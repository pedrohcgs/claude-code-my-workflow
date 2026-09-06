# 05_report.R — client-ready decline-curve report (self-contained HTML)
#
# No Quarto / Pandoc / LaTeX required: the HTML is assembled in R with inline CSS
# and base64-embedded charts, so it renders identically on any machine and on
# shinyapps.io. Open it in a browser and press Ctrl/Cmd-P -> "Save as PDF" for a
# paginated document (a print stylesheet handles page breaks and margins).
#
# Entry points:
#   build_report_html(well, monthly, ...)      -> one well  -> HTML string
#   build_portfolio_html(monthly, ...)         -> whole field -> HTML string
#   render_report_file(path, well, monthly,...) -> writes a file
#   render_all_reports(dir, monthly, ...)      -> one file per well + portfolio
#   html_to_pdf(html_path, pdf_path)           -> TRUE if a headless browser made a PDF

source("R/03_decline_curve.R")
if (file.exists("R/07_analytics.R")) source("R/07_analytics.R")   # for backtest_well() in the KAZ-RC report
suppressPackageStartupMessages(library(htmltools))

# --- branding (edit here, or drop a report/logo.png) --------------------

default_brand <- function() {
  logo <- "report/logo.png"
  list(
    company = "GeoAI Analytics",
    tagline = "Subsurface & production analytics for Central Asia",
    color   = "#1b5e9c",
    accent  = "#c62828",
    logo    = if (file.exists(logo)) logo else NULL
  )
}

# --- small helpers ---------------------------------------------------

.png_data_uri <- function(plot, width = 9, height = 4.6, dpi = 150) {
  f <- tempfile(fileext = ".png")
  ggplot2::ggsave(f, plot, width = width, height = height, dpi = dpi)
  on.exit(unlink(f), add = TRUE)
  base64enc::dataURI(file = f, mime = "image/png")
}

.stat_card <- function(label, value, sub = NULL) {
  div(class = "card",
      div(class = "card-label", label),
      div(class = "card-value", value),
      if (!is.null(sub)) div(class = "card-sub", sub))
}

.html_table <- function(df, align_right = TRUE) {
  tags$table(class = "tbl",
    tags$thead(tags$tr(lapply(names(df), tags$th))),
    tags$tbody(lapply(seq_len(nrow(df)), function(i)
      tags$tr(lapply(seq_along(df), function(j) tags$td(as.character(df[i, j]))))))
  )
}

.fmt <- function(x, d = 2) formatC(x, format = "f", digits = d, big.mark = ",")

.report_css <- function(brand) sprintf('
  :root { --brand:%s; --accent:%s; }
  * { box-sizing: border-box; }
  body { font: 15px/1.55 -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
         color: #1a1a1a; margin: 0; background: #fff; }
  .wrap { max-width: 900px; margin: 0 auto; padding: 20px 32px 48px; }
  header.band { border-bottom: 3px solid var(--brand); padding: 22px 32px 16px; }
  .wrap-h { max-width: 900px; margin: 0 auto; display: flex; align-items: baseline; gap: 16px; }
  header.band img { height: 38px; align-self: center; }
  header.band .co { font-size: 21px; font-weight: 800; letter-spacing: .2px; color: var(--brand); }
  header.band .tg { color: #666; font-size: 13px; }
  header.band .rt { margin-left: auto; text-align: right; font-size: 12px; color: #666;
                    text-transform: uppercase; letter-spacing: .6px; }
  h1 { font-size: 22px; margin: 26px 0 4px; }
  h2 { font-size: 15px; margin: 30px 0 10px; padding-bottom: 6px; text-transform: uppercase;
       letter-spacing: .6px; border-bottom: 2px solid var(--brand); color: var(--brand); }
  .subtitle { color: #666; margin: 0 0 8px; font-size: 13.5px; }
  .cards { display: flex; gap: 14px; flex-wrap: wrap; margin: 16px 0 4px; }
  .card { flex: 1 1 150px; border: 1px solid #d9d9d9; border-radius: 8px; padding: 12px 14px;
          border-top: 3px solid #d9d9d9; }
  .card-label { font-size: 10.5px; text-transform: uppercase; letter-spacing: .5px; color: #777; }
  .card-value { font-size: 23px; font-weight: 700; margin-top: 3px; }
  .card-sub { font-size: 12px; color: #777; margin-top: 2px; }
  .card.hi { border-color: var(--brand); border-top-width: 3px; border-top-color: var(--brand); }
  .card.hi .card-value { color: var(--brand); }
  img.chart { width: 100%%; border: 1px solid #eee; border-radius: 8px; margin: 8px 0; }
  table.tbl { border-collapse: collapse; width: 100%%; font-size: 13px; margin: 8px 0; }
  table.tbl th { text-align: left; border-bottom: 2px solid var(--brand);
                 padding: 7px 10px; color: #333; }
  table.tbl td { border-bottom: 1px solid #ececec; padding: 6px 10px; }
  table.tbl tr:last-child td { border-bottom: none; font-weight: 700; }
  .callout { border: 1px solid #f0c8c8; border-left: 4px solid var(--accent);
             padding: 10px 14px; border-radius: 4px; margin: 14px 0; font-size: 13px; }
  .callout ul { margin: 6px 0 0 18px; padding: 0; }
  footer { margin-top: 40px; padding-top: 14px; border-top: 1px solid #e3e3e3;
           font-size: 11px; color: #777; }
  @page { size: A4; margin: 16mm; }
  @media print {
    body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    h2 { break-after: avoid; }
    .cards, img.chart, table.tbl, .callout { break-inside: avoid; }
    a[href]:after { content: ""; }
  }
', brand$color, brand$accent)

.doc <- function(title, brand, body_nodes) {
  hdr <- tags$header(class = "band",
    div(class = "wrap-h",
      if (!is.null(brand$logo)) tags$img(src = base64enc::dataURI(file = brand$logo, mime = "image/png")),
      div(div(class = "co", brand$company), div(class = "tg", brand$tagline)),
      div(class = "rt", "Decline-Curve Analysis", tags$br(),
          format(Sys.Date(), "%Y-%m-%d"))
    ))
  # NB: htmltools::renderTags() hoists tags$head() out of the string, so the head
  # is assembled by hand; only the body is rendered via htmltools.
  body_html <- as.character(tagList(hdr, div(class = "wrap", body_nodes)))
  paste0(
    "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n",
    "<meta charset=\"utf-8\">\n",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
    "<title>", htmltools::htmlEscape(title), "</title>\n",
    "<style>\n", .report_css(brand), "\n</style>\n",
    "</head>\n<body>\n", body_html, "\n</body>\n</html>\n"
  )
}

.methodology <- function() {
  tagList(
    tags$h2("Method & assumptions"),
    tags$p(HTML(
      'Monthly oil rate is fitted with the Arps decline model &nbsp;',
      '<em>q(t) = q<sub>i</sub> / (1 + b&middot;D<sub>i</sub>&middot;t)<sup>1/b</sup></em>&nbsp; ',
      'by Levenberg&ndash;Marquardt least squares. Exponential (b = 0), hyperbolic ',
      '(0 &lt; b &lt; 1, capped) and harmonic (b = 1) are each fitted; the model with ',
      'the lowest AIC<sub>c</sub> is reported. The time origin is the first month of the ',
      'fit window, so q<sub>i</sub> is the rate at the start of the analysed decline. ',
      'EUR = cumulative oil produced to date + the closed-form Arps volume from the last ',
      'observed rate down to the stated economic rate. The forecast horizon is shortened ',
      'automatically for weak or short-history fits.')),
    tags$p(class = "subtitle", HTML(
      '<strong>Not reserves in the SPE-PRMS sense.</strong> This is a single-well ',
      'deterministic estimate and does not model field-level abandonment economics, ',
      'infill drilling, or intervention upside.'))
  )
}

.footer <- function() tags$footer(HTML(sprintf(
  'Generated %s by the GeoAI decline-curve engine (R %s). Source data: Equinor Volve ',
  format(Sys.time(), "%Y-%m-%d %H:%M"), as.character(getRversion())),
  'field production data, &copy; Equinor and the former Volve licence partners, ',
  'released under the Equinor Open Data Licence for research and study. ',
  'Charts and estimates are illustrative.'))

# --- single-well report --------------------------------------------

build_report_html <- function(well_id, monthly,
                              q_econ = 50, window = "auto",
                              max_years = 30, b_max = 1.5,
                              brand = default_brand()) {
  f <- fit_decline(dplyr::filter(monthly, well == .env$well_id),
                   q_econ = q_econ, window = window,
                   max_years = max_years, b_max = b_max)

  if (!isTRUE(f$ok)) {
    body <- tagList(
      tags$h1(paste("Well", well_id)),
      div(class = "callout", strong("No decline fit produced. "),
          paste(f$flags, collapse = "; ")),
      .footer())
    return(.doc(paste(brand$company, "-", well_id), brand, body))
  }

  g   <- fit_grade(f$fit_quality$r2)
  chart <- .png_data_uri(plot_decline_fit(f, log_y = TRUE, compact = TRUE))

  params <- data.frame(
    Parameter = c("Decline model", "Fit window", "q\u1d62 at decline start (bopd)",
                  "D\u1d62 nominal (/yr)", "b exponent", "First-year effective decline",
                  "Fit R\u00b2", "Points fitted", "Decline start", "Last observed month",
                  "Last observed rate (bopd)", "Economic rate (bopd)"),
    Value = c(f$model, f$fit_quality$window,
              .fmt(f$params$qi_bopd, 0), .fmt(f$params$Di_nominal_annual, 2),
              .fmt(f$params$b, 2), sprintf("%.0f%%", 100 * f$de_first_year),
              sprintf("%.3f", f$fit_quality$r2), f$fit_quality$n_points,
              format(f$decline_start), format(f$last_date),
              .fmt(f$last_rate_bopd, 0), f$q_econ),
    check.names = FALSE)

  # annual forecast snapshot
  fc_annual <- f$forecast |>
    dplyr::mutate(yr = lubridate::year(date)) |>
    dplyr::group_by(yr) |>
    dplyr::summarise(`Avg rate (bopd)` = round(mean(rate_bopd)),
                     `Year-end rate (bopd)` = round(dplyr::last(rate_bopd)),
                     .groups = "drop") |>
    dplyr::rename(Year = yr)

  flags_node <- if (length(f$flags))
    div(class = "callout", strong("Caveats for this well:"),
        tags$ul(lapply(f$flags, tags$li)))

  body <- tagList(
    tags$h1(paste0("Well ", well_id, " \u2014 production forecast")),
    tags$p(class = "subtitle",
           sprintf("Economic rate %s bopd \u00b7 fit window \u201c%s\u201d \u00b7 horizon %s yr",
                   q_econ, f$fit_quality$window, max_years)),
    div(class = "cards",
      .stat_card("Decline model", f$model, sprintf("R\u00b2 %.2f (%s)", f$fit_quality$r2, g$label)),
      .stat_card("Produced to date", paste0(.fmt(f$np_to_date_bbl / 1e6, 2), " MMbbl")),
      .stat_card("Remaining (forecast)", paste0(.fmt(f$remaining_bbl / 1e6, 2), " MMbbl"),
                 paste("to", format(f$eol_date))),
      .stat_card("EUR",
                 paste0(.fmt(f$eur_mmbbl, 2), " MMbbl"),
                 if (!is.na(f$eur_p90_mmbbl))
                   sprintf("P90 %.1f – P10 %.1f", f$eur_p90_mmbbl, f$eur_p10_mmbbl)) |>
        (\(x) { x$attribs$class <- "card hi"; x })()
    ),
    flags_node,
    tags$h2("Rate vs time \u2014 history and forecast"),
    tags$img(class = "chart", src = chart,
             alt = paste("Decline curve for", well_id)),
    tags$p(class = "subtitle",
           "Grey = monthly history \u00b7 blue = fitted Arps decline \u00b7 red = forecast \u00b7 dashed = economic rate."),
    tags$h2("Fitted parameters"),
    .html_table(params),
    tags$h2("Forecast (annual)"),
    .html_table(fc_annual),
    .methodology(),
    .footer()
  )
  .doc(paste(brand$company, "-", well_id), brand, body)
}

# --- field portfolio report -------------------------------------

build_portfolio_html <- function(monthly,
                                 q_econ = 50, window = "auto",
                                 max_years = 30, b_max = 1.5,
                                 brand = default_brand()) {
  res <- fit_all_wells(monthly, q_econ = q_econ, window = window,
                       max_years = max_years, b_max = b_max)
  ok  <- dplyr::filter(res$summary, ok)

  bard <- ok |>
    dplyr::transmute(well,
                     `Produced to date` = np_to_date_mbbl,
                     `Remaining (forecast)` = remaining_mbbl) |>
    tidyr::pivot_longer(-well, names_to = "component", values_to = "mmbbl")
  bar <- ggplot2::ggplot(bard,
      ggplot2::aes(stats::reorder(well, -mmbbl), mmbbl, fill = component)) +
    ggplot2::geom_col() +
    ggplot2::scale_fill_manual(values = c("Produced to date" = "#37474f",
                                          "Remaining (forecast)" = brand$color)) +
    ggplot2::labs(title = NULL, x = NULL, y = "MMbbl", fill = NULL) +
    theme_geoai()
  bar_uri <- .png_data_uri(bar, width = 9, height = 3.8)

  dash <- "\u2014"
  tab <- res$summary |>
    dplyr::transmute(
      Well = well,
      Model = ifelse(is.na(model), dash, model),
      "R2" = ifelse(ok, sprintf("%.2f", r2), dash),
      "Window" = ifelse(ok, window, dash),
      "Produced (MMbbl)" = ifelse(ok, sprintf("%.2f", np_to_date_mbbl), dash),
      "Remaining (MMbbl)" = ifelse(ok, sprintf("%.2f", remaining_mbbl), dash),
      "EUR (MMbbl)" = ifelse(ok, sprintf("%.2f", eur_mmbbl), dash))
  total <- data.frame(
    Well = "FIELD TOTAL", Model = "", R2 = "", Window = "",
    "Produced (MMbbl)" = sprintf("%.2f", sum(ok$np_to_date_mbbl)),
    "Remaining (MMbbl)" = sprintf("%.2f", sum(ok$remaining_mbbl)),
    "EUR (MMbbl)" = sprintf("%.2f", sum(ok$eur_mmbbl)), check.names = FALSE)
  tab <- rbind(as.data.frame(tab), total)

  anyflag <- dplyr::filter(res$summary, nzchar(flags))
  flags_node <- if (nrow(anyflag))
    div(class = "callout", strong("Wells to read with care:"),
        tags$ul(lapply(seq_len(nrow(anyflag)), function(i)
          tags$li(HTML(paste0("<strong>", anyflag$well[i], "</strong> &mdash; ", anyflag$flags[i]))))))

  body <- tagList(
    tags$h1("Field portfolio \u2014 decline-curve summary"),
    tags$p(class = "subtitle",
           sprintf("%d producing wells \u00b7 economic rate %s bopd \u00b7 fit window \u201c%s\u201d",
                   nrow(ok), q_econ, window)),
    div(class = "cards",
      .stat_card("Wells fitted", nrow(ok)),
      .stat_card("Produced to date", paste0(sprintf("%.1f", sum(ok$np_to_date_mbbl)), " MMbbl")),
      .stat_card("Remaining (forecast)", paste0(sprintf("%.1f", sum(ok$remaining_mbbl)), " MMbbl")),
      .stat_card("Field EUR", paste0(sprintf("%.1f", sum(ok$eur_mmbbl)), " MMbbl")) |>
        (\(x) { x$attribs$class <- "card hi"; x })()
    ),
    tags$h2("EUR by well"),
    tags$img(class = "chart", src = bar_uri, alt = "EUR by well"),
    tags$h2("Per-well parameters"),
    .html_table(tab),
    flags_node,
    .methodology(),
    .footer()
  )
  .doc(paste(brand$company, "- Field portfolio"), brand, body)
}

# --- KAZ-RC-style public reserves report (petroleum adaptation) ----------
#
# The KAZ-RC code and Order MID RK No.374 the user supplied are the *solid
# minerals* public-reporting framework (CRIRSCO family). Kazakhstan oil & gas
# reserves are reported through the State reserve classification (GKZ) and
# PRMS-family categories. This report borrows the KAZ-RC public-report skeleton
# — Competent Person statement, the three principles, an assessment checklist —
# and populates a PRMS 1P/2P/3P table from the P90/P50/P10 EUR. It is an
# ILLUSTRATIVE TEMPLATE, not a filed regulatory document.

build_kazrc_html <- function(well_id, monthly,
                             q_econ = 50, window = "auto", max_years = 30, b_max = 1.5,
                             competent_person = "[Competent Person — name, qualification, professional body]",
                             brand = default_brand()) {
  f <- fit_decline(dplyr::filter(monthly, well == .env$well_id),
                   q_econ = q_econ, window = window, max_years = max_years, b_max = b_max)
  if (!isTRUE(f$ok))
    return(.doc(paste(brand$company, "- KAZ-RC -", well_id), brand,
                tagList(tags$h1(paste("Well", well_id)),
                        div(class = "callout", strong("No estimate produced. "),
                            paste(f$flags, collapse = "; ")), .footer())))

  np   <- f$np_to_date_bbl / 1e6
  p90  <- f$eur_p90_mmbbl %||% f$eur_mmbbl
  p50  <- f$eur_mmbbl
  p10  <- f$eur_p10_mmbbl %||% f$eur_mmbbl
  rr   <- function(x) max(x - np, 0)                       # remaining recoverable

  res_tbl <- data.frame(
    Category = c("Produced to date (Np)",
                 "Proved (1P)  —  ≈ P90",
                 "Proved + Probable (2P)  —  ≈ P50",
                 "Proved + Probable + Possible (3P)  —  ≈ P10"),
    `Confidence` = c("actual", "high (conservative)", "best estimate", "high case"),
    `EUR (MMbbl)` = c(sprintf("%.2f", np), sprintf("%.2f", p90),
                      sprintf("%.2f", p50), sprintf("%.2f", p10)),
    `Remaining recoverable (MMbbl)` = c("—", sprintf("%.2f", rr(p90)),
                                        sprintf("%.2f", rr(p50)), sprintf("%.2f", rr(p10)),
                                        check.names = FALSE),
    check.names = FALSE)

  bt <- tryCatch(backtest_well(dplyr::filter(monthly, well == .env$well_id),
                               holdout_months = 6, q_econ = q_econ, window = window,
                               max_years = max_years, b_max = b_max),
                 error = function(e) list(ok = FALSE))
  bt_txt <- if (isTRUE(bt$ok))
    sprintf("6-month blind back-test: mean abs. error %.0f%%, bias %+.0f%%.",
            100 * bt$mape, 100 * bt$bias) else "Back-test not available (insufficient history)."

  check_tbl <- data.frame(
    Criterion = c("Data source & integrity", "Measurement", "Estimation method",
                  "Key assumptions", "Uncertainty treatment", "Fit quality",
                  "Classification basis", "Audit / verification status"),
    Commentary = c(
      "Monthly oil production history for the well; source dataset as loaded into the tool.",
      "Volumetric production as reported; no re-metering or allocation review performed here.",
      sprintf("Arps decline-curve analysis (%s model, window “%s”), Levenberg–Marquardt fit; EUR by closed-form Arps cumulative to the economic rate.",
              f$model, f$fit_quality$window),
      sprintf("Economic rate %s bopd; forecast horizon cap %s yr; time origin = start of the fitted decline.",
              q_econ, max_years),
      "P90/P50/P10 from parameter-covariance sampling (~300 draws) plus residual-scaled scatter.",
      sprintf("R² = %.2f on %d fitted months. %s", f$fit_quality$r2, f$fit_quality$n_points, bt_txt),
      "1P/2P/3P mapped from P90/P50/P10 EUR per PRMS convention.",
      "Not independently audited. No State expertise (GKZ) or Competent Person sign-off obtained.")
  )

  body <- tagList(
    tags$h1(paste0("Public Report — Petroleum Reserves (KAZ-RC-style template)")),
    tags$p(class = "subtitle", paste0("Well ", well_id, "  ·  prepared ",
                                      format(Sys.Date(), "%Y-%m-%d"))),
    div(class = "callout",
        strong("Status: illustrative template, not a filed report. "),
        "The KAZ-RC code and Order MID RK No.374/2018 are the ", strong("solid-minerals"),
        " public-reporting framework. Kazakhstan petroleum reserves are reported through the ",
        "State reserve classification (ГКЗ) and PRMS-family categories; the filed ",
        "template and a licensed Competent Person / State expertise are required."),
    tags$h2("Competent Person"),
    tags$p(competent_person, tags$br(),
           tags$span(class = "subtitle",
                     "This report must not be issued without the written consent of a Competent Person as to its form, content and date.")),
    tags$h2("Principles"),
    tags$p(HTML("<strong>Transparency</strong> — the reader is given enough clear information to understand the report and is not misled. <strong>Materiality</strong> — it contains the information a reader reasonably needs to form a balanced judgement. <strong>Competence</strong> — it is based on work by suitably qualified and experienced persons bound by a professional code of ethics.")),
    tags$h2("1. The asset"),
    tags$p(sprintf("Well %s. Producing history %s to %s (%d producing months). Last observed oil rate %s bopd. Cumulative oil produced to date %.2f MMbbl.",
                   well_id, format(min(f$series$date[f$series$phase == "history"])),
                   format(f$last_date), f$fit_quality$n_points,
                   formatC(round(f$last_rate_bopd), big.mark = ","), np)),
    tags$h2("2. Basis of estimate"),
    tags$p(sprintf("Estimated ultimate recovery (EUR) is derived by decline-curve analysis on the monthly oil rate. Best-estimate (2P) EUR is %.2f MMbbl, of which %.2f MMbbl remains to be produced to an economic limit of %s bopd. Low (1P) and high (3P) cases are %.2f and %.2f MMbbl.",
                   p50, rr(p50), q_econ, p90, p10)),
    tags$h2("3. Reserve classification"),
    .html_table(res_tbl),
    tags$h2("4. Assessment checklist"),
    .html_table(check_tbl),
    tags$h2("5. Caveats"),
    tags$ul(
      tags$li("Single-well decline-curve analysis; no field-level abandonment economics, infill or intervention upside."),
      tags$li("Deterministic decline with a sampled uncertainty band — not a full probabilistic reserves study."),
      tags$li("Not reserves as certified under SPE-PRMS or the Kazakhstan State classification. No Competent Person sign-off."),
      if (length(f$flags)) tags$li(paste("Model flags:", paste(f$flags, collapse = "; ")))
    ),
    .footer()
  )
  .doc(paste(brand$company, "- KAZ-RC -", well_id), brand, body)
}

# --- file writers ---------------------------------------------

render_report_file <- function(path, well_id, monthly, ...) {
  writeLines(build_report_html(well_id, monthly, ...), path, useBytes = TRUE)
  invisible(path)
}

render_all_reports <- function(dir = "outputs/reports", monthly, ...) {
  ensure_dir(dir)
  wells <- sort(unique(monthly$well))
  safe  <- function(x) gsub("[^A-Za-z0-9]+", "_", x)
  paths <- character(0)
  for (w in wells) {
    p <- file.path(dir, paste0("report_", safe(w), ".html"))
    writeLines(build_report_html(w, monthly, ...), p, useBytes = TRUE)
    paths <- c(paths, p)
  }
  pp <- file.path(dir, "report_field_portfolio.html")
  writeLines(build_portfolio_html(monthly, ...), pp, useBytes = TRUE)
  c(paths, pp)
}

# --- optional: HTML -> PDF via a headless browser (local only) ---

.find_browser <- function() {
  pf   <- c(Sys.getenv("ProgramFiles"), Sys.getenv("ProgramFiles(x86)"),
            "/c/Program Files", "/c/Program Files (x86)")
  rel  <- c(file.path("Google", "Chrome", "Application", "chrome.exe"),
            file.path("Microsoft", "Edge", "Application", "msedge.exe"),
            file.path("Chromium", "Application", "chrome.exe"))
  win  <- as.vector(outer(pf[nzchar(pf)], rel, file.path))
  cand <- c(Sys.getenv("CHROMOTE_CHROME"), win,
            Sys.which(c("google-chrome", "chromium-browser", "chrome", "msedge")))
  cand <- cand[nzchar(cand) & file.exists(cand)]
  if (length(cand)) cand[1] else NA_character_
}

html_to_pdf <- function(html_path, pdf_path, tries = 2) {
  br <- .find_browser()
  if (is.na(br)) { message("No Chrome/Edge found; keeping HTML only."); return(FALSE) }
  url <- paste0("file:///", normalizePath(html_path, winslash = "/", mustWork = TRUE))
  for (i in seq_len(tries)) {
    udd <- file.path(tempdir(), paste0("edge_pdf_", as.integer(runif(1, 1, 1e8))))
    args <- c("--headless=new", "--disable-gpu", "--no-first-run",
              paste0("--user-data-dir=", udd), "--no-pdf-header-footer",
              "--virtual-time-budget=8000",
              paste0("--print-to-pdf=", normalizePath(pdf_path, winslash = "/", mustWork = FALSE)),
              url)
    ok <- tryCatch(
      system2(br, shQuote(args), stdout = FALSE, stderr = FALSE, timeout = 90) == 0,
      error = function(e) FALSE)
    unlink(udd, recursive = TRUE, force = TRUE)
    if (isTRUE(ok) && file.exists(pdf_path)) return(TRUE)
  }
  FALSE
}
