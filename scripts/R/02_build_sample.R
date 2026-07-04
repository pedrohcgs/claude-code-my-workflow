# =============================================================================
# 02_build_sample.R — Assemble the analysis sample from us_raw + eu_raw.
#
# Combines the regional inputs, applies the common screens/exclusions, cleans
# the monthly panel (Ince & Porter 2006 for the Datastream side), and emits:
#   - ipo_sample   : one row per IPO (firm-level)
#   - ipo_monthly  : cleaned firm-month panel
# Both are saved to OUT_DIR as RDS. Consumed by 03_returns.R.
# =============================================================================

for (obj in c("us_raw", "eu_raw", "OUT_DIR")) {
  if (!exists(obj, inherits = FALSE)) {
    stop("02_build_sample.R: `", obj, "` missing. Run 00_run_all.R, not this script directly.")
  }
}

# ---- Combine regions --------------------------------------------------------
firms   <- rbind(us_raw$firms, eu_raw$firms)
monthly <- rbind(us_raw$monthly, eu_raw$monthly)

# ---- Screens & exclusions (applied consistently across regions) -------------
# Common-equity / operating-firm screens live upstream in the loaders (CRSP
# SHRCD 10/11 & EXCHCD 1/2/3 for the US; Ince-Porter static classification for
# Datastream). Here we apply the cross-region analysis screens.
n0 <- nrow(firms)

# US penny-stock screen: offer price >= $5 (Ritter). Applied to US only; other
# venues use local-currency thresholds handled at load. Offer price must be > 0.
keep <- firms$offer_price > 0 &
  !(firms$region == "US" & firms$offer_price < 5)
firms <- firms[keep, , drop = FALSE]

# Restrict the panel to the surviving firms.
monthly <- monthly[monthly$firm_id %in% firms$firm_id, , drop = FALSE]

message(sprintf("Sample screens: %d -> %d IPOs (dropped %d).",
                n0, nrow(firms), n0 - nrow(firms)))

# ---- Clean the monthly panel (Ince & Porter 2006 dynamic reversal) ----------
# Order within firm, flag spurious reversals (exempting the IPO first month),
# set flagged returns to NA. Applied to all regions; it is a no-op on clean data.
monthly <- monthly[order(monthly$firm_id, monthly$month), , drop = FALSE]
split_idx <- split(seq_len(nrow(monthly)), monthly$firm_id)
flag <- logical(nrow(monthly))
for (idx in split_idx) {
  flag[idx] <- ince_porter_reversal(monthly$ret[idx], is_first = monthly$is_first[idx])
}
n_flagged <- sum(flag)
monthly$ret[flag] <- NA_real_
if (n_flagged > 0L) {
  message(sprintf("Ince-Porter reversal screen: set %d firm-month return(s) to NA.", n_flagged))
}

# ---- Region as an ordered, labelled factor for reporting --------------------
region_levels <- c("US", "UK", "FR", "DE", "IT", "NL")
firms$region   <- factor(firms$region, levels = region_levels)
monthly$region <- factor(monthly$region, levels = region_levels)

ipo_sample  <- firms
ipo_monthly <- monthly

saveRDS(ipo_sample,  file.path(OUT_DIR, "ipo_sample.rds"))
saveRDS(ipo_monthly, file.path(OUT_DIR, "ipo_monthly.rds"))
message("Wrote ipo_sample.rds (", nrow(ipo_sample), " IPOs) and ipo_monthly.rds (",
        nrow(ipo_monthly), " firm-months).")
