# run_day1.R — one-shot Day 1 pipeline.
#
# Usage:
#   1. Put 'Volve production data.xlsx' in  data/   (see data/README.md)
#   2. Open geoai-demo.Rproj in RStudio  (or setwd() to this folder)
#   3. source("run_day1.R")
#
# Produces: data/processed/*  and  outputs/eda/*  (incl. EDA_SUMMARY.md)

stopifnot(file.exists("PLAN_two-week-demo.md"))  # guard: correct working directory

cat("\n[1/2] Loading & cleaning production data ...\n")
source("R/01_load_data.R")

cat("\n[2/2] Running EDA ...\n")
source("R/02_eda.R")

cat("\n----------------------------------------------------------\n")
cat("Day 1 complete. Open  outputs/eda/EDA_SUMMARY.md  to review.\n")
cat("----------------------------------------------------------\n")
