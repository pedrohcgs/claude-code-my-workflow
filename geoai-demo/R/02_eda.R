# 02_eda.R — exploratory data analysis + data-quality check for the Volve producers
#
# Input : data/processed/volve_monthly.rds  (from 01_load_data.R)
# Output: outputs/eda/well_summary.csv
#         outputs/eda/field_oil_rate.png
#         outputs/eda/well_decline_smallmultiples.png
#         outputs/eda/data_quality_tile.png
#         outputs/eda/well_watercut.png
#         outputs/eda/EDA_SUMMARY.md   <- readable one-pager
#
# Run from the project root:  source("R/02_eda.R")

source("R/utils.R")
check_wd()

mfile <- "data/processed/volve_monthly.rds"
if (!file.exists(mfile)) stop("Missing ", mfile, " - run source(\"R/01_load_data.R\") first.")
monthly <- readRDS(mfile)
ensure_dir("outputs/eda")

# --- 1. per-well summary ------------------------------------------------

fmt0  <- function(x) formatC(round(x), format = "f", big.mark = ",", digits = 0)
fmt1  <- function(x) formatC(x, format = "f", digits = 1)

well_summary <- monthly |>
  group_by(well) |>
  arrange(month, .by_group = TRUE) |>
  summarise(
    first_month      = min(month),
    last_month       = max(month),
    span_months      = as.integer(round(interval(min(month), max(month)) / months(1))) + 1L,
    producing_months = sum(oil_bbl > 0, na.rm = TRUE),
    gap_months       = span_months - producing_months,
    total_oil_mbbl   = sum(oil_bbl, na.rm = TRUE) / 1e6,
    peak_bopd        = max(oil_rate_bopd, na.rm = TRUE),
    peak_month       = month[which.max(oil_rate_bopd)],
    last_bopd        = oil_rate_bopd[which.max(month)],
    avg_wct_last6    = mean(tail(wct[oil_bbl > 0], 6), na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(decline_from_peak_pct = 100 * (1 - last_bopd / peak_bopd)) |>
  arrange(desc(total_oil_mbbl))

write_csv(well_summary, "outputs/eda/well_summary.csv")

# --- 2. field-level numbers -----------------------------------------

field <- tibble::tibble(
  metric = c("Producing wells", "History start", "History end",
             "Total oil produced (MMbbl)", "Peak field oil rate (bopd)",
             "Months of record", "Total well-months with a data gap"),
  value = c(
    as.character(n_distinct(monthly$well)),
    format(min(monthly$month)),
    format(max(monthly$month)),
    fmt1(sum(monthly$oil_bbl, na.rm = TRUE) / 1e6),
    fmt0(max(
      monthly |> group_by(month) |> summarise(r = sum(oil_rate_bopd, na.rm = TRUE)) |> pull(r)
    )),
    as.character(as.integer(round(interval(min(monthly$month), max(monthly$month)) / months(1))) + 1L),
    as.character(sum(well_summary$gap_months))
  )
)

# --- 3. plots -------------------------------------------------------

pal_theme <- theme_geoai()

# 3a. field oil rate, stacked by well
p_field <- monthly |>
  ggplot(aes(month, oil_rate_bopd, fill = well)) +
  geom_area(position = "stack", alpha = 0.9) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Volve field - monthly oil rate by well",
       x = NULL, y = "Oil rate (bopd, calendar-day)", fill = NULL) +
  pal_theme
ggsave("outputs/eda/field_oil_rate.png", p_field, width = 10, height = 5.5, dpi = 150)

# 3b. per-well decline, log y - the shape decline-curve analysis will fit
p_decline <- monthly |>
  filter(oil_rate_bopd > 0) |>
  ggplot(aes(month, oil_rate_bopd)) +
  geom_line(colour = "grey40") +
  geom_point(size = 0.7, colour = "#1b5e9c") +
  scale_y_log10(labels = scales::comma) +
  facet_wrap(~ well, scales = "free_y") +
  labs(title = "Per-well oil rate (log scale) - input to decline-curve fitting",
       x = NULL, y = "Oil rate (bopd, log10)") +
  pal_theme
ggsave("outputs/eda/well_decline_smallmultiples.png", p_decline, width = 11, height = 6.5, dpi = 150)

# 3c. data-quality tile: producing / idle / no record, per well-month
grid <- tidyr::expand_grid(
  well  = sort(unique(monthly$well)),
  month = seq(min(monthly$month), max(monthly$month), by = "month")
)
qtile <- grid |>
  left_join(monthly |> select(well, month, oil_bbl), by = c("well", "month")) |>
  mutate(status = case_when(
    is.na(oil_bbl)  ~ "no record",
    oil_bbl <= 0    ~ "idle (zero)",
    TRUE            ~ "producing"
  ))
p_qual <- qtile |>
  ggplot(aes(month, well, fill = status)) +
  geom_tile(colour = "white", linewidth = 0.2) +
  scale_fill_manual(values = c("producing" = "#2e7d32",
                               "idle (zero)" = "#f9a825",
                               "no record"  = "#e0e0e0")) +
  labs(title = "Data-quality map - gaps and shut-in periods",
       x = NULL, y = NULL, fill = NULL) +
  pal_theme
ggsave("outputs/eda/data_quality_tile.png", p_qual, width = 10, height = 4.5, dpi = 150)

# 3d. water cut over time (context for decline / workovers)
p_wct <- monthly |>
  filter(oil_bbl > 0, !is.na(wct)) |>
  ggplot(aes(month, wct)) +
  geom_line(colour = "#1b5e9c") +
  scale_y_continuous(labels = scales::percent) +
  facet_wrap(~ well) +
  labs(title = "Water cut over time", x = NULL, y = "Water cut") +
  pal_theme
ggsave("outputs/eda/well_watercut.png", p_wct, width = 11, height = 6, dpi = 150)

# --- 4. readable markdown one-pager -------------------------------

write_eda_md <- function(path, field, wells) {
  con <- file(path, open = "w", encoding = "UTF-8"); on.exit(close(con))
  wl <- function(...) writeLines(paste0(..., collapse = ""), con)
  wl("# Volve Production - Day 1 EDA")
  wl("")
  wl("_Generated ", format(Sys.time(), "%Y-%m-%d %H:%M"), " by `R/02_eda.R`_")
  wl("")
  wl("## Field summary")
  wl("")
  wl("| Metric | Value |")
  wl("|---|---|")
  for (i in seq_len(nrow(field))) wl("| ", field$metric[i], " | ", field$value[i], " |")
  wl("")
  wl("## Per-well summary")
  wl("")
  wl("| Well | History | Months (prod / gap) | Total oil (MMbbl) | Peak bopd | Last bopd | Decline from peak |")
  wl("|---|---|---|---|---|---|---|")
  for (i in seq_len(nrow(wells))) {
    w <- wells[i, ]
    wl("| ", w$well,
       " | ", format(w$first_month), " to ", format(w$last_month),
       " | ", w$producing_months, " / ", w$gap_months,
       " | ", fmt1(w$total_oil_mbbl),
       " | ", fmt0(w$peak_bopd),
       " | ", fmt0(w$last_bopd),
       " | ", fmt0(w$decline_from_peak_pct), "% |")
  }
  wl("")
  wl("## Figures")
  wl("")
  for (f in c("field_oil_rate.png", "well_decline_smallmultiples.png",
              "data_quality_tile.png", "well_watercut.png")) {
    wl("![", f, "](", f, ")")
    wl("")
  }
  wl("## Read-outs for Day 2 (decline-curve fitting)")
  wl("")
  wl("- Wells with **gap months > 0** have shut-in / workover periods; the Arps engine ",
     "will offer a \"fit from last stable segment\" option so those do not distort the fit.")
  wl("- Wells whose **decline from peak** is small are still early in life - forecasts will ",
     "be wide; flag them as low-confidence.")
  wl("- **Water cut** trending toward 100% explains rate decline that is not pure reservoir ",
     "depletion - worth a note in the client report.")
}
write_eda_md("outputs/eda/EDA_SUMMARY.md", field, well_summary)

# --- 5. console echo ---------------------------------------------

cat("\n================ FIELD SUMMARY ================\n")
print(as.data.frame(field), row.names = FALSE)
cat("\n================ PER-WELL SUMMARY =============\n")
print(as.data.frame(
  well_summary |>
    transmute(well, first_month, last_month,
              prod_mo = producing_months, gap_mo = gap_months,
              oil_MMbbl = round(total_oil_mbbl, 2),
              peak_bopd = round(peak_bopd), last_bopd = round(last_bopd),
              decline_pct = round(decline_from_peak_pct))
), row.names = FALSE)
cat("\nWrote outputs/eda/ : well_summary.csv, 4 PNGs, EDA_SUMMARY.md\n")
cat("02_eda.R done.\n")
