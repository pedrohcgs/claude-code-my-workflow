# =============================================================================
# 03_returns.R — Compute IPO returns from the analysis sample.
#
# Uses the pure functions in functions_returns.R (unit-tested separately) so the
# logic here is thin orchestration. Produces:
#   - underpricing : firm-level first-day underpricing (US + UK where offer
#                    prices are clean; NA elsewhere by design)
#   - longrun      : firm-level 36-month BHAR (delisting returns folded in)
#   - ct_alpha     : pooled + per-region Fama-French-style calendar-time alpha
# Saved to OUT_DIR as returns.rds. Consumed by 04_tables.R / 05_figures.R.
# =============================================================================

for (obj in c("ipo_sample", "ipo_monthly", "OUT_DIR")) {
  if (!exists(obj, inherits = FALSE)) {
    stop("03_returns.R: `", obj, "` missing. Run 00_run_all.R, not this script directly.")
  }
}
# (No set.seed here: the orchestrator seeds once; this step draws no RNG.)
#
# REAL-DATA METHODOLOGY TODOs (flagged in the domain review — the synthetic
# scaffold uses simplified proxies; upgrade these when live data is wired):
#   - BHAR benchmark: implement a Barber & Lyon (1997) size x book-to-market
#     MATCHED CONTROL FIRM (replaced on delisting) per firm, feeding bench_ret.
#     The current single `bench_ret` column is an index/portfolio proxy; if kept,
#     label it a reference-portfolio BHAR (Lyon-Barber-Tsai 1999) and note the
#     new-listing bias. Do NOT attribute an index-adjusted BHAR to Barber-Lyon.
#   - BHAR inference: do NOT report naive iid t-stats on the bhar cross-section
#     (hot-market clustering). Use LBT (1999) skewness-adjusted / bootstrapped
#     inference, or defer inference to the calendar-time alpha.
#   - Calendar-time: add a VALUE-WEIGHTED portfolio (Mitchell-Stafford 2000's
#     preferred spec; EW invites the small-firm-artifact critique), use FF3/FF5
#     (+UMD) factors from the factor library (not a cross-firm mean of bench_ret),
#     index by TRUE calendar month, fold the delisting return into the final
#     portfolio month, and use WLS-by-portfolio-size / robust SEs.

# ---- First-day underpricing -------------------------------------------------
# Offer prices are clean only for US (Ritter) and UK (Datastream UP@BDATE);
# Continental underpricing is out of scope for now, so its offer prices are
# absent and underpricing is NA by construction.
clean_offer <- ipo_sample$region %in% c("US", "UK")
underpricing <- data.frame(
  firm_id = ipo_sample$firm_id,
  region  = ipo_sample$region,
  ipo_year = ipo_sample$ipo_year,
  underpricing = NA_real_,
  stringsAsFactors = FALSE
)
underpricing$underpricing[clean_offer] <- compute_underpricing(
  first_close   = ipo_sample$first_close[clean_offer],
  offer_price   = ipo_sample$offer_price[clean_offer],
  market_return = ipo_sample$mkt_ret_first_day[clean_offer]
)

# ---- Long-run BHAR (36-month, delisting returns folded in) ------------------
# Per firm: fold the (Shumway-filled) delisting return into the buy-and-hold
# return, then subtract the benchmark buy-and-hold return over the same window.
ipo_sample$dlret_filled <- fill_delisting_return(
  dlret = ipo_sample$dlret, dlstcd = ipo_sample$dlstcd, exchcd = ipo_sample$exchcd
)

by_firm <- split(ipo_monthly, ipo_monthly$firm_id)
bhar_vec <- vapply(names(by_firm), function(fid) {
  m <- by_firm[[fid]]
  m <- m[order(m$month), , drop = FALSE]
  dlret <- ipo_sample$dlret_filled[match(fid, ipo_sample$firm_id)]
  # Compound firm and benchmark over the IDENTICAL window (Barber-Lyon 1997):
  # keep only months where both legs are observed (e.g. an Ince-Porter NA drops
  # the month from both, not just the firm). Then the delisting return is
  # applied once to the firm leg via fold_delisting_return().
  ok <- !is.na(m$ret) & !is.na(m$bench_ret)
  firm_bh  <- fold_delisting_return(m$ret[ok], dlret)      # firm BH + delisting, matched window
  bench_bh <- buy_and_hold_return(m$bench_ret[ok])         # same window (na.rm = FALSE default)
  firm_bh - bench_bh
}, numeric(1))

longrun <- data.frame(
  firm_id = names(by_firm),
  bhar    = unname(bhar_vec),
  stringsAsFactors = FALSE
)
longrun$region <- ipo_sample$region[match(longrun$firm_id, ipo_sample$firm_id)]
longrun$ipo_year <- ipo_sample$ipo_year[match(longrun$firm_id, ipo_sample$firm_id)]

# ---- Calendar-time portfolio alpha (Mitchell & Stafford 2000) ---------------
# Build an equal-weighted calendar-time portfolio in event-month space (the
# synthetic panel lacks true calendar dates; with real data, index by calendar
# month). Regress portfolio excess return on a single market factor here; extend
# to FF3/FF5 + momentum when factor data is loaded.
ct_alpha_region <- function(region_code) {
  m <- ipo_monthly[ipo_monthly$region == region_code & !is.na(ipo_monthly$ret), , drop = FALSE]
  if (nrow(m) < 12L) return(NULL)
  agg <- aggregate(cbind(ret, bench_ret, rf) ~ month, data = m, FUN = mean, na.rm = TRUE)
  port_excess <- agg$ret - agg$rf
  factors <- data.frame(mktrf = agg$bench_ret - agg$rf)
  res <- calendar_time_alpha(port_excess, factors)
  data.frame(region = region_code, alpha = res$alpha, se = res$se, t = res$t,
             n_months = nrow(agg), stringsAsFactors = FALSE)
}
ct_alpha <- do.call(rbind, lapply(levels(ipo_sample$region), ct_alpha_region))

# ---- Save -------------------------------------------------------------------
returns <- list(underpricing = underpricing, longrun = longrun, ct_alpha = ct_alpha)
saveRDS(returns, file.path(OUT_DIR, "returns.rds"))
message(sprintf("Computed returns: %d underpricing (US/UK), %d BHAR, %d calendar-time alphas.",
                sum(!is.na(underpricing$underpricing)), nrow(longrun),
                if (is.null(ct_alpha)) 0L else nrow(ct_alpha)))
