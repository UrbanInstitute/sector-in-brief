# Entry point for `testthat::test_local()` and `R CMD check`.
# Sources `R/` via load_all(), then runs the testthat suite under tests/testthat/.
library(testthat)
pkgload::load_all(".", quiet = TRUE)
test_dir("tests/testthat", reporter = "summary", stop_on_failure = FALSE)
