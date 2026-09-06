# 03_decline_curve.R — Arps decline-curve engine (pure functions, no side effects)
#
# Fits exponential / hyperbolic / harmonic decline to one well's monthly oil rate,
# auto-selects the best model by AICc, forecasts to an economic-rate limit, and
# returns fitted parameters + EUR + a history/forecast series.
#
# Entry points:
#   fit_decline(well_df, ...)       -> one well  -> list (class "decline_fit")
#   fit_all_wells(monthly, ...)     -> all wells -> list(summary, forecast, fits)
#   plot_decline_fit(fit)           -> ggplot for one well
#   arps_rate(t, qi, Di, b)         -> rate at time t (years, measured from decline start)
#
# Rate unit: bopd.  Time unit: years.  Cumulative volumes: barrels.
# Time origin ("decline start") is the FIRST month of the fit window, so qi is the
# rate at the start of the analysed decline — not a back-extrapolation to first oil.

source("R/utils.R")
suppressPackageStartupMessages(library(minpack.lm))

DAYS_PER_YEAR <- 365.25

# --- Arps equations ------------------------------------------------------

# Rate q(t). b == 0 -> exponential; b == 1 -> harmonic; else hyperbolic.
arps_rate <- function(t, qi, Di, b) {
  if (b <= 1e-6)              qi * exp(-Di * t)
  else if (abs(b - 1) < 1e-6) qi / (1 + Di * t)
  else                        qi / (1 + b * Di * t)^(1 / b)
}

# Cumulative volume (bbl) produced between rates q1 and q2 on the fitted curve,
# using closed-form Arps cumulatives. q in bopd -> multiply by DAYS_PER_YEAR.
arps_cum_between <- function(q1, q2, qi, Di, b) {
  if (Di <= 0 || q1 <= 0 || q2 <= 0) return(NA_real_)
  npy <- DAYS_PER_YEAR
  if (b <= 1e-6) {
    npy * (q1 - q2) / Di
  } else if (abs(b - 1) < 1e-6) {
    npy * (q1 / Di) * log(q1 / q2)
  } else {
    npy * (q1^b / (Di * (1 - b))) * (q1^(1 - b) - q2^(1 - b))
  }
}

# --- one-model fit -----------------------------------------------------

.fit_one_model <- function(t, q, model, b_max = 1.5) {
  q0 <- max(q[1], stats::quantile(q, 0.95, names = FALSE))
  ok <- is.finite(t) & is.finite(q) & q > 0
  t <- t[ok]; q <- q[ok]
  n <- length(q)
  if (n < 4) return(NULL)

  ctrl <- nls.lm.control(maxiter = 400, ftol = 1e-10)
  fit <- NULL

  if (model == "exponential") {
    fit <- tryCatch(nlsLM(
      q ~ qi * exp(-Di * t),
      start = list(qi = q0, Di = 0.5),
      lower = c(qi = 1e-6, Di = 1e-5), upper = c(qi = 10 * q0, Di = 10),
      control = ctrl), error = function(e) NULL)
    b_fixed <- 0

  } else if (model == "harmonic") {
    fit <- tryCatch(nlsLM(
      q ~ qi / (1 + Di * t),
      start = list(qi = q0, Di = 0.5),
      lower = c(qi = 1e-6, Di = 1e-5), upper = c(qi = 10 * q0, Di = 3),
      control = ctrl), error = function(e) NULL)
    b_fixed <- 1

  } else {  # hyperbolic — multi-start on (b, Di) for robustness
    b_fixed <- NA
    b_grid  <- c(0.3, 0.5, 0.8, 1.1, 1.4)
    b_grid  <- b_grid[b_grid < b_max]
    if (!length(b_grid)) b_grid <- b_max / 2
    best_sse <- Inf
    for (b0 in b_grid) {
      for (Di0 in c(0.2, 0.5, 1.0)) {
        f <- tryCatch(nlsLM(
          q ~ qi / (1 + b * Di * t)^(1 / b),
          start = list(qi = q0, Di = Di0, b = b0),
          lower = c(qi = 1e-6, Di = 1e-5, b = 1e-3),
          upper = c(qi = 10 * q0, Di = 3, b = b_max),
          control = ctrl), error = function(e) NULL)
        if (!is.null(f)) {
          sse <- sum(residuals(f)^2)
          if (is.finite(sse) && sse < best_sse) { best_sse <- sse; fit <- f }
        }
      }
    }
  }
  if (is.null(fit)) return(NULL)

  co   <- coef(fit)
  qi   <- unname(co["qi"])
  Di   <- unname(co["Di"])
  b    <- if (is.na(b_fixed)) unname(co["b"]) else b_fixed
  pred <- arps_rate(t, qi, Di, b)
  sse  <- sum((q - pred)^2)
  sst  <- sum((q - mean(q))^2)
  k    <- length(co)
  V    <- tryCatch(stats::vcov(fit), error = function(e) NULL)
  slog <- {
    r <- log(q) - log(pmax(pred, 1e-9))
    r <- r[is.finite(r)]
    if (length(r) > 2) stats::sd(r) else NA_real_
  }
  list(
    model = model, qi = qi, Di = Di, b = b, n = n,
    r2   = 1 - sse / sst,
    rmse = sqrt(sse / n),
    aicc = n * log(sse / n) + 2 * k + (2 * k * (k + 1)) / max(n - k - 1, 1),
    vcov = V, sigma_log = slog
  )
}

# --- probabilistic bands ------------------------------------------------

# Parameter-covariance sampling (+ mean-1 lognormal predictive noise) -> P90/P50/P10
# rate paths, and P90/P50/P10 EUR via the SAME closed-form used for the point
# estimate (so P50 tracks the reported EUR). No refitting -> stays interactive.
# Returns NULL if the fit covariance is unusable.
.decline_bands <- function(best, fut_t, last_rate, q_econ, np_to_date_bbl, b_max, n = 300) {
  co <- c(qi = best$qi, Di = best$Di)
  if (best$model == "hyperbolic") co <- c(co, b = best$b)
  V <- best$vcov
  if (is.null(V) || any(!is.finite(V)) || nrow(V) != length(co)) return(NULL)
  L <- tryCatch(chol((V + t(V)) / 2), error = function(e) NULL)
  if (is.null(L)) return(NULL)

  P <- sweep(matrix(stats::rnorm(n * length(co)), n) %*% L, 2, co, `+`)
  colnames(P) <- names(co)
  P[, "qi"] <- pmax(P[, "qi"], 1e-3)
  P[, "Di"] <- pmin(pmax(P[, "Di"], 1e-4), 10)
  bv <- if ("b" %in% colnames(P)) pmin(pmax(P[, "b"], 1e-3), b_max)
        else rep(if (best$model == "harmonic") 1 else 0, n)

  M <- vapply(seq_len(n),
              function(i) arps_rate(fut_t, P[i, "qi"], P[i, "Di"], bv[i]),
              numeric(length(fut_t)))                       # length(fut_t) x n
  s <- best$sigma_log
  if (is.finite(s) && s > 0) {
    # mean-1 lognormal noise: a persistent per-path bias + smaller per-month scatter
    s1 <- 0.75 * s; s2 <- 0.55 * s
    bias <- exp(stats::rnorm(n, -0.5 * s1^2, s1))
    M <- sweep(M, 2, bias, `*`) *
      exp(matrix(stats::rnorm(length(M), -0.5 * s2^2, s2), nrow(M)))
  }
  M[!is.finite(M) | M < 0] <- 0
  qs <- apply(M, 1, stats::quantile, probs = c(.10, .50, .90), names = FALSE, na.rm = TRUE)
  sm <- function(v, k = 3) {
    nn <- length(v); if (nn <= k) return(v)
    vapply(seq_len(nn), function(i)
      mean(v[max(1, i - k %/% 2):min(nn, i + k %/% 2)]), numeric(1))
  }
  qs[1, ] <- sm(qs[1, ]); qs[3, ] <- sm(qs[3, ])

  # EUR per sample: same closed-form Arps cumulative as the point estimate
  rem <- vapply(seq_len(n), function(i) {
    r <- arps_cum_between(last_rate, q_econ, P[i, "qi"], P[i, "Di"], bv[i])
    if (is.na(r) || r < 0) 0 else r
  }, numeric(1))
  eq <- stats::quantile(np_to_date_bbl + rem, probs = c(.10, .50, .90),
                        names = FALSE, na.rm = TRUE)

  list(rate_lo = qs[1, ], rate_mid = qs[2, ], rate_hi = qs[3, ],
       eur_p90 = eq[1] / 1e6, eur_p50 = eq[2] / 1e6, eur_p10 = eq[3] / 1e6)
}

# --- choose the fit window ------------------------------------------

# Resolve "auto" to a concrete window name for this well's data.
# Use "last_stable" only when there is a LONG hiatus (~6 months, i.e. a real
# intervention) and the post-hiatus segment is long enough to fit; a couple of
# brief shut-in months should not throw away years of decline history.
.resolve_window <- function(months, window) {
  if (window != "auto") return(window)
  gaps <- as.numeric(diff(months))
  brk  <- which(gaps > 180)
  if (!length(brk)) return("post_peak")
  if (length(months) - max(brk) >= 12) "last_stable" else "post_peak"
}

# Indices (into the producing-months series) to fit on.
# gap_days: hiatus length that starts a new "stable" segment (last_stable only).
.select_window <- function(months, q, window, gap_days = 45) {
  n <- length(q)
  peak <- which.max(q)
  if (window == "all")       return(seq_len(n))
  if (window == "post_peak") return(peak:n)
  if (window == "last_stable") {
    brk <- which(as.numeric(diff(months)) > gap_days)
    seg_start <- if (length(brk)) max(brk) + 1L else 1L
    idx <- seg_start:n
    if (length(idx) >= 6) return(idx)
    return(peak:n)                                 # fall back if last segment tiny
  }
  seq_len(n)
}

# --- main: fit one well ------------------------------------------

#' @param well_df   monthly rows for ONE well: month, oil_rate_bopd, oil_bbl, cum_oil_bbl
#' @param q_econ    economic oil rate (bopd) that ends the forecast
#' @param window    "post_peak" (default) | "last_stable" | "all" | "auto"
#' @param max_years hard cap on forecast horizon (auto-tightened for weak/short fits)
#' @param b_max     upper bound on the hyperbolic exponent b (guards optimistic tails)
fit_decline <- function(well_df,
                        q_econ    = 50,
                        window    = "post_peak",
                        max_years = 30,
                        b_max     = 1.5,
                        rate_col  = "oil_rate_bopd") {

  well <- well_df$well[1]
  d <- well_df |>
    dplyr::arrange(month) |>
    dplyr::filter(.data[[rate_col]] > 0, is.finite(.data[[rate_col]]))

  flags <- character(0)
  mk <- function(...) structure(list(well = well, ...), class = "decline_fit")

  if (nrow(d) < 6) {
    return(mk(ok = FALSE, flags = "insufficient data (<6 producing months)",
              history = well_df))
  }

  months <- d$month
  q      <- d[[rate_col]]
  t0     <- min(months)                       # first oil (reference only)

  resolved_window <- .resolve_window(months, window)
  idx <- .select_window(months, q, resolved_window,
                        gap_days = if (window == "auto") 180 else 45)
  if (length(idx) < 4) {
    idx <- seq_len(nrow(d))
    flags <- c(flags, "fit window too short; used all producing months")
  }

  t_anchor <- months[idx[1]]                  # decline start = first month of window
  tf <- as.numeric(months[idx] - t_anchor) / DAYS_PER_YEAR
  qf <- q[idx]

  models <- c("exponential", "hyperbolic", "harmonic")
  if (b_max < 1) models <- setdiff(models, "harmonic")
  cand <- Filter(Negate(is.null),
                 lapply(models, \(m) .fit_one_model(tf, qf, m, b_max = b_max)))
  if (length(cand) == 0) {
    return(mk(ok = FALSE, flags = c(flags, "all model fits failed"), history = well_df))
  }
  best <- cand[[which.min(vapply(cand, `[[`, numeric(1), "aicc"))]]

  # --- sanity flags ---
  span_yr <- as.numeric(max(months) - min(months)) / DAYS_PER_YEAR
  if (best$model == "hyperbolic" && best$b > 1)
    flags <- c(flags, sprintf("hyperbolic b = %.2f (> 1): long-tail forecast may be optimistic", best$b))
  if (best$Di > 1.5)
    flags <- c(flags, sprintf("very steep decline (Di = %.1f/yr): likely a ramp-up / short-history artifact", best$Di))
  if (best$r2 < 0.5)
    flags <- c(flags, sprintf("weak fit (R2 = %.2f): treat forecast as indicative only", best$r2))
  if (span_yr < 1)
    flags <- c(flags, "less than 1 year of history: forecast is low-confidence")

  # --- forecast horizon: tighten for weak / short / strained fits ---
  eff_max_years <- max_years
  strained <- best$Di >= 2.99 || (best$model != "exponential" && best$b >= b_max - 1e-3)
  if (best$r2 < 0.6 || span_yr < 1.5 || strained) {
    eff_max_years <- min(max_years, 10L)
    if (eff_max_years < max_years)
      flags <- c(flags, sprintf("forecast horizon capped at %d yr (weak / short / boundary fit); EUR may understate", eff_max_years))
  }

  # --- forecast from the last observed month to the economic limit ---
  last_date <- max(months)
  last_rate <- q[which.max(months)]

  fut_dates <- seq(last_date %m+% months(1), by = "month",
                   length.out = eff_max_years * 12)
  fut_t     <- as.numeric(fut_dates - t_anchor) / DAYS_PER_YEAR
  fut_q     <- arps_rate(fut_t, best$qi, best$Di, best$b)
  keep      <- which(fut_q >= q_econ)
  if (length(keep) == 0) {
    flags <- c(flags, sprintf("already at/below economic rate %.0f bopd", q_econ))
    fc <- tibble::tibble(date = as.Date(character()), t_years = numeric(), rate_bopd = numeric())
    q_end <- last_rate
  } else {
    kk <- seq_len(max(keep))
    fc <- tibble::tibble(date = fut_dates[kk], t_years = fut_t[kk], rate_bopd = fut_q[kk])
    q_end <- min(fc$rate_bopd)
  }

  # --- volumes ---
  np_to_date <- dplyr::last(well_df$cum_oil_bbl)
  remaining  <- arps_cum_between(last_rate, max(q_end, q_econ), best$qi, best$Di, best$b)
  remaining  <- ifelse(is.na(remaining) || remaining < 0, 0, remaining)
  eur        <- np_to_date + remaining

  # --- probabilistic bands over the forecast window ---
  bands <- NULL
  if (nrow(fc) > 1) {
    bb <- tryCatch(.decline_bands(best, fc$t_years, last_rate, q_econ, np_to_date, b_max),
                   error = function(e) NULL)
    if (!is.null(bb)) {
      eur_pt <- eur / 1e6                      # keep the point estimate inside the range
      bands <- list(
        series = tibble::tibble(date = fc$date, lo = pmax(bb$rate_lo, 0),
                                mid = bb$rate_mid, hi = bb$rate_hi),
        eur_p90 = min(bb$eur_p90, eur_pt), eur_p50 = bb$eur_p50,
        eur_p10 = max(bb$eur_p10, eur_pt))
    }
  }
  # bands stays NULL silently when the fit covariance is unusable

  de1 <- 1 - arps_rate(1, best$qi, best$Di, best$b) / best$qi   # first-year effective decline

  # --- series for plotting (t measured from decline start) ---
  yrs_from_anchor <- function(x) as.numeric(x - t_anchor) / DAYS_PER_YEAR
  hist_series <- well_df |>
    dplyr::transmute(date = month, t_years = yrs_from_anchor(month),
                     rate_bopd = .data[[rate_col]], phase = "history")
  fit_series <- tibble::tibble(date = months[idx], t_years = tf) |>   # window only, no back-cast
    dplyr::mutate(rate_bopd = arps_rate(t_years, best$qi, best$Di, best$b), phase = "fit")
  series <- dplyr::bind_rows(hist_series, fit_series, dplyr::mutate(fc, phase = "forecast"))

  mk(
    ok = TRUE,
    model = best$model,
    params = list(qi_bopd = best$qi, Di_nominal_annual = best$Di, b = best$b),
    de_first_year = de1,
    fit_quality = list(r2 = best$r2, rmse = best$rmse, aicc = best$aicc,
                       n_points = best$n, window = resolved_window,
                       window_requested = window),
    t0 = t0, decline_start = t_anchor,
    last_date = last_date, last_rate_bopd = last_rate,
    q_econ = q_econ, b_max = b_max,
    eol_date = if (nrow(fc)) max(fc$date) else last_date,
    remaining_months = nrow(fc),
    np_to_date_bbl = np_to_date,
    remaining_bbl  = remaining,
    eur_bbl        = eur,
    eur_mmbbl      = eur / 1e6,
    eur_p90_mmbbl  = if (!is.null(bands)) bands$eur_p90 else NA_real_,
    eur_p50_mmbbl  = if (!is.null(bands)) bands$eur_p50 else NA_real_,
    eur_p10_mmbbl  = if (!is.null(bands)) bands$eur_p10 else NA_real_,
    series = series,
    forecast = fc,
    bands = if (!is.null(bands)) bands$series else NULL,
    flags = flags
  )
}

# --- fit every well --------------------------------------------

fit_all_wells <- function(monthly, ...) {
  wells <- sort(unique(monthly$well))
  fits  <- setNames(lapply(wells, \(w) fit_decline(dplyr::filter(monthly, well == w), ...)), wells)

  summ <- purrr_map_df(fits, function(f) {
    if (!isTRUE(f$ok)) {
      return(tibble::tibble(well = f$well, model = NA_character_, ok = FALSE,
                            flags = paste(f$flags, collapse = "; ")))
    }
    tibble::tibble(
      well            = f$well,
      model           = f$model,
      ok              = TRUE,
      window          = f$fit_quality$window,
      qi_bopd         = round(f$params$qi_bopd),
      Di_nom_annual   = round(f$params$Di_nominal_annual, 3),
      b               = round(f$params$b, 3),
      de_first_year   = round(f$de_first_year, 3),
      r2              = round(f$fit_quality$r2, 3),
      n_points        = f$fit_quality$n_points,
      last_rate_bopd  = round(f$last_rate_bopd),
      eol_date        = f$eol_date,
      np_to_date_mbbl = round(f$np_to_date_bbl / 1e6, 3),
      remaining_mbbl  = round(f$remaining_bbl / 1e6, 3),
      eur_mmbbl       = round(f$eur_mmbbl, 3),
      eur_p90_mmbbl   = round(f$eur_p90_mmbbl, 3),
      eur_p10_mmbbl   = round(f$eur_p10_mmbbl, 3),
      flags           = paste(f$flags, collapse = "; ")
    )
  })

  forecast <- purrr_map_df(fits, function(f) {
    if (!isTRUE(f$ok)) return(NULL)
    dplyr::mutate(f$series, well = f$well)
  })

  list(summary = summ, forecast = forecast, fits = fits)
}

# tiny dplyr-only row-binding map (avoids a purrr dependency)
purrr_map_df <- function(x, f) {
  out <- Filter(Negate(is.null), lapply(x, f))
  if (length(out) == 0) return(tibble::tibble())
  dplyr::bind_rows(out)
}

# --- fit-quality label -------------------------------------------

fit_grade <- function(r2) {
  if (is.null(r2) || is.na(r2)) return(list(label = "n/a",  colour = "secondary"))
  if (r2 >= 0.9)  return(list(label = "Good", colour = "success"))
  if (r2 >= 0.75) return(list(label = "Fair", colour = "warning"))
  list(label = "Weak", colour = "danger")
}

# --- plotting -------------------------------------------------

plot_decline_fit <- function(fit, log_y = TRUE, compact = FALSE) {
  if (!isTRUE(fit$ok)) {
    return(ggplot() +
             annotate("text", 0, 0, label = paste(fit$well, "-", paste(fit$flags, collapse = "; "))) +
             theme_void())
  }
  s <- fit$series
  sub <- if (compact) NULL else sprintf(
    "qi=%.0f bopd at decline start | Di=%.2f/yr | b=%.2f | R²=%.2f | EUR=%.2f MMbbl (%.2f remaining)",
    fit$params$qi_bopd, fit$params$Di_nominal_annual, fit$params$b,
    fit$fit_quality$r2, fit$eur_mmbbl, fit$remaining_bbl / 1e6)
  p <- ggplot(s, aes(date, rate_bopd))
  if (!is.null(fit$bands) && nrow(fit$bands) > 1) {
    bnd <- fit$bands
    if (log_y) { bnd$lo <- pmax(bnd$lo, 1e-6) }
    p <- p + geom_ribbon(data = bnd, inherit.aes = FALSE,
                         aes(x = date, ymin = lo, ymax = hi),
                         fill = "#c62828", alpha = 0.14)
  }
  p <- p +
    geom_point(data = dplyr::filter(s, phase == "history", rate_bopd > 0),
               size = 1, colour = "#37474f") +
    geom_line(data = dplyr::filter(s, phase == "fit", rate_bopd > 0),
              colour = "#1b5e9c", linewidth = 0.9) +
    geom_line(data = dplyr::filter(s, phase == "forecast"),
              colour = "#c62828", linewidth = 0.9) +
    geom_hline(yintercept = fit$q_econ, linetype = "dashed", colour = "grey55") +
    annotate("text", x = min(s$date), y = fit$q_econ, vjust = -0.5, hjust = 0,
             label = paste0("econ limit ", fit$q_econ, " bopd"), size = 3, colour = "grey40") +
    labs(
      title = sprintf("%s — %s decline (window: %s)",
                      fit$well, fit$model, fit$fit_quality$window),
      subtitle = sub, x = NULL, y = "Oil rate (bopd)",
      caption = if (!is.null(fit$bands)) "Shaded band = P90–P10 forecast range" else NULL
    ) +
    theme_geoai()
  if (log_y) p + scale_y_log10(labels = scales::comma)
  else       p + scale_y_continuous(labels = scales::comma)
}
