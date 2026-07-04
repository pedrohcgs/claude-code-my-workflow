# =============================================================================
# tests/test_returns.R — Self-contained unit tests for functions_returns.R.
#
# Base-R only (no testthat dependency) so it runs anywhere:
#     Rscript tests/test_returns.R
# Exit code 0 = all pass, 1 = a failure. Verifies the IPO return logic on
# synthetic inputs with KNOWN answers, independent of any live data access.
# =============================================================================

# Locate and source the functions relative to this file.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
root <- if (length(file_arg)) normalizePath(file.path(dirname(file_arg), "..")) else normalizePath("..")
source(file.path(root, "scripts", "R", "functions_returns.R"))

.n_pass <- 0L; .n_fail <- 0L
check <- function(desc, cond) {
  if (isTRUE(cond)) {
    .n_pass <<- .n_pass + 1L
    cat(sprintf("  ok   %s\n", desc))
  } else {
    .n_fail <<- .n_fail + 1L
    cat(sprintf("  FAIL %s\n", desc))
  }
}
approx <- function(a, b, tol = 1e-8) all(abs(a - b) < tol)

cat("test_returns.R\n")

# ---- compute_underpricing ----
check("underpricing: raw = close/offer - 1",
      approx(compute_underpricing(12, 10), 0.2))
check("underpricing: market-adjusted subtracts market return",
      approx(compute_underpricing(12, 10, market_return = 0.05), 0.15))
check("underpricing: non-positive offer -> NA",
      is.na(compute_underpricing(12, 0)))
check("underpricing: vectorised",
      approx(compute_underpricing(c(11, 20), c(10, 10)), c(0.1, 1.0)))

# ---- buy_and_hold_return ----
check("BH: compounds correctly",
      approx(buy_and_hold_return(c(0.1, 0.1)), 0.21))
check("BH: NA propagates by default",
      is.na(buy_and_hold_return(c(0.1, NA))))
check("BH: na.rm=TRUE ignores NA",
      approx(buy_and_hold_return(c(0.1, NA, 0.1), na.rm = TRUE), 0.21))

# ---- compute_bhar / compute_car ----
check("BHAR: firm minus benchmark buy-and-hold",
      approx(compute_bhar(c(0.1, 0.1), c(0.05, 0.05)), 0.21 - 0.1025))
check("BHAR: unequal lengths error",
      inherits(try(compute_bhar(c(0.1), c(0.1, 0.2)), silent = TRUE), "try-error"))
check("CAR: sums abnormal returns",
      approx(compute_car(c(0.02, -0.01, 0.03)), 0.04))

# ---- fill_delisting_return (Shumway) ----
# dlstcd 500 (perf-related) with missing dlret: NYSE(1)/AMEX(2) -> -0.30, Nasdaq(3) -> -0.55.
fd <- fill_delisting_return(
  dlret  = c(NA, NA, NA, 0.1),
  dlstcd = c(500L, 500L, 233L, 500L),   # 233 = merger (not perf-related)
  exchcd = c(1L, 3L, 3L, 1L)
)
check("delist fill: NYSE perf-missing -> -0.30", approx(fd[1], -0.30))
check("delist fill: Nasdaq perf-missing -> -0.55", approx(fd[2], -0.55))
check("delist fill: non-perf code left NA", is.na(fd[3]))
check("delist fill: recorded dlret untouched", approx(fd[4], 0.1))

# ---- fold_delisting_return ----
check("fold delisting: (1+BH)(1+dlret)-1",
      approx(fold_delisting_return(c(0.1, 0.1), -0.5), (1.21 * 0.5) - 1))
check("fold delisting: NA dlret treated as 0",
      approx(fold_delisting_return(c(0.1, 0.1), NA), 0.21))

# ---- calendar_time_alpha (recovers a known intercept) ----
set.seed(1L)
nmo <- 240L
mkt <- rnorm(nmo, 0.006, 0.04)
true_alpha <- 0.003
port <- true_alpha + 1.1 * mkt + rnorm(nmo, 0, 0.001)  # tiny noise
res <- calendar_time_alpha(port, data.frame(mktrf = mkt))
check("calendar-time alpha: recovers intercept", approx(res$alpha, true_alpha, tol = 5e-4))
check("calendar-time alpha: returns se and t", is.finite(res$se) && is.finite(res$t))

# ---- ince_porter_reversal ----
# A spurious 400% spike then reversal in the middle should be flagged; a genuine
# IPO first-day pop (is_first) should be exempt.
ret <- c(4.0, -0.7, 0.01, 0.02)          # month1 pop, month2 crash (reversal pair)
flag_first_exempt <- ince_porter_reversal(ret, is_first = c(TRUE, FALSE, FALSE, FALSE))
check("Ince-Porter: first-day pop exempt", isFALSE(flag_first_exempt[1]))
ret2 <- c(0.01, 4.0, -0.8, 0.02)          # +400% (mo2) then -80% (mo3): (5.0)(0.2)-1 = 0 < 0.5
flag2 <- ince_porter_reversal(ret2, is_first = c(TRUE, FALSE, FALSE, FALSE))
# The reversal PAIR is months 2 (spike) and 3 (crash) — both flagged; month 4 clean.
# (Checks the shift DIRECTION: t-1 partner, not t+1.)
check("Ince-Porter: spike month (2) flagged", isTRUE(flag2[2]))
check("Ince-Porter: crash month (3) flagged", isTRUE(flag2[3]))
check("Ince-Porter: post-reversal month (4) NOT flagged", isFALSE(flag2[4]))

# ---- winsorize ----
w <- winsorize(c(-100, 1:98, 100), p = 0.02)
check("winsorize: caps extremes", max(w) < 100 && min(w) > -100)
check("winsorize: bad p errors",
      inherits(try(winsorize(1:10, p = 0.9), silent = TRUE), "try-error"))

# ---- summary ----
cat(sprintf("\n%d passed, %d failed\n", .n_pass, .n_fail))
if (.n_fail > 0L) quit(status = 1L, save = "no")
