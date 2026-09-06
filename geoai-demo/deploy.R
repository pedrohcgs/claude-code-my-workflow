# deploy.R — publish the decline-curve app to shinyapps.io
#
# One-time (per machine): configure the account with the token block from
#   shinyapps.io -> Account -> Tokens -> Show:
#     rsconnect::setAccountInfo(name=..., token=..., secret=...)
# Then, from the project root:  source("deploy.R")

source("R/utils.R"); check_wd()
library(rsconnect)

APP_NAME <- "decline-explorer"
ACCOUNT  <- "geoai-analytics"
SERVER   <- "shinyapps.io"

if (!(ACCOUNT %in% rsconnect::accounts()$name))
  stop("Account '", ACCOUNT, "' is not configured. Run rsconnect::setAccountInfo(...) first.")

# Minimal bundle: the app + the R it sources + the one data file it reads.
app_files <- c(
  "app.R",
  "R/utils.R",
  "R/03_decline_curve.R",
  "R/05_report.R",
  "R/06_screening.R",
  "R/ingest.R",
  "R/_disable_autoload.R",
  "data/processed/volve_monthly.rds"
)
missing <- app_files[!file.exists(app_files)]
if (length(missing))
  stop("missing bundle files: ", paste(missing, collapse = ", "),
       "\n(run source(\"run_day1.R\") to (re)build the processed data)")

message("Deploying ", APP_NAME, " to ", ACCOUNT, ".", SERVER, " ...")
rsconnect::deployApp(
  appDir      = ".",
  appFiles    = app_files,
  appName     = APP_NAME,
  account     = ACCOUNT,
  server      = SERVER,
  forceUpdate = TRUE,
  launch.browser = FALSE,
  logLevel    = "normal"
)
message("\nLive at: https://", ACCOUNT, ".", SERVER, "/", APP_NAME, "/")
