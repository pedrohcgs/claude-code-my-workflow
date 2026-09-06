# utils.R — shared helpers for the GeoAI demo
# Sourced by every script. No side effects beyond defining functions/constants.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(lubridate)
  library(stringr)
  library(readr)
  library(ggplot2)
})

# --- constants ---------------------------------------------------------------

SM3_TO_BBL <- 6.28981          # 1 standard cubic metre of oil -> barrels
PROJECT_MARKER <- "PLAN_two-week-demo.md"   # file that marks the project root

# --- tiny helpers ----------------------------------------------------------

`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0 || (length(a) == 1 && is.na(a))) b else a
}

# Warn if the working directory is not the project root.
check_wd <- function() {
  if (!file.exists(PROJECT_MARKER)) {
    stop(
      "This script expects the working directory to be the geoai-demo project root\n",
      "(the folder that contains '", PROJECT_MARKER, "').\n",
      "Current wd: ", getwd(), "\n",
      "Fix: open geoai-demo.Rproj in RStudio, or run setwd('<path>/geoai-demo') first."
    )
  }
  invisible(TRUE)
}

# Make a directory (recursively) without noise.
ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

# --- data-wrangling helpers ----------------------------------------------

# Lowercase, snake_case column names without adding a janitor dependency.
clean_names <- function(x) {
  n <- names(x)
  n <- tolower(trimws(n))
  n <- gsub("[ ./\\-]+", "_", n)
  n <- gsub("[^a-z0-9_]", "", n)
  n <- gsub("_+", "_", n)
  n <- gsub("^_|_$", "", n)
  names(x) <- n
  x
}

# Find the name of the first column that matches one of `candidates`
# (exact snake_case first, then substring). Returns NA if not required.
pick_col <- function(df, candidates, required = TRUE, what = candidates[1]) {
  nm <- names(df)
  hit <- candidates[candidates %in% nm]
  if (length(hit) == 0) {
    for (c in candidates) {
      m <- grep(c, nm, value = TRUE, fixed = TRUE)
      if (length(m)) { hit <- m[1]; break }
    }
  }
  if (length(hit) == 0) {
    if (required) {
      stop(sprintf(
        "Could not find a column for '%s'.\n  Looked for: %s\n  Columns present: %s",
        what, paste(candidates, collapse = ", "), paste(nm, collapse = ", ")
      ))
    }
    return(NA_character_)
  }
  hit[1]
}

# Parse the many date encodings a production spreadsheet might use.
parse_prod_date <- function(x) {
  if (inherits(x, "Date"))   return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (is.numeric(x))         return(as.Date(x, origin = "1899-12-30"))  # Excel serial
  d <- suppressWarnings(lubridate::ymd(x, quiet = TRUE))
  if (all(is.na(d))) d <- suppressWarnings(as.Date(lubridate::ymd_hms(x, quiet = TRUE)))
  if (all(is.na(d))) d <- suppressWarnings(lubridate::dmy(x, quiet = TRUE))
  if (all(is.na(d))) d <- suppressWarnings(lubridate::mdy(x, quiet = TRUE))
  d
}

# Coerce a column to numeric, tolerating commas / stray text.
as_num <- function(x) {
  if (is.numeric(x)) return(x)
  suppressWarnings(as.numeric(gsub("[^0-9eE.+-]", "", as.character(x))))
}

# A clean ggplot theme used across the demo.
theme_geoai <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title       = element_text(face = "bold"),
      strip.text       = element_text(face = "bold"),
      legend.position  = "bottom"
    )
}
