# run_app.R — launch the demo app in a browser.
# From the project root:  source("run_app.R")
stopifnot(file.exists("app.R"))
shiny::runApp("app.R", launch.browser = TRUE)
