# =============================================================================
# 01_load_eu.R — Load the EU/UK IPO inputs (all via WRDS: Compustat Global +
# Worldscope + Datastream; Orbis optional/off).
#
# Produces `eu_raw` = list(firms, monthly) in the same schema as us_raw. Real
# WRDS pull when configured; synthetic fallback otherwise. No credentials in
# code; no raw licensed data written to a tracked path.
#
# Source roles (see the plan / decision record):
#   - Datastream : returns (RI), first-trade dating (P#S), UK offer price
#                  (UP at BDATE), dead-stock lists (survivorship).
#   - Compustat Global + Worldscope : ipodate, incorporation date, accounting.
#   - Orbis (BvD) : OPTIONAL robustness cross-check only (BvD-ID linking,
#                   incorporation) — OFF by default; not load-bearing here.
#
# WRDS library names for Datastream/Orbis vary by institution — set via env
# (DS_LIB, ORBIS_LIB) and validated at load, never hardcoded blindly.
# =============================================================================

if (!exists("PROJECT_SEED", inherits = FALSE)) {
  stop("01_load_eu.R: run via 00_run_all.R (PROJECT_SEED not set). ",
       "The orchestrator seeds the RNG once; this script must not re-seed.")
}

EU_REGIONS <- c("UK", "FR", "DE", "IT", "NL")
# Compustat Global country codes (ISO) for the target venues.
EU_LOC <- c(UK = "GBR", FR = "FRA", DE = "DEU", IT = "ITA", NL = "NLD")
H_MONTHS <- 36L
USE_ORBIS <- identical(Sys.getenv("IPO_USE_ORBIS", "0"), "1")  # OFF by default

use_synthetic <- identical(Sys.getenv("IPO_USE_SYNTHETIC", "0"), "1")
con <- if (use_synthetic) NULL else wrds_connect()

if (!is.null(con)) {
  # === Real pull (WRDS configured) ===========================================
  message("  [data] Loading EU/UK inputs from WRDS (Compustat Global + Worldscope + Datastream).")

  # --- 1. Listing universe + date (Compustat Global) -------------------------
  # g_company header carries ipodate + country (loc); g_secd is the daily
  # security file. Restrict to the target countries and sample window.
  loc_list <- paste(sprintf("'%s'", EU_LOC), collapse = ", ")
  cg_hdr <- wrds_query(con, sprintf("
    SELECT gvkey, iid, loc, ipodate, exchg FROM comp.g_company
    WHERE loc IN (%s) AND ipodate BETWEEN '%s-01-01' AND '%s-12-31'",
    loc_list, SAMPLE_START, SAMPLE_END))
  assert_fields(cg_hdr, c("gvkey", "loc", "ipodate"), "comp.g_company")

  # --- 2. Incorporation date + accounting (Worldscope) -----------------------
  # Field 18273 = DATE OF INCORPORATION (confirmed). The IPO/first-traded field
  # code was flagged UNVERIFIED by research — do NOT rely on it; use Compustat
  # ipodate + Datastream first-trade dating instead. assert_fields guards.
  ws <- wrds_query(con, "
    SELECT code AS ws_code, item6105 AS isin, item18273 AS incorp_date
    FROM tr_ws.wrds_ws_company")
  assert_fields(ws, c("ws_code", "incorp_date"), "Worldscope (tr_ws.wrds_ws_company)")

  # --- 3. Returns / first-trade / UK offer price (Datastream via WRDS) --------
  # Datastream library name varies by institution; set DS_LIB (browse WRDS to
  # confirm). Pull the total-return index RI (returns), unadjusted price UP
  # (UK offer price at BDATE), unpadded price P#S (first-trade dating), BDATE.
  # SURVIVORSHIP: the instrument list MUST union ACTIVE and DEAD constituents
  # per market/year (see the static-screen + live-union note below).
  ds_lib <- Sys.getenv("DS_LIB", unset = NA_character_)
  if (is.na(ds_lib) || !nzchar(ds_lib)) {
    DBI::dbDisconnect(con)
    stop("01_load_eu.R: set DS_LIB to your WRDS Datastream library name ",
         "(browse WRDS to find it) before the real EU pull. See data/README.md.")
  }
  # Structure of the pull (fill table/column names for your DS_LIB layout):
  #   ds <- wrds_query(con, sprintf("SELECT infocode, marketdate, ret_index AS ri,
  #                    unadj_price AS up, unpadded_price AS pns, base_date AS bdate
  #                    FROM %s.ds2primqtprc WHERE marketdate BETWEEN ...", ds_lib))
  #   assert_fields(ds, c("infocode","marketdate","ri"), paste0(ds_lib, " Datastream"))
  #
  # STATIC screens + live∪dead union + trailing-padding truncation happen HERE,
  # BEFORE the dynamic Ince-Porter reversal screen in 02_build_sample.R. Without
  # the live∪dead union the EU/UK long-run BHAR carries an upward survivorship
  # bias the US (Shumway) side removes — invalidating the cross-country comparison.

  # --- 4. Orbis (OPTIONAL, off by default) -----------------------------------
  if (USE_ORBIS) {
    orbis_lib <- Sys.getenv("ORBIS_LIB", unset = NA_character_)
    if (is.na(orbis_lib) || !nzchar(orbis_lib)) {
      warning("01_load_eu.R: IPO_USE_ORBIS=1 but ORBIS_LIB unset - skipping Orbis.", call. = FALSE)
    }
    # Optional cross-check only: BvD-ID linking + incorporation date. Not
    # load-bearing (returns from Datastream, ipodate from Compustat Global).
  }

  DBI::dbDisconnect(con)

  stop("01_load_eu.R: WRDS query layer wired; complete the R assembly of `eu_raw` ",
       "(Compustat-Global x Worldscope x Datastream link via ISIN/identifiers, ",
       "first-trade dating from first non-NA P#S, UK offer price from UP@BDATE, ",
       "live union dead lists, event-month panel) and validate on the first live ",
       "run. See the schema in this file's header and the plan.")
} else {
  # === Synthetic fallback ====================================================
  eu_raw <- synthesize_ipos(regions = EU_REGIONS, n_per_region = 30L, n_months = H_MONTHS)
  message("Loaded SYNTHETIC EU/UK IPO data: ", nrow(eu_raw$firms), " firms, ",
          nrow(eu_raw$monthly), " firm-months across ", paste(EU_REGIONS, collapse = "/"), ".")
}
