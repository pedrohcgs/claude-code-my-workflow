# =============================================================================
# 04_tables.R — Descriptive tables from returns.rds -> LaTeX (for the deck/note).
#
# Writes .tex fragments to OUT_DIR (input via \input{} in the .qmd) plus an RDS
# of the underlying summary data. Uses knitr::kable when available; otherwise
# writes a CSV and warns (loud, not silent).
# =============================================================================

for (obj in c("returns", "OUT_DIR")) {
  if (!exists(obj, inherits = FALSE)) {
    stop("04_tables.R: `", obj, "` missing. Run 00_run_all.R, not this script directly.")
  }
}

has_kable <- requireNamespace("knitr", quietly = TRUE)

#' Summary statistics for a numeric column grouped by a categorical column
#'
#' @param df A data.frame containing `value` and `group` columns.
#' @param value Character scalar: name of the numeric column to summarise.
#' @param group Character scalar: name of the grouping column (also the name of
#'   the first output column).
#' @return A data.frame with the grouping column plus `n`, `mean`, `median`, `sd`
#'   — one row per non-empty group level.
summarise_by <- function(df, value, group) {
  x <- df[[value]]
  g <- df[[group]]
  ok <- !is.na(x)
  x <- x[ok]; g <- droplevels(as.factor(g[ok]))
  parts <- split(x, g)
  out <- data.frame(n = vapply(parts, length, integer(1L)),
                    mean   = vapply(parts, function(v) mean(v,          na.rm = TRUE), numeric(1L)),
                    median = vapply(parts, function(v) stats::median(v, na.rm = TRUE), numeric(1L)),
                    sd     = vapply(parts, function(v) stats::sd(v,      na.rm = TRUE), numeric(1L)),
                    row.names = NULL, stringsAsFactors = FALSE)
  # Name the first column after the grouping variable (not hardcoded "region").
  out <- cbind(stats::setNames(data.frame(names(parts), stringsAsFactors = FALSE), group), out)
  out
}

tab_underpricing <- summarise_by(returns$underpricing, "underpricing", "region")
tab_longrun      <- summarise_by(returns$longrun, "bhar", "region")
tab_ct           <- returns$ct_alpha

tables <- list(underpricing = tab_underpricing, longrun = tab_longrun, ct_alpha = tab_ct)
saveRDS(tables, file.path(OUT_DIR, "tables.rds"))

write_table <- function(df, file, caption, digits = 3) {
  path <- file.path(OUT_DIR, file)
  if (has_kable) {
    tex <- knitr::kable(df, format = "latex", booktabs = TRUE, digits = digits,
                        caption = caption, row.names = FALSE)
    writeLines(as.character(tex), path)
    message("Wrote ", path)
  } else {
    csv <- sub("\\.tex$", ".csv", path)
    utils::write.csv(df, csv, row.names = FALSE)
    warning("04_tables.R: 'knitr' not installed - wrote ", csv, " (CSV) instead of LaTeX.\n",
            "Install with: install.packages('knitr')", call. = FALSE)
    message("Wrote ", csv, " (CSV fallback)")
  }
}

write_table(tab_underpricing, "table_underpricing.tex",
            "First-day underpricing by region (US and UK; offer prices clean).")
write_table(tab_longrun, "table_longrun_bhar.tex",
            "36-month buy-and-hold abnormal returns (BHAR) by region.")
if (!is.null(tab_ct)) {
  write_table(tab_ct, "table_calendar_time_alpha.tex",
              "Calendar-time portfolio abnormal returns (monthly alpha) by region.")
}
