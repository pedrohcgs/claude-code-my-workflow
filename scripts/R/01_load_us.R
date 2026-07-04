# =============================================================================
# 01_load_us.R — Load the US IPO inputs (CRSP + Compustat NA + Ritter).
#
# Produces `us_raw` = list(firms, monthly) in the common schema consumed by
# 02_build_sample.R. Real WRDS pull when configured; synthetic fallback
# otherwise. No credentials in code; no raw licensed data written to a tracked
# path. Set IPO_USE_SYNTHETIC=1 to force the synthetic path.
#
# Schema of the objects produced (both paths):
#   firms:   firm_id, region, ipo_date, ipo_year, exchcd, offer_price,
#            first_close, mkt_ret_first_day, dlstcd, dlret
#   monthly: firm_id, region, month (event-month 1..H), ret, bench_ret, rf, is_first
# =============================================================================

if (!exists("PROJECT_SEED", inherits = FALSE)) {
  stop("01_load_us.R: run via 00_run_all.R (PROJECT_SEED not set). ",
       "The orchestrator seeds the RNG once; this script must not re-seed.")
}

use_synthetic <- identical(Sys.getenv("IPO_USE_SYNTHETIC", "0"), "1")
con <- if (use_synthetic) NULL else wrds_connect()

H_MONTHS <- 36L  # long-run horizon (event months post first trading month)

if (!is.null(con)) {
  # === Real pull (WRDS configured) ===========================================
  message("  [data] Loading US inputs from WRDS (CRSP + Compustat NA + Ritter).")

  # --- 1. Common-stock universe + first trading date (CRSP) ------------------
  # SHRCD 10/11 = US common stock; EXCHCD 1/2/3 = NYSE/AMEX/Nasdaq. The first
  # date a permno appears in the daily stock file is the IPO first-trade proxy.
  crsp_first <- wrds_query(con, sprintf("
    SELECT d.permno, MIN(d.date) AS first_dt
    FROM crsp.dsf d
    INNER JOIN crsp.dsenames n
      ON d.permno = n.permno AND d.date BETWEEN n.namedt AND n.nameendt
    WHERE n.shrcd IN (10, 11) AND n.exchcd IN (1, 2, 3)
      AND d.date BETWEEN '%s-01-01' AND '%s-12-31'
    GROUP BY d.permno", SAMPLE_START, SAMPLE_END))
  assert_fields(crsp_first, c("permno", "first_dt"), "crsp.dsf")

  # First-day close (|PRC|; CRSP stores bid/ask midpoints as negative) and the
  # exchange on the first day.
  crsp_firstday <- wrds_query(con, "
    SELECT d.permno, ABS(d.prc) AS first_close, n.exchcd
    FROM crsp.dsf d
    INNER JOIN crsp.dsenames n
      ON d.permno = n.permno AND d.date BETWEEN n.namedt AND n.nameendt
    INNER JOIN (SELECT permno, MIN(date) AS first_dt FROM crsp.dsf GROUP BY permno) f
      ON d.permno = f.permno AND d.date = f.first_dt")

  # --- 2. Monthly returns (event window) + market/rf benchmarks --------------
  # crsp.msf for firm returns; crsp.msi (vwretd) as the market benchmark; the
  # Fama-French risk-free from ff.factors_monthly. Event-month alignment done in R.
  crsp_month <- wrds_query(con, sprintf("
    SELECT permno, date, ret FROM crsp.msf
    WHERE date BETWEEN '%s-01-01' AND '%s-12-31' AND ret IS NOT NULL", SAMPLE_START, SAMPLE_END))
  mkt_month  <- wrds_query(con, "SELECT date, vwretd FROM crsp.msi")
  ff_month   <- wrds_query(con, "SELECT date, rf FROM ff.factors_monthly")

  # --- 3. Delisting returns (crsp.msedelist) ---------------------------------
  crsp_delist <- wrds_query(con, "SELECT permno, dlstdt, dlret, dlstcd FROM crsp.msedelist")

  # --- 4. Offer prices from Ritter's public files ----------------------------
  # Ritter's firm-level files live in data/raw/ritter/ (gitignored). The link to
  # CRSP permno is by CUSIP/ticker+date and is data-specific — implement the
  # merge for the exact file you downloaded; assert the offer_price column.
  ritter_path <- here::here("data", "raw", "ritter", "ipo_offer_prices.csv")
  if (!file.exists(ritter_path)) {
    DBI::dbDisconnect(con)
    stop("01_load_us.R: Ritter offer-price file not found at ", ritter_path,
         ".\nDownload from site.warrington.ufl.edu/ritter/ipo-data/ into ",
         "data/raw/ritter/ and provide a permno<->offer_price crosswalk. ",
         "See data/README.md.")
  }
  ritter <- utils::read.csv(ritter_path, stringsAsFactors = FALSE)
  assert_fields(ritter, c("permno", "offer_price", "ipo_date"), "Ritter file")

  DBI::dbDisconnect(con)

  # --- 5. Assemble firms + event-time monthly panel (in R) -------------------
  # NOTE: this assembly (event-month alignment of crsp_month to first_dt,
  # benchmark merge, delisting fold) is deterministic R; verify counts on the
  # first real run. Left as a documented TODO to keep the query layer reviewable
  # without a live connection:
  stop("01_load_us.R: WRDS queries wired; complete the R assembly of `us_raw` ",
       "(event-month alignment + Ritter offer-price merge + benchmark join) and ",
       "validate row counts on the first live run. See the schema in this file's header.")
} else {
  # === Synthetic fallback ====================================================
  us_raw <- synthesize_ipos(regions = "US", n_per_region = 60L, n_months = H_MONTHS)
  message("Loaded SYNTHETIC US IPO data: ", nrow(us_raw$firms), " firms, ",
          nrow(us_raw$monthly), " firm-months.")
}
