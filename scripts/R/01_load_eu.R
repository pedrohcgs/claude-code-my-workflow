# =============================================================================
# 01_load_eu.R — Load the EU/UK IPO inputs (all via WRDS: Datastream +
# Compustat Global + Worldscope; Orbis optional/off).
#
# Produces `eu_raw` = list(firms, monthly) in the same schema as us_raw. Real
# WRDS pull when configured; synthetic fallback otherwise. No credentials in
# code; no raw licensed data written to a tracked path.
#
# WRDS schema/field names below were CONFIRMED against the live data dictionary
# on 2026-07-04 (see data/README.md "Confirmed WRDS schema" and the discovery
# scripts in explorations/). Datastream = tr_ds_equities; Orbis =
# bvd_orbis_{large,medium,small}. Overridable via env for other institutions.
#
# Source roles (see the plan / decision record):
#   - Datastream : returns (RI/ret), first-trade dating (first non-NA daily
#                  price), UK offer price (unadjusted close at first trade),
#                  dead-stock lists (survivorship via statuscode A/D/S union).
#   - Compustat Global + Worldscope : ipodate, incorporation date, accounting.
#   - Orbis (BvD) : OPTIONAL robustness cross-check only (BvD-ID/ISIN linking,
#                   incorporation + ipo_date) — OFF by default; not load-bearing.
# =============================================================================

if (!exists("PROJECT_SEED", inherits = FALSE)) {
  stop("01_load_eu.R: run via 00_run_all.R (PROJECT_SEED not set). ",
       "The orchestrator seeds the RNG once; this script must not re-seed.")
}

EU_REGIONS <- c("UK", "FR", "DE", "IT", "NL")
# Datastream/Compustat country codes. Datastream `cmpyctrycode` is ISO-2 with
# UK == 'GB' (confirmed); Compustat Global `loc` is ISO-3.
EU_ISO2 <- c(UK = "GB", FR = "FR", DE = "DE", IT = "IT", NL = "NL")
EU_ISO3 <- c(UK = "GBR", FR = "FRA", DE = "DEU", IT = "ITA", NL = "NLD")
H_MONTHS <- 36L
USE_ORBIS <- identical(Sys.getenv("IPO_USE_ORBIS", "0"), "1")  # OFF by default

# WRDS schema names (this institution's confirmed layout; override if yours
# differs). These are FIXED schemas, not the old per-institution DS_LIB guess.
DS_SCHEMA    <- Sys.getenv("IPO_DS_SCHEMA", "tr_ds_equities")
ORBIS_TIERS  <- strsplit(Sys.getenv("IPO_ORBIS_TIERS",
                 "bvd_orbis_large,bvd_orbis_medium,bvd_orbis_small"), ",")[[1]]
CG_SCHEMA    <- Sys.getenv("IPO_CG_SCHEMA", "comp")     # Compustat Global
WS_SCHEMA    <- Sys.getenv("IPO_WS_SCHEMA", "tr_ws")    # Worldscope

use_synthetic <- identical(Sys.getenv("IPO_USE_SYNTHETIC", "0"), "1")
con <- if (use_synthetic) NULL else wrds_connect()

if (!is.null(con)) {
  # === Real pull (WRDS configured) ===========================================
  message("  [data] Loading EU/UK inputs from WRDS (Datastream + Compustat Global + Worldscope).")
  iso2_list <- paste(sprintf("'%s'", EU_ISO2), collapse = ", ")
  iso3_list <- paste(sprintf("'%s'", EU_ISO3), collapse = ", ")

  # --- 1. Datastream security master -----------------------------------------
  # Target-country EQUITIES only (typecode 'EQ' excludes ADR/PREF/GDR/ETF/INVT),
  # PRIMARY quote only (isprimqt = 1, dedupes multi-venue listings). ALL status
  # codes (A active / D dead / S suspended) are kept — the live∪dead union is
  # what removes the survivorship bias the US (Shumway) side also removes.
  # NOTE: wrds_ds_names_full carries name-history rows, so >1 row per infocode;
  # the assembly dedupes to one master row per infocode (latest segment).
  ds_master <- wrds_query(con, sprintf("
    SELECT infocode, dssecname, cmpyctrycode, isin, primqtsedol, ticker,
           typecode, statuscode, startdate, enddate, delistdate
    FROM %s.wrds_ds_names_full
    WHERE cmpyctrycode IN (%s) AND typecode = 'EQ' AND isprimqt = 1",
    DS_SCHEMA, iso2_list))
  assert_fields(ds_master, c("infocode", "cmpyctrycode", "isin", "statuscode"),
                paste0(DS_SCHEMA, ".wrds_ds_names_full"))

  # --- 2. Datastream daily returns / prices (the returns backbone) ------------
  # wrds_ds2dsf is the consolidated WRDS Datastream daily stock file (confirmed
  # coverage 1964->present, so 1995 is fully covered). `ri` = total-return index
  # (dividends reinvested) -> long-run BHAR; `ret` = daily total return (LOCAL
  # currency); `close` = UNADJUSTED price (UK offer-price proxy at first trade —
  # use `close`, NOT `adjclose`, which is split-adjusted). Restricted to the
  # master infocodes via join so we never scan the full file.
  ds_daily <- wrds_query(con, sprintf("
    SELECT d.infocode, d.marketdate, d.ri, d.ret, d.close, d.adjclose,
           d.numshrs, d.mktcap, d.currency, d.statuscode
    FROM %s.wrds_ds2dsf d
    INNER JOIN (
      SELECT DISTINCT infocode FROM %s.wrds_ds_names_full
      WHERE cmpyctrycode IN (%s) AND typecode = 'EQ' AND isprimqt = 1
    ) m ON d.infocode = m.infocode
    WHERE d.marketdate BETWEEN '%s-01-01' AND '%s-12-31'
      AND d.ri IS NOT NULL",
    DS_SCHEMA, DS_SCHEMA, iso2_list, SAMPLE_START, SAMPLE_END))
  assert_fields(ds_daily, c("infocode", "marketdate", "ri", "ret", "close"),
                paste0(DS_SCHEMA, ".wrds_ds2dsf"))

  # --- 3. Listing date (Compustat Global) ------------------------------------
  # g_company header carries ipodate + country (loc, ISO-3). Used to CROSS-CHECK
  # the Datastream first-trade date (never trust names_full.startdate: it clusters
  # at the DS2 extract start, not the true listing date).
  cg_hdr <- wrds_query(con, sprintf("
    SELECT gvkey, iid, loc, ipodate, exchg FROM %s.g_company
    WHERE loc IN (%s) AND ipodate BETWEEN '%s-01-01' AND '%s-12-31'",
    CG_SCHEMA, iso3_list, SAMPLE_START, SAMPLE_END))
  assert_fields(cg_hdr, c("gvkey", "loc", "ipodate"),
                paste0(CG_SCHEMA, ".g_company"))

  # --- 4. Incorporation date + accounting (Worldscope) -----------------------
  # Field 18273 = DATE OF INCORPORATION (confirmed). item6105 = ISIN, the link
  # key to Datastream/Compustat. The IPO/first-traded Worldscope code was flagged
  # UNVERIFIED by research — do NOT rely on it; first-trade comes from Datastream,
  # ipodate from Compustat Global. assert_fields guards the columns we do use.
  ws <- wrds_query(con, sprintf("
    SELECT code AS ws_code, item6105 AS isin, item18273 AS incorp_date
    FROM %s.wrds_ws_company", WS_SCHEMA))
  assert_fields(ws, c("ws_code", "incorp_date"),
                paste0(WS_SCHEMA, ".wrds_ws_company (Worldscope)"))

  # --- 5. Orbis (OPTIONAL cross-check, off by default) -----------------------
  # ISIN -> BvD-ID linkage (ob_identifiers) + incorporation/IPO/delist dates
  # (ob_legal_info), unioned across the large/medium/small tiers. Confirmed:
  # ob_legal_info_l has real dateinc + ipo_date + delisted_date; ob_identifiers_l
  # has sd_isin. NOT load-bearing (returns from Datastream, ipodate from CG).
  orbis <- NULL
  if (USE_ORBIS) {
    orbis_sql <- paste(vapply(ORBIS_TIERS, function(tier) sprintf("
      SELECT id.sd_isin AS isin, id.bvdid, li.dateinc, li.ipo_date,
             li.delisted_date, li.listed, li.mainexch, '%s' AS orbis_tier
      FROM %s.ob_identifiers_%s id
      INNER JOIN %s.ob_legal_info_%s li ON id.bvdid = li.bvdid
      WHERE id.sd_isin IS NOT NULL",
      tier, tier, sub("^bvd_orbis_", "", tier), tier,
      sub("^bvd_orbis_", "", tier)), character(1)), collapse = "\nUNION ALL\n")
    orbis <- wrds_query(con, orbis_sql)
    assert_fields(orbis, c("isin", "bvdid", "dateinc"), "Orbis (bvd_orbis_*)")
  }

  DBI::dbDisconnect(con)

  # --- 6. Assemble firms + event-time monthly panel (in R) -------------------
  # Deterministic R assembly (no randomness). Steps, all with the REAL columns
  # pulled above — validate row counts on the first full run:
  #   (a) DS master: dedupe wrds_ds_names_full to one row per infocode (latest
  #       name-history segment); map cmpyctrycode -> region via EU_ISO2.
  #   (b) First-trade date = MIN(marketdate) per infocode in ds_daily (first
  #       non-NA ri). UK offer-price proxy = `close` on that first-trade date.
  #   (c) IPO screen: keep infocodes whose first-trade year is in [SAMPLE_START,
  #       SAMPLE_END]; cross-check against Compustat-Global ipodate (join by ISIN
  #       via Worldscope item6105) and (if USE_ORBIS) Orbis ipo_date — flag
  #       disagreements > ~30 days rather than silently trust one source.
  #   (d) Monthly returns: compound daily `ret` to calendar months per infocode
  #       (or month-end ri[t]/ri[t-1] - 1), then align to event month 1..H_MONTHS
  #       from the first-trade month. Returns are LOCAL currency (`ret`).
  #   (e) Benchmark (bench_ret): per-venue local index total return, same event
  #       months (UK FTSE All-Share, FR SBF250, DE CDAX, IT MIB, NL AEX; source
  #       ds2equityindex / wrds_ds_indexmerged — index infocodes TBD, one decision
  #       to confirm). rf: local risk-free or 0 for BHAR (calendar-time uses FF).
  #   (f) Ince-Porter dynamic screens + trailing-padding truncation happen in
  #       02_build_sample.R (which sees both us_raw and eu_raw), NOT here.
  #   (g) Emit firms (firm_id=paste0('DS',infocode), region, ipo_date=first-trade,
  #       ipo_year, exchcd=NA, offer_price=UK-only close-proxy else NA,
  #       first_close, mkt_ret_first_day, dlstcd=NA/status, dlret=NA) and monthly
  #       (firm_id, region, month, ret, bench_ret, rf, is_first) — us_raw schema.
  stop("01_load_eu.R: WRDS queries wired + live-verified (field names confirmed ",
       "2026-07-04). Complete the deterministic R assembly of `eu_raw` per steps ",
       "(a)-(g) above and validate counts on the first full run. Two decisions to ",
       "confirm with the author: EU benchmark index infocodes, and the ISIN link ",
       "policy across DS/CG/WS/Orbis. See data/README.md and the plan.")
} else {
  # === Synthetic fallback ====================================================
  eu_raw <- synthesize_ipos(regions = EU_REGIONS, n_per_region = 30L, n_months = H_MONTHS)
  message("Loaded SYNTHETIC EU/UK IPO data: ", nrow(eu_raw$firms), " firms, ",
          nrow(eu_raw$monthly), " firm-months across ", paste(EU_REGIONS, collapse = "/"), ".")
}
