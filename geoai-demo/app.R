# app.R — GeoAI demo: decline-curve explorer
#
# Run from the project root:  library(shiny); runApp(launch.browser = TRUE)
# or:  source("run_app.R")

library(shiny)
library(bslib)

source("R/05_report.R")      # -> 03_decline_curve.R -> utils.R, dplyr, ggplot2, minpack.lm, htmltools
source("R/ingest.R")         # ingest_production() for user uploads
source("R/06_screening.R")   # screen_wells()

scroll_table <- function(id, height = "430px") {
  div(style = sprintf("max-height:%s; overflow:auto;", height), tableOutput(id))
}
pct <- function(x, d = 0) ifelse(is.finite(x), paste0(formatC(100 * x, format = "f", digits = d), "%"), "—")

# ---- data ---------------------------------------------------------------

MONTHLY_PATH  <- "data/processed/volve_monthly.rds"
data_ready    <- file.exists(MONTHLY_PATH)
VOLVE_MONTHLY <- if (data_ready) readRDS(MONTHLY_PATH) else NULL
volve_wells   <- if (data_ready) sort(unique(VOLVE_MONTHLY$well)) else character(0)

BRAND        <- "#1b5e9c"
COMPANY      <- "GeoAI Analytics"
DEFAULT_WELL <- if ("15/9-F-12" %in% volve_wells) "15/9-F-12" else
  if (length(volve_wells)) volve_wells[1] else NULL
LOGO_URI     <- if (file.exists("report/logo.png"))
  base64enc::dataURI(file = "report/logo.png", mime = "image/png") else NULL

app_title <- tagList(
  if (!is.null(LOGO_URI))
    tags$img(src = LOGO_URI, style = "height:26px;margin-right:10px;vertical-align:middle;"),
  "GeoAI — Decline-Curve Explorer"
)

# ---- UI --------------------------------------------------------------

ui <- page_sidebar(
  title = app_title,
  window_title = "GeoAI — Decline-Curve Explorer",
  theme = bs_theme(version = 5, primary = BRAND, base_font = font_google("Inter")),

  tags$head(tags$style(HTML(
    ".shiny-plot-output img { max-width: 100%; height: auto; }
     .demo-intro { font-size: 13.5px; color: #5a5a5a; margin: 2px 0 12px; }
     .demo-foot  { font-size: 11.5px; color: #8a8a8a; margin-top: 22px;
                   border-top: 1px solid #e6e6e6; padding-top: 10px; }
     .src-label  { font-size: 12px; color: #666; margin-top: -4px; }"))),

  sidebar = sidebar(
    width = 300,
    if (!data_ready) {
      div(class = "text-danger",
          strong("No processed data found."), br(),
          "Run Day 1 first: open ", code("geoai-demo.Rproj"),
          " and in the R console run ", code('source("run_day1.R")'), ".")
    } else {
      tagList(
        selectInput("well", "Well", choices = volve_wells, selected = DEFAULT_WELL),
        sliderInput("q_econ", "Economic oil rate (bopd)",
                    min = 10, max = 500, value = 50, step = 10),
        radioButtons("window", "Fit window",
                     c("Auto" = "auto", "Post-peak" = "post_peak",
                       "Last stable" = "last_stable", "All history" = "all"),
                     selected = "auto"),
        sliderInput("b_max", "Max b (hyperbolic tail)",
                    min = 0.5, max = 2, value = 1.5, step = 0.1),
        radioButtons("yscale", "Rate axis",
                     c("Log" = "log", "Linear" = "linear"), selected = "log"),
        sliderInput("max_years", "Max forecast horizon (yr)",
                    min = 5, max = 40, value = 30, step = 5),
        hr(),
        fileInput("upload", "Upload production data",
                  accept = c(".csv", ".xlsx", ".xls"), buttonLabel = "Browse…",
                  placeholder = "CSV or Excel"),
        div(class = "src-label", textOutput("src_label")),
        actionLink("reset_sample", "↺ back to Volve sample"),
        hr(),
        downloadButton("dl_report",   "Well report (HTML)",  class = "btn-sm"),
        downloadButton("dl_portfolio", "Field report (HTML)", class = "btn-sm"),
        downloadButton("dl_forecast", "Forecast (CSV)",       class = "btn-sm"),
        helpText("Open a report and press Ctrl/Cmd-P → Save as PDF.")
      )
    }
  ),

  if (!data_ready) {
    card(card_body("Waiting for data. See the sidebar."))
  } else {
    tagList(
      p(class = "demo-intro",
        "Loaded with Equinor's ", strong("Volve"), " field — real North Sea production, ",
        "2008–2016 (open data) — or ", strong("upload your own"), " production file in the ",
        "sidebar. Pick a well; the fitted Arps decline, P90–P10 range and EUR update live. ",
        "The ", strong("Well screening"), " and ", strong("Field portfolio"), " tabs work the ",
        "whole asset; ", strong("About & method"), " explains the model."),
      layout_columns(
        fill = FALSE, col_widths = c(4, 4, 4, 4, 4, 4),
        value_box("Model",       textOutput("v_model"), theme = "primary"),
        value_box("qi (bopd)",   textOutput("v_qi"),    theme = "light"),
        value_box("Di /yr",      textOutput("v_di"),    theme = "light"),
        value_box("b",           textOutput("v_b"),     theme = "light"),
        value_box("R²",          uiOutput("v_r2"),      theme = "light"),
        value_box("EUR (MMbbl)", textOutput("v_eur"), uiOutput("v_eur_range"), theme = "primary")
      ),
      uiOutput("flag_box"),
      card(
        full_screen = TRUE, min_height = "480px",
        card_header("Rate vs time — history, fit, forecast & P90–P10 range"),
        plotOutput("declinePlot", height = "440px")
      ),
      navset_card_tab(
        nav_panel("Forecast table",   scroll_table("fcTable")),
        nav_panel("Fit details",      tableOutput("fitDetails")),
        nav_panel("Production data",   scroll_table("prodTable")),
        nav_panel(
          "Well screening",
          p(class = "text-muted small",
            "Rule-based, not a machine-learning model. Every input is a plain production ",
            "signal and the score is a transparent weighted sum — see ", strong("About & method"),
            ". Ranks wells worth a closer look for intervention; it decides nothing."),
          scroll_table("screenTable", "460px")
        ),
        nav_panel(
          "Field portfolio",
          layout_columns(
            fill = FALSE, col_widths = c(6, 6),
            value_box("Field EUR (MMbbl)", textOutput("pf_eur"), theme = "primary"),
            value_box("Remaining to produce (MMbbl)", textOutput("pf_rem"), theme = "light")
          ),
          plotOutput("portfolioBar", height = "320px"),
          tableOutput("portfolioTable")
        ),
        nav_panel(
          "About & method",
          div(
            style = "max-width: 760px; font-size: 14px;",
            h5("What this is"),
            p("A working prototype: it turns a well's monthly oil-production history into a ",
              "decline-curve forecast with a P90–P10 range and an estimated ultimate recovery ",
              "(EUR), rolls the wells up into an asset view, and screens them for intervention ",
              "candidates. Runs on any field's production data; loaded here with Equinor's ",
              "public ", strong("Volve"), " field."),
            h5("Decline model"),
            tags$ul(
              tags$li(HTML("Fits the Arps model &nbsp;<em>q(t) = q<sub>i</sub> / (1 + b&middot;D<sub>i</sub>&middot;t)<sup>1/b</sup></em>&nbsp; by Levenberg–Marquardt least squares.")),
              tags$li("Exponential, hyperbolic and harmonic are each fitted; the lowest-AICc model wins."),
              tags$li("Time origin is the start of the fit window, so qi is the rate where the analysed decline begins."),
              tags$li("EUR = oil produced to date + the closed-form Arps volume from the last rate down to the economic rate."),
              tags$li("Horizon is shortened automatically for weak or short-history fits; every questionable fit is flagged.")
            ),
            h5("P90 / P50 / P10 range"),
            p("The fitted parameters carry uncertainty (the fit's covariance). We draw ~300 ",
              "parameter sets from that covariance, add lognormal scatter sized to the fit's own ",
              "residuals, and read the 10th / 50th / 90th percentiles of the resulting rate and ",
              "EUR. P90 is the low (conservative) case, P10 the high case. This is a ",
              "parametric approximation, not a full probabilistic reserves study."),
            h5("Well screening score (0–100)"),
            p("A transparent weighted sum of four production signals — no training, no black box:"),
            tags$ul(
              tags$li("35% — underperformance vs the well's own fitted decline (producing below trend)"),
              tags$li("25% — remaining oil to produce (enough upside to be worth an intervention)"),
              tags$li("20% — current water cut"),
              tags$li("20% — rate of change of water cut (rising = actionable)")
            ),
            p("The ", em("signal"), " column is a plain if-then reading of those same numbers."),
            h5("What it does not do (yet)"),
            tags$ul(
              tags$li("Machine-learning production prediction, physics-based reservoir / EOR modelling, or type-curve analogues."),
              tags$li("Field-level abandonment economics — several Volve wells were shut in above their economic rate when the platform left in 2016, so per-well “remaining” is an upper bound."),
              tags$li("KazSRE / state-reserve reporting formats, or a Russian / Kazakh interface — the localisation layer is the next build.")
            ),
            h5("Data & licence"),
            p("Equinor Volve field production data, © Equinor and the former Volve licence partners, ",
              "released under the Equinor Open Data Licence for research and study. Figures here are ",
              "illustrative and are ", strong("not"), " reserves in the SPE-PRMS sense."),
            hr(),
            p(class = "text-muted", paste0(COMPANY, " · demo · not investment or reserves advice."))
          )
        )
      ),
      div(class = "demo-foot",
          paste0(COMPANY, " — decline-curve demo. Sample data: Equinor Volve open dataset (2008–2016). ",
                 "Estimates are illustrative, not SPE-PRMS reserves."))
    )
  }
)

# ---- server --------------------------------------------------------

server <- function(input, output, session) {
  req(data_ready)

  rv <- reactiveValues(monthly = VOLVE_MONTHLY, src = "Volve field (sample)")
  active <- reactive(rv$monthly)

  observeEvent(input$upload, {
    req(input$upload)
    res <- tryCatch(ingest_production(input$upload$datapath), error = function(e) e)
    if (inherits(res, "error")) {
      showNotification(paste("Could not read that file —", conditionMessage(res)),
                       type = "error", duration = 12)
      return()
    }
    wl <- sort(unique(res$monthly$well))
    rv$monthly <- res$monthly
    rv$src <- paste0(input$upload$name, "  (", res$info, ")")
    updateSelectInput(session, "well", choices = wl, selected = wl[1])
    showNotification(paste0("Loaded ", res$info, ". Fitting ", length(wl), " wells…"),
                     type = "message", duration = 6)
  })

  observeEvent(input$reset_sample, {
    rv$monthly <- VOLVE_MONTHLY
    rv$src <- "Volve field (sample)"
    updateSelectInput(session, "well", choices = volve_wells, selected = DEFAULT_WELL)
  })

  output$src_label <- renderText(paste0("Data: ", rv$src))

  fit <- reactive({
    req(input$well, input$well %in% unique(active()$well))
    fit_decline(dplyr::filter(active(), well == input$well),
                q_econ = input$q_econ, window = input$window,
                max_years = input$max_years, b_max = input$b_max)
  })

  portfolio <- reactive({
    fit_all_wells(active(), q_econ = input$q_econ, window = input$window,
                  max_years = input$max_years, b_max = input$b_max)
  })

  nf <- function(x, d = 2) if (is.null(x) || is.na(x)) "—" else formatC(x, format = "f", digits = d, big.mark = ",")

  # value boxes -----------------------------------------------------
  output$v_model <- renderText(if (isTRUE(fit()$ok)) fit()$model else "—")
  output$v_qi    <- renderText(if (isTRUE(fit()$ok)) nf(fit()$params$qi_bopd, 0) else "—")
  output$v_di    <- renderText(if (isTRUE(fit()$ok)) nf(fit()$params$Di_nominal_annual, 2) else "—")
  output$v_b     <- renderText(if (isTRUE(fit()$ok)) nf(fit()$params$b, 2) else "—")
  output$v_eur   <- renderText(if (isTRUE(fit()$ok)) nf(fit()$eur_mmbbl, 2) else "—")
  output$v_eur_range <- renderUI({
    f <- fit()
    if (!isTRUE(f$ok) || is.na(f$eur_p90_mmbbl)) return(NULL)
    span(class = "small",
         sprintf("P90 %.1f · P10 %.1f", f$eur_p90_mmbbl, f$eur_p10_mmbbl))
  })
  output$v_r2 <- renderUI({
    f <- fit()
    if (!isTRUE(f$ok)) return("—")
    g <- fit_grade(f$fit_quality$r2)
    tagList(sprintf("%.3f ", f$fit_quality$r2),
            span(class = paste0("badge bg-", g$colour), g$label))
  })

  # flags --------------------------------------------------------
  output$flag_box <- renderUI({
    f <- fit()
    if (!isTRUE(f$ok))
      return(div(class = "alert alert-danger",
                 strong("Cannot fit this well: "), paste(f$flags, collapse = "; ")))
    if (length(f$flags))
      div(class = "alert alert-warning",
          strong("Read with care:"), tags$ul(lapply(f$flags, tags$li)))
  })

  # main plot --------------------------------------------------
  output$declinePlot <- renderPlot({
    f <- fit()
    validate(need(isTRUE(f$ok), paste("No fit:", paste(f$flags, collapse = "; "))))
    plot_decline_fit(f, log_y = (input$yscale == "log"))
  }, width = 900, height = 440, res = 96)

  # forecast table -------------------------------------------
  output$fcTable <- renderTable({
    f <- fit(); req(isTRUE(f$ok))
    validate(need(nrow(f$forecast) > 0,
                  "This well is already at or below the economic rate — no forecast."))
    out <- f$forecast |>
      dplyr::transmute(Date = format(date, "%Y-%m"),
                       `Rate P50 (bopd)` = round(rate_bopd, 1))
    if (!is.null(f$bands)) {
      b <- f$bands
      out$`P90 (bopd)` <- round(b$lo, 1)
      out$`P10 (bopd)` <- round(b$hi, 1)
    }
    out
  }, striped = TRUE, spacing = "xs", width = "100%", digits = 1)

  # fit details --------------------------------------------
  output$fitDetails <- renderTable({
    f <- fit(); req(isTRUE(f$ok))
    win <- f$fit_quality$window
    if (identical(f$fit_quality$window_requested, "auto")) win <- paste0(win, " (auto)")
    eur_row <- if (is.na(f$eur_p90_mmbbl)) sprintf("%.3f", f$eur_mmbbl)
      else sprintf("%.3f  (P90 %.2f – P10 %.2f)", f$eur_mmbbl, f$eur_p90_mmbbl, f$eur_p10_mmbbl)
    data.frame(
      Field = c("Well", "Model", "Fit window", "Points fitted", "R²", "RMSE (bopd)",
                "qi at decline start (bopd)", "Di nominal (/yr)", "b", "Max b allowed",
                "1st-year effective decline", "Decline start", "Last observed rate (bopd)",
                "Last observed month", "Economic rate (bopd)", "Forecast end of life",
                "Forecast months", "Np to date (MMbbl)", "Remaining (MMbbl)", "EUR (MMbbl)"),
      Value = c(
        f$well, f$model, win, f$fit_quality$n_points,
        sprintf("%.3f", f$fit_quality$r2), sprintf("%.0f", f$fit_quality$rmse),
        formatC(f$params$qi_bopd, format = "f", digits = 0, big.mark = ","),
        sprintf("%.3f", f$params$Di_nominal_annual), sprintf("%.3f", f$params$b),
        sprintf("%.1f", f$b_max), sprintf("%.0f%%", 100 * f$de_first_year),
        format(f$decline_start),
        formatC(f$last_rate_bopd, format = "f", digits = 0, big.mark = ","),
        format(f$last_date), f$q_econ, format(f$eol_date), f$remaining_months,
        sprintf("%.3f", f$np_to_date_bbl / 1e6),
        sprintf("%.3f", f$remaining_bbl / 1e6), eur_row
      )
    )
  }, striped = TRUE, spacing = "xs", width = "100%")

  # production data -------------------------------------
  output$prodTable <- renderTable({
    dplyr::filter(active(), well == input$well) |>
      dplyr::transmute(Month = format(month, "%Y-%m"),
                       `Oil (bbl)` = round(oil_bbl),
                       `Oil rate (bopd)` = round(oil_rate_bopd, 1),
                       `Water cut` = ifelse(is.finite(wct), scales::percent(wct, accuracy = 1), "—"),
                       `Days on stream` = round(days_on_stream, 1),
                       `Cum oil (Mbbl)` = round(cum_oil_bbl / 1e6, 3))
  }, striped = TRUE, spacing = "xs", width = "100%", digits = 1)

  # well screening ------------------------------------
  screening <- reactive(screen_wells(active(), portfolio()$fits, input$q_econ))
  output$screenTable <- renderTable({
    s <- screening()
    validate(need(nrow(s) > 0, "No wells to screen."))
    s |>
      dplyr::transmute(
        Well = well,
        `Attention` = ifelse(is.finite(attention), as.character(attention), "—"),
        `Current bopd` = ifelse(is.finite(current_bopd), formatC(current_bopd, format = "d", big.mark = ","), "—"),
        `6-mo decline` = pct(decline_6mo),
        `Under vs trend` = pct(underperf_vs_trend),
        `Water cut` = pct(wct),
        `WC trend /yr` = pct(wct_trend_yr, 1),
        `Remaining MMbbl` = ifelse(is.finite(remaining_mmbbl), sprintf("%.2f", remaining_mmbbl), "—"),
        `Months to econ` = ifelse(is.finite(months_to_econ), as.character(round(months_to_econ)), "—"),
        Signal = signal
      )
  }, striped = TRUE, spacing = "xs", width = "100%")

  # field portfolio ------------------------------------
  output$pf_eur <- renderText({
    pf <- dplyr::filter(portfolio()$summary, ok); nf(sum(pf$eur_mmbbl, na.rm = TRUE), 1)
  })
  output$pf_rem <- renderText({
    pf <- dplyr::filter(portfolio()$summary, ok); nf(sum(pf$remaining_mbbl, na.rm = TRUE), 1)
  })
  output$portfolioBar <- renderPlot({
    pf <- dplyr::filter(portfolio()$summary, ok)
    validate(need(nrow(pf) > 0, "No wells could be fitted with the current settings."))
    bd <- pf |>
      dplyr::transmute(well, `Produced to date` = np_to_date_mbbl,
                       `Remaining (forecast)` = remaining_mbbl) |>
      tidyr::pivot_longer(-well, names_to = "component", values_to = "mmbbl")
    ggplot(bd, aes(stats::reorder(well, -mmbbl), mmbbl, fill = component)) +
      geom_col() +
      scale_fill_manual(values = c("Produced to date" = "#37474f",
                                   "Remaining (forecast)" = BRAND)) +
      labs(title = "EUR by well", x = NULL, y = "MMbbl", fill = NULL) +
      theme_geoai()
  }, width = 900, height = 320, res = 96)
  output$portfolioTable <- renderTable({
    pf <- portfolio()$summary
    tab <- pf |>
      dplyr::transmute(
        Well = well, Model = ifelse(is.na(model), "—", model),
        `R2` = ifelse(ok, sprintf("%.3f", r2), "—"),
        `EUR (MMbbl)` = ifelse(ok, sprintf("%.2f", eur_mmbbl), "—"),
        `EUR P90–P10` = ifelse(ok & is.finite(eur_p90_mmbbl),
                               sprintf("%.2f – %.2f", eur_p90_mmbbl, eur_p10_mmbbl), "—"),
        `Produced (MMbbl)` = ifelse(ok, sprintf("%.2f", np_to_date_mbbl), "—"),
        `Remaining (MMbbl)` = ifelse(ok, sprintf("%.2f", remaining_mbbl), "—"),
        Flags = flags
      )
    okp <- dplyr::filter(pf, ok)
    total <- data.frame(
      Well = "FIELD TOTAL", Model = "", R2 = "",
      `EUR (MMbbl)` = sprintf("%.2f", sum(okp$eur_mmbbl)), `EUR P90–P10` = "",
      `Produced (MMbbl)` = sprintf("%.2f", sum(okp$np_to_date_mbbl)),
      `Remaining (MMbbl)` = sprintf("%.2f", sum(okp$remaining_mbbl)), Flags = "",
      check.names = FALSE
    )
    rbind(as.data.frame(tab), total)
  }, striped = TRUE, spacing = "xs", width = "100%")

  for (id in c("fcTable", "fitDetails", "prodTable", "screenTable",
               "pf_eur", "pf_rem", "portfolioBar", "portfolioTable")) {
    outputOptions(output, id, suspendWhenHidden = FALSE)
  }

  # downloads -----------------------------------------
  safe_well <- function() gsub("[^A-Za-z0-9]+", "_", input$well)

  output$dl_forecast <- downloadHandler(
    filename = function() sprintf("forecast_%s.csv", safe_well()),
    content  = function(path) {
      f <- fit()
      if (isTRUE(f$ok)) {
        out <- f$series
        readr::write_csv(out, path)
      } else readr::write_csv(data.frame(note = paste(f$flags, collapse = "; ")), path)
    }
  )
  output$dl_report <- downloadHandler(
    filename = function() sprintf("report_%s.html", safe_well()),
    content  = function(path) {
      writeLines(build_report_html(input$well, active(),
                   q_econ = input$q_econ, window = input$window,
                   max_years = input$max_years, b_max = input$b_max),
                 path, useBytes = TRUE)
    }
  )
  output$dl_portfolio <- downloadHandler(
    filename = function() "report_field_portfolio.html",
    content  = function(path) {
      writeLines(build_portfolio_html(active(),
                   q_econ = input$q_econ, window = input$window,
                   max_years = input$max_years, b_max = input$b_max),
                 path, useBytes = TRUE)
    }
  )
}

shinyApp(ui, server)
