# run_reports.R — generate a client-ready HTML report for every well + the field
# portfolio, into outputs/reports/. Then (if Chrome/Edge is present) also make PDFs.
#
# From the project root:  source("run_reports.R")

source("R/utils.R")
source("R/05_report.R")
check_wd()

mfile <- "data/processed/volve_monthly.rds"
if (!file.exists(mfile)) stop("Missing ", mfile, " - run source(\"run_day1.R\") first.")
monthly <- readRDS(mfile)

# match these to R/04_fit_report.R
Q_ECON <- 50; WINDOW <- "auto"; MAX_YEARS <- 30; B_MAX <- 1.5

message("Building HTML reports ...")
paths <- render_all_reports("outputs/reports", monthly,
                            q_econ = Q_ECON, window = WINDOW,
                            max_years = MAX_YEARS, b_max = B_MAX)
for (p in paths) message("  ", p)

message("\nTrying HTML -> PDF via headless browser ...")
n_pdf <- 0
for (p in paths) {
  pdf <- sub("\\.html$", ".pdf", p)
  if (html_to_pdf(p, pdf)) { message("  ", pdf); n_pdf <- n_pdf + 1 }
}
if (n_pdf == 0)
  message("  (no PDFs made - open an .html file and use Ctrl/Cmd-P -> Save as PDF)")

message("\nDone. ", length(paths), " HTML, ", n_pdf, " PDF in outputs/reports/")
