# 06_screening.R — rule-based well-attention screening (NOT a machine-learning model)
#
#   screen_wells(monthly, fits, q_econ) -> tibble ordered by attention score
#
# Every input to the score is a plain, inspectable production signal. The score is
# a transparent weighted sum — no training, no black box. It flags wells worth a
# closer look for intervention; it does not decide anything.

source("R/03_decline_curve.R")   # for %||% and purrr_map_df

# annualised decline over the last k months of actual rate
.ann_decline <- function(r, k) {
  n <- length(r)
  if (n <= k || !is.finite(r[n - k]) || r[n - k] <= 0 || !is.finite(r[n])) return(NA_real_)
  1 - (r[n] / r[n - k])^(12 / k)
}

# slope (per year) of a short series, robust to a couple of NAs
.slope_yr <- function(y) {
  ok <- is.finite(y); if (sum(ok) < 3) return(NA_real_)
  x <- seq_along(y)[ok]; y <- y[ok]
  unname(stats::coef(stats::lm(y ~ x))[2]) * 12
}

.clamp01 <- function(x, lo, hi) pmin(pmax((x - lo) / (hi - lo), 0), 1)

screen_wells <- function(monthly, fits, q_econ = 50) {
  wells <- names(fits)

  purrr_map_df(wells, function(w) {
    d <- monthly |>
      dplyr::filter(well == w, oil_rate_bopd > 0, is.finite(oil_rate_bopd)) |>
      dplyr::arrange(month)
    n <- nrow(d)
    f <- fits[[w]]
    if (n < 3)
      return(tibble::tibble(well = w, current_bopd = NA_real_, decline_6mo = NA_real_,
                            decline_12mo = NA_real_, underperf_vs_trend = NA_real_,
                            wct = NA_real_, wct_trend_yr = NA_real_,
                            remaining_mmbbl = NA_real_, months_to_econ = NA_real_,
                            attention = NA_real_, signal = "insufficient data"))

    r         <- d$oil_rate_bopd
    last_rate <- r[n]
    dec6      <- .ann_decline(r, 6)
    dec12     <- .ann_decline(r, 12)
    wct_last  <- if ("wct" %in% names(d)) d$wct[n] else NA_real_
    wct_trend <- if ("wct" %in% names(d)) .slope_yr(utils::tail(d$wct, 6)) else NA_real_

    # underperformance vs the well's own fitted decline, averaged over the last
    # 3 producing months (smooths partial-month / abandonment-ramp noise)
    underperf <- NA_real_
    if (isTRUE(f$ok)) {
      fs <- dplyr::filter(f$series, phase == "fit")
      k  <- min(3L, nrow(fs))
      pred_tail <- if (k > 0) mean(utils::tail(fs$rate_bopd, k), na.rm = TRUE) else NA_real_
      act_tail  <- mean(utils::tail(r, k), na.rm = TRUE)
      if (is.finite(pred_tail) && pred_tail > 0 && is.finite(act_tail))
        underperf <- max((pred_tail - act_tail) / pred_tail, 0)   # 0 = at or above trend
    }
    rem_mmbbl   <- if (isTRUE(f$ok)) f$remaining_bbl / 1e6 else NA_real_
    months_econ <- if (isTRUE(f$ok)) f$remaining_months else NA_real_

    # transparent attention score (0–100)
    s_under <- .clamp01(underperf %||% 0, 0.05, 0.40)   # producing >5% under its own trend
    s_wct   <- .clamp01(wct_last  %||% 0, 0.50, 0.95)   # already water-heavy
    s_wctup <- .clamp01(wct_trend %||% 0, 0.02, 0.25)   # water cut rising
    s_rem   <- .clamp01(rem_mmbbl %||% 0, 0.20, 3.00)   # enough oil left to be worth it
    score   <- round(100 * (0.35 * s_under + 0.20 * s_wct + 0.20 * s_wctup + 0.25 * s_rem))

    signal <- dplyr::case_when(
      !isTRUE(f$ok)                                        ~ "No reliable decline fit — short history",
      (rem_mmbbl %||% 1) < 0.10                            ~ "Near end of life — limited upside",
      (wct_trend %||% 0) > 0.08 & (wct_last %||% 0) > 0.60 ~ "Rising water cut — water shut-off / conformance",
      (underperf %||% 0) > 0.25 & (wct_last %||% 1) < 0.55 ~ "Below trend, low water — stimulation / re-perforation",
      (underperf %||% 0) > 0.25                            ~ "Below trend — diagnostic / intervention review",
      (dec6      %||% 0) > 0.70                            ~ "Steep recent decline — artificial-lift review",
      TRUE                                                 ~ "Monitor"
    )

    tibble::tibble(
      well = w, current_bopd = round(last_rate),
      decline_6mo = dec6, decline_12mo = dec12,
      underperf_vs_trend = underperf, wct = wct_last, wct_trend_yr = wct_trend,
      remaining_mmbbl = rem_mmbbl, months_to_econ = months_econ,
      attention = score, signal = signal
    )
  }) |>
    dplyr::arrange(dplyr::desc(dplyr::coalesce(attention, -1)))
}
