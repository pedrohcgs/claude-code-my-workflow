# This file's presence tells Shiny NOT to auto-source every .R file in R/ on
# app startup. The scripts in R/ are batch pipeline steps with side effects
# (01_load_data.R, 02_eda.R, 04_fit_report.R) and must not run when the app
# launches. app.R sources only what it needs: source("R/03_decline_curve.R").
