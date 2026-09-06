# 09_las.R — minimal LAS 2.0 well-log reader + basic curve QC (base R only).
#
#   read_las(path)            -> list(well = <meta tbl>, curves = <chr>, units, data = <tbl>)
#   las_qc(las)               -> per-curve QC tibble (null %, range, spikes, monotonic depth)
#   normalize_curve(x, lo, hi)-> min-max normalised copy of a curve
#   guess_track(curve_names)  -> which curves are GR / resistivity / density / neutron / sonic / caliper

source("R/utils.R")   # %||%, dplyr

read_las <- function(path) {
  raw <- readLines(path, warn = FALSE, encoding = "latin1")
  raw <- raw[!grepl("^\\s*#", raw)]                      # strip comments
  sec <- toupper(trimws(sub("^~\\s*", "", raw[grepl("^~", raw)])))
  idx <- which(grepl("^~", raw))
  sec_of <- function(name) {
    hit <- idx[grepl(name, sec)]
    if (!length(hit)) return(integer(0))
    start <- hit[1] + 1
    nxt <- idx[idx > hit[1]]
    end <- if (length(nxt)) nxt[1] - 1 else length(raw)
    if (end < start) integer(0) else start:end
  }
  parse_kv <- function(lines) {
    lines <- lines[nzchar(trimws(lines))]
    m <- regmatches(lines, regexec(
      "^\\s*([^.]+?)\\s*\\.([^ \t]*)\\s+(.*?)\\s*:\\s*(.*)$", lines))
    keep <- vapply(m, length, 1L) == 5
    if (!any(keep)) return(tibble::tibble())
    m <- m[keep]
    tibble::tibble(
      mnem = trimws(vapply(m, `[`, "", 2)),
      unit = trimws(vapply(m, `[`, "", 3)),
      value = trimws(vapply(m, `[`, "", 4)),
      descr = trimws(vapply(m, `[`, "", 5)))
  }

  well_tbl  <- parse_kv(raw[sec_of("WELL")])
  curve_tbl <- parse_kv(raw[sec_of("CURVE")])
  if (!nrow(curve_tbl)) stop("No ~CURVE section found — is this a LAS 2.0 file?")

  # ~ASCII data
  a <- sec_of("ASCII|^A$| A ")
  if (!length(a)) a <- sec_of("^A")
  dat_lines <- raw[a]
  dat_lines <- dat_lines[nzchar(trimws(dat_lines))]
  nums <- lapply(strsplit(trimws(dat_lines), "\\s+"), as.numeric)
  ncol <- nrow(curve_tbl)
  nums <- nums[vapply(nums, length, 1L) == ncol]
  if (!length(nums)) stop("Could not parse the ~ASCII data block.")
  mat <- do.call(rbind, nums)
  colnames(mat) <- curve_tbl$mnem

  # NULL value
  nullv <- suppressWarnings(as.numeric(
    well_tbl$value[toupper(well_tbl$mnem) %in% c("NULL", "NULL.")]))
  nullv <- if (length(nullv) && is.finite(nullv[1])) nullv[1] else -999.25
  mat[mat == nullv] <- NA

  list(well = well_tbl, curves = curve_tbl$mnem, units = curve_tbl$unit,
       data = tibble::as_tibble(mat), null = nullv, nrows = nrow(mat))
}

guess_track <- function(nm) {
  u <- toupper(nm)
  list(
    depth = nm[grepl("^DEPT|^DEPTH|^MD$|^TVD", u)][1],
    gr    = nm[grepl("GR|GAMMA", u)][1],
    res   = nm[grepl("RES|ILD|LLD|RT$|RESD|AT90|M2R", u)],
    rhob  = nm[grepl("RHOB|DEN$|DENS|ZDEN", u)][1],
    nphi  = nm[grepl("NPHI|NEU|TNPH|PHIN", u)][1],
    sonic = nm[grepl("^DT|SONIC|AC$", u)][1],
    cali  = nm[grepl("CALI|CAL$|HCAL", u)][1]
  )
}

las_qc <- function(las) {
  d <- las$data
  g <- guess_track(las$curves)
  depth_col <- g$depth %||% names(d)[1]
  dplyr::bind_rows(lapply(names(d), function(cn) {
    x <- d[[cn]]
    n <- length(x); nna <- sum(is.na(x))
    fin <- x[is.finite(x)]
    dx <- if (length(fin) > 5) abs(diff(fin)) else numeric(0)
    spike <- if (length(dx)) sum(dx > (stats::median(dx, na.rm = TRUE) +
                                       6 * stats::mad(dx, na.rm = TRUE)), na.rm = TRUE) else 0L
    tibble::tibble(
      curve = cn, unit = las$units[match(cn, las$curves)],
      null_pct = round(100 * nna / n, 1),
      min = if (length(fin)) round(min(fin), 2) else NA_real_,
      max = if (length(fin)) round(max(fin), 2) else NA_real_,
      spikes = as.integer(spike),
      flag = dplyr::case_when(
        nna / n > 0.5              ~ "mostly null",
        cn == depth_col && any(diff(fin) <= 0) ~ "depth not monotonic",
        grepl("GR|GAMMA", toupper(cn)) && length(fin) && max(fin) > 400 ~ "GR out of range (>400)",
        grepl("RHOB|DENS", toupper(cn)) && length(fin) && (min(fin) < 1 | max(fin) > 3.5) ~ "density out of range",
        spike > 0                  ~ sprintf("%d spike(s)", spike),
        TRUE                       ~ "ok")
    )
  }))
}

normalize_curve <- function(x, lo = NULL, hi = NULL) {
  fin <- x[is.finite(x)]
  if (!length(fin)) return(x)
  lo <- lo %||% stats::quantile(fin, 0.05, names = FALSE)
  hi <- hi %||% stats::quantile(fin, 0.95, names = FALSE)
  if (hi <= lo) return(x)
  pmin(pmax((x - lo) / (hi - lo), 0), 1)
}
