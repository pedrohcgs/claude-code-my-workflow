# =============================================================================
# functions_synth.R — Synthetic IPO data generator (fallback only).
#
# Produces small, plausibly-shaped synthetic IPO data so the pipeline runs
# end-to-end and the return logic executes WITHOUT any licensed access. This is
# NOT research data — it exists so a fresh clone can `Rscript 00_run_all.R` and
# so reviewers can exercise the code paths. Real loaders replace `firms`/
# `monthly` with pulls from CRSP / Compustat / Datastream. The generator is
# deterministic given a seed.
# =============================================================================

#' Generate synthetic IPO firm-level and firm-month data
#'
#' RNG-transparent: does NOT call set.seed() (that would reset the global RNG
#' mid-pipeline and break the single-seed guarantee). The orchestrator
#' 00_run_all.R sets the seed once; sequential calls draw from that stream.
#'
#' @param regions Character vector of region codes (e.g. c("US","UK","FR")).
#' @param n_per_region Integer IPOs per region.
#' @param n_months Integer long-run horizon in months (default 36L).
#' @return A list with `firms` (one row per IPO) and `monthly` (firm-month panel).
synthesize_ipos <- function(regions, n_per_region = 40L, n_months = 36L) {
  n_per_region <- as.integer(n_per_region)
  n_months <- as.integer(n_months)
  n <- length(regions) * n_per_region

  region <- rep(regions, each = n_per_region)
  id <- sprintf("SYN%05d", seq_len(n))
  # US trades on exch 1/2/3 (NYSE/AMEX/Nasdaq); others carry a market label.
  exchcd <- ifelse(region == "US", sample(c(1L, 2L, 3L), n, replace = TRUE), NA_integer_)
  ipo_year <- sample(1995L:2024L, n, replace = TRUE)
  ipo_date <- as.Date(sprintf("%d-%02d-15", ipo_year, sample(1L:12L, n, replace = TRUE)))

  offer_price <- round(runif(n, 5, 30), 2)                 # >= 5 (US screen)
  underpricing_true <- rnorm(n, mean = 0.15, sd = 0.25)    # avg ~15% pop
  first_close <- round(offer_price * (1 + underpricing_true), 2)
  mkt_ret_first_day <- rnorm(n, mean = 0.0003, sd = 0.01)

  # Delisting (US only, meaningful): ~20% delist within the window; some are
  # performance-related with a MISSING dlret (to exercise the Shumway fill).
  delisted <- region == "US" & runif(n) < 0.20
  dlstcd <- ifelse(delisted, sample(c(500L, 574L, 580L, 233L), n, replace = TRUE), 100L)
  perf <- dlstcd == 500L | (dlstcd >= 520L & dlstcd <= 584L)
  dlret <- rep(NA_real_, n)
  # Some performance delistings have a recorded return, some are missing.
  has_rec <- perf & runif(n) < 0.5
  dlret[has_rec] <- rnorm(sum(has_rec), mean = -0.4, sd = 0.1)

  firms <- data.frame(
    firm_id     = id,
    region      = region,
    ipo_date    = ipo_date,
    ipo_year    = ipo_year,
    exchcd      = exchcd,
    offer_price = offer_price,
    first_close = first_close,
    mkt_ret_first_day = mkt_ret_first_day,
    dlstcd      = dlstcd,
    dlret       = dlret,
    stringsAsFactors = FALSE
  )

  # Firm-month panel: slight negative drift for IPOs (the "new issues puzzle"),
  # benchmark centered on a normal market return.
  rows <- n * n_months
  monthly <- data.frame(
    firm_id  = rep(id, each = n_months),
    region   = rep(region, each = n_months),
    month    = rep(seq_len(n_months), times = n),
    ret      = rnorm(rows, mean = 0.004, sd = 0.11),   # IPO firm monthly return
    bench_ret = rnorm(rows, mean = 0.007, sd = 0.045), # benchmark monthly return
    rf       = 0.002,
    stringsAsFactors = FALSE
  )
  monthly$is_first <- monthly$month == 1L
  # Truncate the panel at delisting. The monthly panel holds returns for months
  # STRICTLY BEFORE the delisting month; the delisting-month loss is carried by
  # `dlret` and applied once via fold_delisting_return() (no double count).
  # Draw delist months only for delisting firms (no wasted RNG via ifelse), in
  # 6..(n_months-1) so a delisted firm always has a shorter-than-full panel.
  delisted_idx <- firms$dlstcd != 100L
  last_obs <- rep(n_months, n)
  if (any(delisted_idx)) {
    last_obs[delisted_idx] <- sample(6L:(n_months - 1L), sum(delisted_idx), replace = TRUE) - 1L
  }
  names(last_obs) <- firms$firm_id
  keep <- monthly$month <= last_obs[monthly$firm_id]
  monthly <- monthly[keep, , drop = FALSE]

  list(firms = firms, monthly = monthly)
}
