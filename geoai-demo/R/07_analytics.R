# 07_analytics.R — field-level KPI grid, decline-forecast backtest, and analog-well
# matching / new-well estimation. Pure functions; no side effects.
#
#   field_kpis(monthly, fits)                 -> per-well KPI tibble
#   backtest_well(well_df, holdout_months, …) -> forecast-vs-actual accuracy for one well
#   well_features(monthly, fits)              -> standardised feature matrix (one row/well)
#   analogs(feat, target_well, k)             -> k nearest analog wells + distances
#   estimate_new_well(feat, inputs, k)        -> analog-weighted qi / Di / b / EUR guess

source("R/03_decline_curve.R")   # %||%, purrr_map_df, fit_decline, DAYS_PER_YEAR

# --- per-well KPI grid ------------------------------------------------

.ann_decl <- function(r, k) {
  n <- length(r)
  if (n <= k || !is.finite(r[n - k]) || r[n - k] <= 0 || !is.finite(r[n])) return(NA_real_)
  1 - (r[n] / r[n - k])^(12 / k)
}
.slope_yr <- function(y) {
  ok <- is.finite(y); if (sum(ok) < 3) return(NA_real_)
  x <- seq_along(y)[ok]; unname(stats::coef(stats::lm(y[ok] ~ x))[2]) * 12
}

field_kpis <- function(monthly, fits) {
  wells <- names(fits)
  purrr_map_df(wells, function(w) {
    d <- monthly |>
      dplyr::filter(well == w, oil_rate_bopd > 0, is.finite(oil_rate_bopd)) |>
      dplyr::arrange(month)
    n <- nrow(d); f <- fits[[w]]
    r <- d$oil_rate_bopd
    wc <- if ("wct" %in% names(d)) d$wct else rep(NA_real_, n)
    tibble::tibble(
      well            = w,
      months_prod     = n,
      current_bopd    = if (n) r[n] else NA_real_,
      peak_bopd       = if (n) max(r, na.rm = TRUE) else NA_real_,
      decl_3mo        = .ann_decl(r, 3),
      decl_6mo        = .ann_decl(r, 6),
      decl_12mo       = .ann_decl(r, 12),
      cum_oil_mmbbl   = if ("cum_oil_bbl" %in% names(d) && n) dplyr::last(d$cum_oil_bbl) / 1e6 else NA_real_,
      wct             = if (n) wc[n] else NA_real_,
      wct_trend_yr    = .slope_yr(utils::tail(wc, 6)),
      model           = if (isTRUE(f$ok)) f$model else NA_character_,
      r2              = if (isTRUE(f$ok)) f$fit_quality$r2 else NA_real_,
      months_to_econ  = if (isTRUE(f$ok)) f$remaining_months else NA_real_,
      eur_mmbbl       = if (isTRUE(f$ok)) f$eur_mmbbl else NA_real_,
      eur_p90_mmbbl   = if (isTRUE(f$ok)) f$eur_p90_mmbbl else NA_real_,
      eur_p10_mmbbl   = if (isTRUE(f$ok)) f$eur_p10_mmbbl else NA_real_
    )
  })
}

# --- forecast-vs-actual backtest -----------------------------------

# Fit the decline on all but the last `holdout_months`, forecast that window,
# compare to the actual. Returns MAPE and bias over the held-out months.
backtest_well <- function(well_df, holdout_months = 6, ...) {
  d <- well_df |>
    dplyr::arrange(month) |>
    dplyr::filter(oil_rate_bopd > 0, is.finite(oil_rate_bopd))
  n <- nrow(d)
  if (n < holdout_months + 12)
    return(list(ok = FALSE, note = "not enough history to backtest"))

  train <- d[seq_len(n - holdout_months), ]
  test  <- d[(n - holdout_months + 1):n, ]
  f <- tryCatch(fit_decline(train, ...), error = function(e) NULL)
  if (is.null(f) || !isTRUE(f$ok)) return(list(ok = FALSE, note = "training fit failed"))

  anchor <- f$decline_start
  t_test <- as.numeric(test$month - anchor) / DAYS_PER_YEAR
  pred   <- arps_rate(t_test, f$params$qi_bopd, f$params$Di_nominal_annual, f$params$b)
  act    <- test$oil_rate_bopd
  ok     <- is.finite(pred) & is.finite(act) & act > 0
  if (!any(ok)) return(list(ok = FALSE, note = "no comparable months"))
  list(
    ok = TRUE,
    holdout = holdout_months,
    mape = mean(abs(pred[ok] - act[ok]) / act[ok]),
    bias = mean((pred[ok] - act[ok]) / act[ok]),                 # + = forecast high
    detail = tibble::tibble(month = test$month[ok],
                            actual = round(act[ok], 1),
                            forecast = round(pred[ok], 1))
  )
}

backtest_field <- function(monthly, holdout_months = 6, ...) {
  wells <- sort(unique(monthly$well))
  purrr_map_df(wells, function(w) {
    b <- backtest_well(dplyr::filter(monthly, well == w), holdout_months, ...)
    tibble::tibble(well = w,
                   backtest_ok = isTRUE(b$ok),
                   mape = if (isTRUE(b$ok)) b$mape else NA_real_,
                   bias = if (isTRUE(b$ok)) b$bias else NA_real_,
                   note = if (isTRUE(b$ok)) "" else b$note)
  })
}

# --- analog-well matching ------------------------------------------

# One standardised feature row per well: shape of the decline + fluid signals.
well_features <- function(monthly, fits) {
  wells <- names(fits)
  raw <- purrr_map_df(wells, function(w) {
    d <- monthly |> dplyr::filter(well == w, oil_rate_bopd > 0) |> dplyr::arrange(month)
    n <- nrow(d); f <- fits[[w]]
    wc <- if ("wct" %in% names(d)) d$wct else rep(NA_real_, n)
    tibble::tibble(
      well        = w,
      log_peak    = if (n) log10(pmax(max(d$oil_rate_bopd, na.rm = TRUE), 1)) else NA_real_,
      di          = if (isTRUE(f$ok)) f$params$Di_nominal_annual else NA_real_,
      b           = if (isTRUE(f$ok)) f$params$b else NA_real_,
      log_cum     = if ("cum_oil_bbl" %in% names(d) && n) log10(pmax(dplyr::last(d$cum_oil_bbl), 1)) else NA_real_,
      wct_end     = if (n) dplyr::last(wc) else NA_real_,
      wct_slope   = .slope_yr(utils::tail(wc, 12)),
      months_prod = n
    )
  })
  num <- setdiff(names(raw), "well")
  mat <- as.matrix(raw[num])
  ctr <- colMeans(mat, na.rm = TRUE)
  scl <- apply(mat, 2, stats::sd, na.rm = TRUE); scl[!is.finite(scl) | scl == 0] <- 1
  z <- sweep(sweep(mat, 2, ctr, `-`), 2, scl, `/`)
  z[!is.finite(z)] <- 0
  list(well = raw$well, names = num, center = ctr, scale = scl, z = z, raw = raw)
}

analogs <- function(feat, target_well, k = 3) {
  i <- match(target_well, feat$well)
  if (is.na(i)) return(NULL)
  d <- sqrt(rowSums(sweep(feat$z, 2, feat$z[i, ], `-`)^2))
  ord <- order(d)
  ord <- ord[ord != i][seq_len(min(k, length(ord) - 1))]
  tibble::tibble(analog = feat$well[ord], distance = round(d[ord], 2),
                 di = round(feat$raw$di[ord], 2), b = round(feat$raw$b[ord], 2),
                 peak_bopd = round(10^feat$raw$log_peak[ord]),
                 cum_mmbbl = round(10^feat$raw$log_cum[ord] / 1e6, 2))
}

# inputs: named list with any of log_peak / di / b / log_cum / wct_end / wct_slope
estimate_new_well <- function(feat, inputs, fits, k = 3) {
  q <- feat$center
  for (nm in intersect(names(inputs), names(q))) {
    v <- inputs[[nm]]
    if (!is.null(v) && length(v) == 1 && is.finite(v)) q[nm] <- v
  }
  zq <- (q - feat$center) / feat$scale
  zq[!is.finite(zq)] <- 0
  d  <- sqrt(rowSums(sweep(feat$z, 2, zq, `-`)^2))
  w  <- 1 / (d[order(d)][seq_len(min(k, length(d)))]^2 + 1e-6)
  idx <- order(d)[seq_len(min(k, length(d)))]
  wn  <- w / sum(w)
  fk  <- fits[feat$well[idx]]
  pick <- function(g) sum(wn * vapply(fk, g, numeric(1)))
  list(
    analogs = feat$well[idx], weights = round(wn, 2),
    qi_bopd = pick(\(f) if (isTRUE(f$ok)) f$params$qi_bopd else NA_real_),
    di      = pick(\(f) if (isTRUE(f$ok)) f$params$Di_nominal_annual else NA_real_),
    b       = pick(\(f) if (isTRUE(f$ok)) f$params$b else NA_real_),
    eur_mmbbl = pick(\(f) if (isTRUE(f$ok)) f$eur_mmbbl else NA_real_)
  )
}
