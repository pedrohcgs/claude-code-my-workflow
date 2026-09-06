# ingest.R — turn a raw production file into the tidy monthly/daily tables the
# rest of the app expects. Used by 01_load_data.R (batch) and by the app's
# "upload your own data" path.
#
#   ingest_production(path) -> list(daily = <tbl>, monthly = <tbl>, info = <chr>)
#
# Accepts .xlsx/.xls/.csv. Tolerant of column naming. Handles oil given as a
# volume (Sm3 or bbl) or as a rate (bopd); daily- or monthly-frequency rows.

source("R/utils.R")

ingest_production <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext %in% c("xlsx", "xls")) {
    if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' is required for Excel files.")
    sheets <- readxl::excel_sheets(path)
    sheet  <- sheets[grepl("daily", sheets, ignore.case = TRUE)][1]
    if (is.na(sheet)) sheet <- sheets[grepl("month|prod", sheets, ignore.case = TRUE)][1]
    if (is.na(sheet)) sheet <- sheets[1]
    raw <- readxl::read_excel(path, sheet = sheet, guess_max = 100000)
  } else if (ext %in% c("csv", "txt", "tsv")) {
    raw <- readr::read_csv(path, show_col_types = FALSE, guess_max = 100000)
  } else {
    stop("Unsupported file type: .", ext, " — use CSV or Excel.")
  }
  raw <- clean_names(raw)

  col_date <- pick_col(raw, c("dateprd", "date", "prod_date", "produced_date",
                              "month", "period", "prod_month", "yyyymm"), what = "date")
  col_well <- pick_col(raw, c("npd_well_bore_name", "well_bore_code", "wellbore",
                              "well_bore", "well_name", "well", "wellname",
                              "well_id", "name", "borehole"),
                       required = FALSE, what = "well")
  col_oil  <- pick_col(raw, c("bore_oil_vol", "oil_vol", "oil_volume", "oil_rate",
                              "oil_bopd", "oil_bbl", "oil_sm3", "oil_stb", "oil_prod",
                              "oil", "qo"), what = "oil volume or rate")
  col_gas  <- pick_col(raw, c("bore_gas_vol", "gas_vol", "gas_volume", "gas_rate", "gas"),
                       required = FALSE)
  col_wat  <- pick_col(raw, c("bore_wat_vol", "wat_vol", "water_vol", "water_volume",
                              "water_rate", "water", "wat"), required = FALSE)
  col_hrs  <- pick_col(raw, c("on_stream_hrs", "onstream_hrs", "hours_on_stream",
                              "on_stream", "uptime_hrs", "hrs"), required = FALSE)
  col_kind <- pick_col(raw, c("flow_kind", "flowkind"), required = FALSE)
  col_type <- pick_col(raw, c("well_type", "welltype", "type"), required = FALSE)

  is_rate <- grepl("rate|bopd|bpd|per_day|_d$|qo", col_oil)
  is_bbl  <- grepl("bbl|barrel|stb|bopd|bpd", col_oil)
  oil_k   <- if (is_bbl) 1 else SM3_TO_BBL

  dat <- tibble::tibble(
    well      = if (!is.na(col_well)) as.character(raw[[col_well]]) else "Well 1",
    date      = parse_prod_date(raw[[col_date]]),
    oil_in    = as_num(raw[[col_oil]]),
    gas_in    = if (!is.na(col_gas)) as_num(raw[[col_gas]]) else NA_real_,
    wat_in    = if (!is.na(col_wat)) as_num(raw[[col_wat]]) else NA_real_,
    hrs_on    = if (!is.na(col_hrs)) as_num(raw[[col_hrs]]) else NA_real_,
    flow_kind = if (!is.na(col_kind)) as.character(raw[[col_kind]]) else NA_character_,
    well_type = if (!is.na(col_type)) as.character(raw[[col_type]]) else NA_character_
  ) |>
    dplyr::filter(!is.na(well), !is.na(date), is.finite(oil_in))
  if (nrow(dat) == 0)
    stop("No usable rows found — check that the file has a readable date column and an oil column.")

  # --- period length per well (days between consecutive rows) ---
  dat <- dat |>
    dplyr::arrange(well, date) |>
    dplyr::group_by(well) |>
    dplyr::mutate(gap = as.numeric(date - dplyr::lag(date))) |>
    dplyr::ungroup()
  med_gap <- stats::median(dat$gap, na.rm = TRUE)
  if (!is.finite(med_gap) || med_gap <= 0) med_gap <- 30
  freq <- if (med_gap <= 3) "daily" else if (med_gap <= 45) "monthly" else "irregular"

  # --- oil as a volume in barrels for each row ---
  dat <- dat |>
    dplyr::mutate(
      period_days = dplyr::coalesce(gap, med_gap),
      oil_bbl_row = if (is_rate) {
        oil_in * oil_k * dplyr::if_else(!is.na(hrs_on) & hrs_on > 0, hrs_on / 24, period_days)
      } else {
        oil_in * oil_k
      },
      gas_row = if (is_rate) gas_in * period_days else gas_in,
      wat_row = if (is_rate) wat_in * oil_k * period_days else wat_in * oil_k,
      day     = lubridate::floor_date(date, "day")
    )

  # --- keep oil producers ---
  if (any(!is.na(dat$well_type))) {
    dat <- dplyr::filter(dat, stringr::str_to_upper(stringr::str_trim(well_type)) %in%
                           c("OP", "OB", "PRODUCER", "PRODUCTION") | is.na(well_type))
  } else if (any(!is.na(dat$flow_kind))) {
    dat <- dplyr::filter(dat, stringr::str_detect(stringr::str_to_lower(dplyr::coalesce(flow_kind, "")),
                                                  "prod") | is.na(flow_kind))
  }
  keep <- dat |> dplyr::group_by(well) |>
    dplyr::summarise(o = sum(oil_bbl_row, na.rm = TRUE), .groups = "drop") |>
    dplyr::filter(o > 0) |> dplyr::pull(well)
  dat <- dplyr::filter(dat, well %in% keep)
  if (nrow(dat) == 0) stop("No oil-producing wells found in the file.")

  # --- daily table ---
  daily <- dat |>
    dplyr::group_by(well, date = day) |>
    dplyr::summarise(
      oil_bbl = sum(oil_bbl_row, na.rm = TRUE),
      gas     = sum(gas_row, na.rm = TRUE),
      wat_bbl = sum(wat_row, na.rm = TRUE),
      hrs_on  = sum(hrs_on, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      oil_rate_bopd = oil_bbl / pmax(hrs_on / 24, 1e-6),
      wct = dplyr::if_else((wat_bbl + oil_bbl) > 0, wat_bbl / (wat_bbl + oil_bbl), NA_real_)
    ) |>
    dplyr::arrange(well, date)

  # --- monthly table (engine input) ---
  monthly <- dat |>
    dplyr::mutate(month = lubridate::floor_date(date, "month")) |>
    dplyr::group_by(well, month) |>
    dplyr::summarise(
      oil_bbl        = sum(oil_bbl_row, na.rm = TRUE),
      gas            = sum(gas_row, na.rm = TRUE),
      wat_bbl        = sum(wat_row, na.rm = TRUE),
      days_on_stream = sum(hrs_on, na.rm = TRUE) / 24,
      days_reported  = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      cal_days      = lubridate::days_in_month(month),
      oil_rate_bopd = oil_bbl / cal_days,
      oil_rate_on   = dplyr::if_else(days_on_stream > 0, oil_bbl / days_on_stream, NA_real_),
      wct           = dplyr::if_else((wat_bbl + oil_bbl) > 0,
                                     wat_bbl / (wat_bbl + oil_bbl), NA_real_),
      gor           = dplyr::if_else(oil_bbl > 0, gas / oil_bbl, NA_real_)
    ) |>
    dplyr::arrange(well, month) |>
    dplyr::group_by(well) |>
    dplyr::mutate(cum_oil_bbl = cumsum(tidyr::replace_na(oil_bbl, 0))) |>
    dplyr::ungroup()

  info <- sprintf("%d wells, %s to %s, %s rows (%s oil %s)",
                  dplyr::n_distinct(monthly$well),
                  format(min(monthly$month)), format(max(monthly$month)),
                  freq, if (is_bbl) "bbl" else "Sm3",
                  if (is_rate) "rate" else "volume")

  list(daily = daily, monthly = monthly, info = info)
}
