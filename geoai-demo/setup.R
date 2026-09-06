# setup.R — install R packages needed from Day 2 onward.
# Day 1 (load + EDA) runs WITHOUT this, on packages you already have.
#
# Run once:  source("setup.R")

needed <- c(
  "minpack.lm",  # robust non-linear least squares for Arps decline fitting (Day 2)
  "janitor",     # tidy column names / tabulation (Day 2+)
  "shiny",       # web app (Day 3+)
  "bslib",       # app theming
  "DT",          # interactive tables in the app
  "plotly",      # interactive decline plots
  "rmarkdown",   # PDF/HTML report rendering (Day 6)
  "rsconnect",   # deploy to shinyapps.io (Day 8)
  "renv"         # dependency lockfile (Day 8, before deploy)
)

have    <- rownames(installed.packages())
missing <- setdiff(needed, have)

if (length(missing) == 0) {
  message("All Day 2+ packages already installed.")
} else {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}

# report
have <- rownames(installed.packages())
for (p in needed) message(sprintf("  %-12s %s", p, if (p %in% have) "OK" else "STILL MISSING"))
