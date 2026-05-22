# Boot smoke test: can app() construct a shinyApp object from a clean
# staged tree?
#
# This catches the class of bug that unit tests miss: namespace
# qualification drift, UI tag assembly errors, or any breakage along
# the static boot path (ensure_data_local → publish_data_dictionary →
# visualpanel_mapper → page_navbar construction). pkgload::load_all()
# alone catches source-level errors but not invocation-time ones.
#
# The test never starts a server; it only calls app() to construct.

test_that("app() constructs a shinyApp object on a clean staged tree", {
  stage_app_fixtures()
  obj <- app()
  expect_s3_class(obj, "shiny.appobj")
  # Sanity: both halves are present
  expect_true(is.function(obj$serverFuncSource()))
  expect_true(length(obj$httpHandler) > 0 || !is.null(obj$ui))
})
