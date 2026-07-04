# =============================================================================
# functions_returns.R — Pure functions for IPO return construction.
#
# No side effects, no I/O, no global state. Every function is unit-tested in
# tests/testthat/test_returns.R against synthetic data, so the return logic is
# verifiable WITHOUT live WRDS / Datastream access. Sourced by 00_run_all.R
# before the pipeline and by the tests.
#
# References (see Bibliography_base.bib and the plan):
#   Ritter (1991); Barber & Lyon (1997); Lyon, Barber & Tsai (1999);
#   Mitchell & Stafford (2000); Shumway (1997); Shumway & Warther (1999);
#   Ince & Porter (2006).
# =============================================================================

# ---- First-day underpricing -------------------------------------------------

#' First-day IPO underpricing (initial return)
#'
#' Underpricing = first-day close / offer price - 1, optionally adjusted for the
#' contemporaneous market return over the same (one-day) window.
#'
#' @param first_close Numeric vector of first-day closing prices (> 0).
#' @param offer_price Numeric vector of offer/issue prices (> 0).
#' @param market_return Numeric vector (or scalar) of the market return over the
#'   first trading day; default 0 (raw underpricing).
#' @return Numeric vector of (market-adjusted) initial returns; NA where inputs
#'   are non-positive or missing.
compute_underpricing <- function(first_close, offer_price, market_return = 0) {
  bad <- is.na(first_close) | is.na(offer_price) | offer_price <= 0 | first_close <= 0
  raw <- first_close / offer_price - 1
  out <- raw - market_return
  out[bad] <- NA_real_
  out
}

# ---- Holding-period / long-run returns --------------------------------------

#' Buy-and-hold return from a vector of periodic returns
#'
#' @param returns Numeric vector of periodic simple returns.
#' @param na.rm Logical; if FALSE (default) any NA yields NA (a gap in the
#'   holding period is a real problem, not something to silently skip).
#' @return Scalar buy-and-hold return prod(1 + r) - 1.
buy_and_hold_return <- function(returns, na.rm = FALSE) {
  if (!na.rm && anyNA(returns)) return(NA_real_)
  prod(1 + returns, na.rm = na.rm) - 1
}

#' Buy-and-hold abnormal return (BHAR)
#'
#' Compounds the firm's holding-period return and subtracts the benchmark's
#' (matched control firm or reference portfolio; Barber & Lyon 1997).
#'
#' @param firm_returns Numeric vector of the IPO firm's periodic returns.
#' @param bench_returns Numeric vector of the benchmark's periodic returns
#'   (same length / window).
#' @return Scalar BHAR.
compute_bhar <- function(firm_returns, bench_returns) {
  if (length(firm_returns) != length(bench_returns)) {
    stop("compute_bhar(): firm and benchmark return vectors must be equal length.")
  }
  buy_and_hold_return(firm_returns) - buy_and_hold_return(bench_returns)
}

#' Cumulative abnormal return (CAR)
#'
#' Sum of periodic abnormal returns (firm - benchmark).
#'
#' @param abnormal_returns Numeric vector of periodic abnormal returns.
#' @param na.rm Logical; default FALSE.
#' @return Scalar CAR.
compute_car <- function(abnormal_returns, na.rm = FALSE) {
  sum(abnormal_returns, na.rm = na.rm)
}

# ---- Delisting-return handling (long-run survivorship) ----------------------

#' Fill missing performance-related delisting returns (Shumway 1997)
#'
#' CRSP frequently records a missing delisting return precisely when a firm
#' delists for cause. Leaving these as NA/0 upward-biases IPO long-run
#' performance. Following Shumway (1997) and Shumway & Warther (1999), impute
#' -30\% for NYSE/AMEX and -55\% for Nasdaq when the delisting is
#' performance-related and the recorded dlret is missing. Following the
#' Shumway & Warther (1999) convention widely used in the IPO long-run
#' literature, performance-related delistings are codes 500-599 (dropped for
#' cause / liquidation), which is broader than Shumway (1997)'s original
#' 500 & 520-584 band — an under-inclusive net leaves survivorship bias intact.
#'
#' @param dlret Numeric vector of CRSP delisting returns (may be NA).
#' @param dlstcd Integer vector of CRSP delisting codes.
#' @param exchcd Integer vector of CRSP exchange codes (1/2 = NYSE/AMEX, 3 = Nasdaq).
#' @return Numeric vector of delisting returns with performance-related NAs filled.
fill_delisting_return <- function(dlret, dlstcd, exchcd) {
  perf_related <- !is.na(dlstcd) & dlstcd >= 500L & dlstcd <= 599L
  missing_dlret <- is.na(dlret)
  is_nasdaq <- !is.na(exchcd) & exchcd == 3L
  fill <- ifelse(is_nasdaq, -0.55, -0.30)
  needs_fill <- perf_related & missing_dlret
  dlret[needs_fill] <- fill[needs_fill]
  dlret
}

#' Fold a delisting return into a holding-period return
#'
#' @param returns Numeric vector of periodic returns up to (not incl.) delisting.
#' @param dlret Scalar delisting return for the final (partial) period; NA -> 0.
#' @return Scalar holding-period return incorporating the delisting return.
fold_delisting_return <- function(returns, dlret) {
  dlret <- if (is.na(dlret)) 0 else dlret
  (1 + buy_and_hold_return(returns)) * (1 + dlret) - 1
}

# ---- Calendar-time portfolio alpha (Mitchell & Stafford 2000) ---------------

#' Fama-French calendar-time abnormal return (alpha)
#'
#' Regress the monthly excess return of the event portfolio on factor returns;
#' the intercept is the risk-adjusted abnormal performance. This inference is
#' robust to the cross-sectional correlation induced by hot-market IPO
#' clustering (Mitchell & Stafford 2000), unlike BHAR t-stats.
#'
#' @param port_excess Numeric vector: portfolio return minus the risk-free rate,
#'   one observation per calendar month.
#' @param factors Numeric matrix / data.frame of factor returns (e.g. columns
#'   mktrf, smb, hml[, umd]), one row per calendar month, aligned to port_excess.
#' @return A list with alpha (monthly), its standard error, t-statistic, and the
#'   fitted lm object.
calendar_time_alpha <- function(port_excess, factors) {
  factors <- as.data.frame(factors)
  if (nrow(factors) != length(port_excess)) {
    stop("calendar_time_alpha(): factors rows must match length(port_excess).")
  }
  fit <- stats::lm(
    stats::reformulate(names(factors), response = "port_excess"),
    data = data.frame(port_excess = port_excess, factors)
  )
  co <- summary(fit)$coefficients
  list(
    alpha = unname(co["(Intercept)", "Estimate"]),
    se    = unname(co["(Intercept)", "Std. Error"]),
    t     = unname(co["(Intercept)", "t value"]),
    fit   = fit
  )
}

# ---- Datastream cleaning (Ince & Porter 2006) -------------------------------

#' Ince & Porter (2006) dynamic reversal screen
#'
#' Flags spurious return reversals in Datastream: if either R_t or R_{t-1}
#' exceeds `thresh` (default 300\%) and their compounded two-period return is
#' below `floor` (default 50\%), both returns are treated as data errors.
#' IPO first-day pops are legitimately large, so the first post-listing
#' observation is exempted via `is_first`.
#'
#' @param ret Numeric vector of periodic returns (chronological).
#' @param is_first Logical vector marking the IPO's first observation (exempt).
#' @param thresh Upper return threshold (default 3.0 = 300\%).
#' @param floor Compounded-return floor (default 0.5 = 50\%).
#' @return Logical vector: TRUE where the observation should be set to NA.
ince_porter_reversal <- function(ret, is_first = rep(FALSE, length(ret)),
                                 thresh = 3.0, floor = 0.5) {
  n <- length(ret)
  flag <- logical(n)
  if (n < 2L) return(flag)
  ret_lag <- c(NA_real_, ret[-n])
  big <- (!is.na(ret) & ret > thresh) | (!is.na(ret_lag) & ret_lag > thresh)
  compounded <- (1 + ret) * (1 + ret_lag) - 1
  reversal <- big & !is.na(compounded) & compounded < floor
  flag <- reversal & !is_first
  # `reversal` fires at t (the crash), whose pair partner is the EARLIER spike at
  # t-1. To also flag that earlier observation, shift the flag LEFT
  # (flag_lag[t-1] = flag[t]): c(flag[-1], FALSE). (Verified by the directional
  # unit test in tests/test_returns.R — a right shift flags the wrong month.)
  flag_lag <- c(flag[-1L], FALSE) & !is_first
  flag | flag_lag
}

# ---- Utilities --------------------------------------------------------------

#' Symmetric winsorization at the p / (1-p) quantiles
#'
#' @param x Numeric vector.
#' @param p Lower tail probability (default 0.01 -> 1\%/99\%).
#' @return Winsorized numeric vector.
winsorize <- function(x, p = 0.01) {
  if (p <= 0 || p >= 0.5) stop("winsorize(): p must be in (0, 0.5).")
  q <- stats::quantile(x, probs = c(p, 1 - p), na.rm = TRUE, names = FALSE)
  pmin(pmax(x, q[1L]), q[2L])
}
