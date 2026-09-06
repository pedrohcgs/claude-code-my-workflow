# 08_ml.R — a small, honest gradient-boosted model for well "attention".
#
# TARGET (computable from production alone, no fabricated labels):
#   for each well-month t with >=12 months of prior history, does the well's
#   average oil rate over months t+1..t+6 fall more than THRESH below what a
#   decline curve fitted on data up to t would predict?  (1 = yes, "underperforms")
#
# FEATURES at month t: rate level & shape, water-cut level & trend, cumulative
# oil, months on production. All available in real time.
#
# This demonstrates the ML capability truthfully. On a 6-well field the sample is
# small and autocorrelated, so the reported CV AUC is illustrative, not a
# production benchmark — the app says so.
#
#   ml_build_training(monthly, thresh, horizon)      -> data.frame (features + y + well/month)
#   ml_train(train_df, nrounds)                       -> list(model, auc, features, ...)
#   ml_score_current(model, monthly)                  -> per-well risk + SHAP contributions

source("R/03_decline_curve.R")
.ml_pkg <- requireNamespace("xgboost", quietly = TRUE)

ML_FEATURES <- c("rate", "log_rate", "decl_3mo", "decl_6mo", "rate_vs_12mo",
                 "wct", "wct_trend_6mo", "cum_oil_mbbl", "months_prod")

.feat_at <- function(d, t) {
  r  <- d$oil_rate_bopd[seq_len(t)]
  wc <- if ("wct" %in% names(d)) d$wct[seq_len(t)] else rep(NA_real_, t)
  dd <- function(k) if (t > k && is.finite(r[t - k]) && r[t - k] > 0)
    1 - (r[t] / r[t - k])^(12 / k) else NA_real_
  sl <- function(y) { y <- utils::tail(y, 6); ok <- is.finite(y)
    if (sum(ok) < 3) NA_real_
    else unname(stats::coef(stats::lm(y[ok] ~ seq_along(y)[ok]))[2]) * 12 }
  data.frame(
    rate          = as.numeric(r[t]),
    log_rate      = log10(max(r[t], 1)),
    decl_3mo      = dd(3),
    decl_6mo      = dd(6),
    rate_vs_12mo  = if (t > 12 && is.finite(r[t - 12]) && r[t - 12] > 0) r[t] / r[t - 12] else NA_real_,
    wct           = as.numeric(wc[t]),
    wct_trend_6mo = sl(wc),
    cum_oil_mbbl  = if ("cum_oil_bbl" %in% names(d)) d$cum_oil_bbl[t] / 1e6 else NA_real_,
    months_prod   = as.numeric(t)
  )
}

ml_build_training <- function(monthly, thresh = 0.15, horizon = 6, min_hist = 12, ...) {
  wells <- sort(unique(monthly$well))
  rows <- list()
  for (w in wells) {
    d <- monthly |> dplyr::filter(well == w, oil_rate_bopd > 0, is.finite(oil_rate_bopd)) |>
      dplyr::arrange(month)
    n <- nrow(d)
    if (n < min_hist + horizon + 1) next
    for (t in min_hist:(n - horizon)) {
      f  <- tryCatch(fit_decline(d[seq_len(t), ], ...), error = function(e) NULL)
      if (is.null(f) || !isTRUE(f$ok)) next
      fut_t <- as.numeric(d$month[(t + 1):(t + horizon)] - f$decline_start) / DAYS_PER_YEAR
      pred  <- arps_rate(fut_t, f$params$qi_bopd, f$params$Di_nominal_annual, f$params$b)
      act   <- d$oil_rate_bopd[(t + 1):(t + horizon)]
      if (!all(is.finite(pred)) || mean(pred) <= 0) next
      y <- as.integer(mean(act) < (1 - thresh) * mean(pred))
      fr <- .feat_at(d, t)
      fr$y <- y; fr$well <- w; fr$month <- as.character(d$month[t])
      rows[[length(rows) + 1]] <- fr
    }
  }
  if (!length(rows)) return(data.frame())
  dplyr::bind_rows(rows)
}

# stable low-level xgboost (works across the 1.x / 3.x API split)
.xgb_fit <- function(X, y, nrounds) {
  dtr <- xgboost::xgb.DMatrix(data = X, label = y, missing = NA)
  xgboost::xgb.train(
    params = list(objective = "binary:logistic", max_depth = 3, eta = 0.08,
                  subsample = 0.9, colsample_bytree = 0.9, nthread = 1),
    data = dtr, nrounds = nrounds, verbose = 0)
}

ml_train <- function(train_df, nrounds = 120, ...) {
  if (!.ml_pkg) return(list(ok = FALSE, note = "xgboost not installed"))
  tr <- train_df[stats::complete.cases(train_df[ML_FEATURES]), ]
  if (nrow(tr) < 30 || length(unique(tr$y)) < 2)
    return(list(ok = FALSE, note = "not enough labelled data to train"))
  X <- as.matrix(tr[ML_FEATURES]); storage.mode(X) <- "double"
  y <- as.numeric(tr$y)
  set.seed(42)
  wl <- unique(tr$well); folds <- split(seq_len(nrow(tr)), match(tr$well, wl))
  preds <- rep(NA_real_, nrow(tr))
  for (te in folds) {
    if (length(unique(y[-te])) < 2) next
    m <- .xgb_fit(X[-te, , drop = FALSE], y[-te], nrounds)
    preds[te] <- predict(m, X[te, , drop = FALSE])
  }
  auc <- .auc(y[is.finite(preds)], preds[is.finite(preds)])
  full <- .xgb_fit(X, y, nrounds)
  imp  <- tryCatch(xgboost::xgb.importance(model = full,
                                           feature_names = ML_FEATURES),
                   error = function(e) NULL)
  list(ok = TRUE, model = full, features = ML_FEATURES, auc = auc,
       n = nrow(tr), pos_rate = mean(y), importance = imp,
       note = sprintf("well-grouped CV AUC %.2f on %d well-months (%.0f%% flagged positive)",
                      auc, nrow(tr), 100 * mean(y)))
}

.auc <- function(y, p) {
  n1 <- sum(y == 1); n0 <- sum(y == 0)
  if (n1 == 0 || n0 == 0) return(NA_real_)
  r <- rank(p); (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

# score every well at its latest month + SHAP feature contributions
ml_score_current <- function(trained, monthly) {
  if (!isTRUE(trained$ok)) return(NULL)
  wells <- sort(unique(monthly$well)); rows <- list()
  for (w in wells) {
    d <- monthly |> dplyr::filter(well == w, oil_rate_bopd > 0, is.finite(oil_rate_bopd)) |>
      dplyr::arrange(month)
    if (nrow(d) < 6) next
    rows[[w]] <- .feat_at(d, nrow(d))
  }
  if (!length(rows)) return(NULL)
  X <- as.matrix(dplyr::bind_rows(rows)[, trained$features, drop = FALSE])
  storage.mode(X) <- "double"; X[!is.finite(X)] <- NA
  risk    <- as.numeric(predict(trained$model, X))
  contrib <- predict(trained$model, X, predcontrib = TRUE)
  colnames(contrib) <- c(trained$features, "BIAS")
  list(well = names(rows), risk = risk, contrib = contrib)
}
