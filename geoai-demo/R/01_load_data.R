# 01_load_data.R — load and clean the Volve production history
#
# Input : a Volve production spreadsheet in  data/  (see data/README.md)
# Output: data/processed/volve_daily.rds    + .csv
#         data/processed/volve_monthly.rds  + .csv   <- main input for decline analysis
#
# Run from the project root:  source("R/01_load_data.R")

source("R/utils.R")
library(readxl)
check_wd()

# --- 1. locate the input file ---------------------------------------------

find_input <- function() {
  x <- list.files("data", pattern = "production.*\\.xlsx?$",
                  ignore.case = TRUE, recursive = TRUE, full.names = TRUE)
  if (length(x)) return(x[1])
  x <- list.files("data", pattern = "\\.xlsx?$", ignore.case = TRUE,
                  recursive = TRUE, full.names = TRUE)
  if (length(x)) return(x[1])
  x <- list.files("data", pattern = "\\.csv$", ignore.case = TRUE,
                  recursive = TRUE, full.names = TRUE)
  if (length(x)) return(x[1])
  NA_character_
}

infile <- find_input()
if (is.na(infile)) {
  stop(
    "\n\nNo Volve production file found in data/.\n",
    "  1. Create a free account at https://www.equinor.com/energy/volve-data-sharing\n",
    "  2. Download 'Volve production data.xlsx'  (the production-history spreadsheet,\n",
    "     a few MB - NOT the 40 GB bundle).\n",
    "  3. Put it in:  ", normalizePath(file.path(getwd(), "data"), mustWork = FALSE), "\n",
    "  4. Run again:  source(\"R/01_load_data.R\")\n\n"
  )
}
message("Input file : ", infile)

# --- 2. read it ----------------------------------------------------------

is_excel <- grepl("\\.xlsx?$", infile, ignore.case = TRUE)
if (is_excel) {
  sheets <- excel_sheets(infile)
  sheet  <- sheets[grepl("daily",   sheets, ignore.case = TRUE)][1]
  if (is.na(sheet)) sheet <- sheets[grepl("monthly", sheets, ignore.case = TRUE)][1]
  if (is.na(sheet)) sheet <- sheets[1]
  message("Sheets     : ", paste(sheets, collapse = " | "))
  message("Using sheet: ", sheet)
  raw <- read_excel(infile, sheet = sheet, guess_max = 100000)
} else {
  raw <- readr::read_csv(infile, show_col_types = FALSE, guess_max = 100000)
}
raw <- clean_names(raw)
message("Rows read  : ", nrow(raw))
message("Columns    : ", paste(names(raw), collapse = ", "))

# --- 3. map columns (tolerant of naming variants) ------------------------

col_date  <- pick_col(raw, c("dateprd", "date", "prod_date", "produced_date"), what = "date")
col_well  <- pick_col(raw, c("npd_well_bore_name", "well_bore_code", "wellbore",
                             "well_bore", "well_name", "well"), what = "well name")
col_oil   <- pick_col(raw, c("bore_oil_vol", "oil_vol", "oil_volume", "oil"), what = "oil volume")
col_gas   <- pick_col(raw, c("bore_gas_vol", "gas_vol", "gas_volume", "gas"),
                      required = FALSE, what = "gas volume")
col_wat   <- pick_col(raw, c("bore_wat_vol", "wat_vol", "water_vol", "water_volume", "water"),
                      required = FALSE, what = "water volume")
col_hrs   <- pick_col(raw, c("on_stream_hrs", "onstream_hrs", "hours_on_stream", "on_stream"),
                      required = FALSE, what = "on-stream hours")
col_kind  <- pick_col(raw, c("flow_kind", "flowkind"),   required = FALSE)
col_type  <- pick_col(raw, c("well_type", "welltype"),   required = FALSE)

dat <- tibble(
  well     = as.character(raw[[col_well]]),
  date     = parse_prod_date(raw[[col_date]]),
  oil_sm3  = as_num(raw[[col_oil]]),
  gas_sm3  = if (!is.na(col_gas)) as_num(raw[[col_gas]]) else NA_real_,
  wat_sm3  = if (!is.na(col_wat)) as_num(raw[[col_wat]]) else NA_real_,
  hrs_on   = if (!is.na(col_hrs)) as_num(raw[[col_hrs]]) else NA_real_,
  flow_kind = if (!is.na(col_kind)) as.character(raw[[col_kind]]) else NA_character_,
  well_type = if (!is.na(col_type)) as.character(raw[[col_type]]) else NA_character_
) |>
  filter(!is.na(well), !is.na(date))

# --- 4. keep oil producers only ----------------------------------------

n_before <- n_distinct(dat$well)
if (any(!is.na(dat$well_type))) {
  producers <- dat |>
    filter(str_to_upper(str_trim(well_type)) %in% c("OP", "OB", "PRODUCER", "PRODUCTION"))
} else if (any(!is.na(dat$flow_kind))) {
  producers <- dat |> filter(str_detect(str_to_lower(flow_kind %||% ""), "prod"))
} else {
  keep <- dat |> group_by(well) |> summarise(o = sum(oil_sm3, na.rm = TRUE)) |>
    filter(o > 0) |> pull(well)
  producers <- dat |> filter(well %in% keep)
}
if (nrow(producers) == 0) {
  warning("No producers identified by well_type/flow_kind; falling back to oil>0.")
  keep <- dat |> group_by(well) |> summarise(o = sum(oil_sm3, na.rm = TRUE)) |>
    filter(o > 0) |> pull(well)
  producers <- dat |> filter(well %in% keep)
}
message(sprintf("Wells      : %d total -> %d oil producers kept", n_before, n_distinct(producers$well)))
message("Producers  : ", paste(sort(unique(producers$well)), collapse = ", "))

# --- 5. daily table ----------------------------------------------------

daily <- producers |>
  group_by(well, date) |>
  summarise(
    oil_sm3 = sum(oil_sm3, na.rm = TRUE),
    gas_sm3 = sum(gas_sm3, na.rm = TRUE),
    wat_sm3 = sum(wat_sm3, na.rm = TRUE),
    hrs_on  = sum(hrs_on,  na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    oil_bbl      = oil_sm3 * SM3_TO_BBL,
    oil_rate_bopd = oil_bbl / pmax(hrs_on / 24, 1e-6),   # rate while flowing
    wct          = ifelse((wat_sm3 + oil_sm3) > 0, wat_sm3 / (wat_sm3 + oil_sm3), NA_real_),
    gor          = ifelse(oil_sm3 > 0, gas_sm3 / oil_sm3, NA_real_)
  ) |>
  arrange(well, date)

# --- 6. monthly table (main input for decline curve analysis) ---------

monthly <- daily |>
  mutate(month = floor_date(date, "month")) |>
  group_by(well, month) |>
  summarise(
    oil_sm3        = sum(oil_sm3, na.rm = TRUE),
    gas_sm3        = sum(gas_sm3, na.rm = TRUE),
    wat_sm3        = sum(wat_sm3, na.rm = TRUE),
    days_on_stream = sum(hrs_on, na.rm = TRUE) / 24,
    days_reported  = n(),
    .groups = "drop"
  ) |>
  mutate(
    cal_days      = days_in_month(month),
    oil_bbl       = oil_sm3 * SM3_TO_BBL,
    oil_rate_bopd = oil_bbl / cal_days,                       # calendar-day rate
    oil_rate_on   = ifelse(days_on_stream > 0,
                           oil_bbl / days_on_stream, NA_real_),# rate while flowing
    wct           = ifelse((wat_sm3 + oil_sm3) > 0,
                           wat_sm3 / (wat_sm3 + oil_sm3), NA_real_),
    gor           = ifelse(oil_sm3 > 0, gas_sm3 / oil_sm3, NA_real_)
  ) |>
  arrange(well, month) |>
  group_by(well) |>
  mutate(cum_oil_bbl = cumsum(replace_na(oil_bbl, 0))) |>
  ungroup()

# --- 7. write outputs ------------------------------------------------

ensure_dir("data/processed")
saveRDS(daily,   "data/processed/volve_daily.rds")
saveRDS(monthly, "data/processed/volve_monthly.rds")
write_csv(daily,   "data/processed/volve_daily.csv")
write_csv(monthly, "data/processed/volve_monthly.csv")

message("\nWrote:")
message("  data/processed/volve_daily.rds   (", nrow(daily),   " rows)")
message("  data/processed/volve_monthly.rds (", nrow(monthly), " rows)")
message("  + matching .csv copies")
message("\nDate range : ", format(min(monthly$month)), " to ", format(max(monthly$month)))
message("01_load_data.R done.")
