# =============================================================================
# functions_data.R — WRDS data-access helpers.
#
# CREDENTIAL-SAFE: no credentials in code. All access reads environment
# variables from a gitignored .Renviron (see data/README.md). If WRDS is not
# configured, wrds_connect() returns NULL and the loaders fall back to a small
# SYNTHETIC dataset so the pipeline runs end-to-end on a fresh clone without any
# licensed access. Raw licensed data is NEVER written to a tracked path
# (see .claude/rules/confidential-data.md).
#
# ALL sources are on WRDS (single RPostgres connection): CRSP, Compustat NA +
# Global, Worldscope, Datastream, and Orbis. The Datastream/Orbis WRDS library
# names vary by institution and are set via env (DS_LIB / ORBIS_LIB) in the
# loaders, then validated with assert_fields().
# =============================================================================

#' Open a WRDS connection (or return NULL if unconfigured)
#'
#' Reads WRDS_USER from the environment; the password is expected in
#' ~/.pgpass or the WRDS_PASS environment variable (never in code).
#'
#' @return A DBI connection, or NULL if WRDS is not configured.
wrds_connect <- function() {
  if (!(nzchar(Sys.getenv("WRDS_USER")) && requireNamespace("RPostgres", quietly = TRUE))) {
    message("  [data] WRDS not configured (WRDS_USER / RPostgres) - using synthetic data.")
    return(NULL)
  }
  pass <- Sys.getenv("WRDS_PASS", unset = NA_character_)
  args <- list(
    drv    = RPostgres::Postgres(),
    host   = Sys.getenv("WRDS_HOST", "wrds-pgdata.wharton.upenn.edu"),
    port   = as.integer(Sys.getenv("WRDS_PORT", "9737")),
    dbname = Sys.getenv("WRDS_DBNAME", "wrds"),
    user   = Sys.getenv("WRDS_USER"),
    sslmode = "require"
  )
  if (!is.na(pass)) args$password <- pass
  tryCatch(
    do.call(DBI::dbConnect, args),
    error = function(e) {
      warning("wrds_connect(): connection failed - falling back to synthetic. ",
              conditionMessage(e), call. = FALSE)
      NULL
    }
  )
}

#' Run a read-only SQL query against a WRDS connection
#'
#' @param con A DBI connection from wrds_connect() (or NULL).
#' @param sql A SELECT statement.
#' @return A data.frame, or NULL if con is NULL.
wrds_query <- function(con, sql) {
  if (is.null(con)) return(NULL)
  DBI::dbGetQuery(con, sql)
}

#' Assert that a claimed data-source field code exists before trusting it
#'
#' The research pass flagged several field codes as unverified (e.g. a
#' Worldscope IPO/first-traded code; the UK-only BDATE offset). Rather than
#' trust them silently, call this at load time against the actual pulled columns.
#'
#' @param df A data.frame just pulled from a source.
#' @param fields Character vector of required column names.
#' @param source Human-readable source name for the error message.
#' @return Invisibly TRUE; stops if any field is missing.
assert_fields <- function(df, fields, source = "source") {
  if (is.null(df)) return(invisible(TRUE))  # synthetic path: nothing to assert
  missing <- setdiff(fields, names(df))
  if (length(missing) > 0L) {
    stop(sprintf("assert_fields(): %s is missing expected field(s): %s. ",
                 source, paste(missing, collapse = ", ")),
         "Verify the field code against the live data dictionary (see the plan's ",
         "'Open items to confirm').")
  }
  invisible(TRUE)
}
