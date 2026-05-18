library(shinytest2)

test_that("{shinytest2} recording: number_overall_all", {
  app <- AppDriver$new(variant = platform_variant(), name = "number_overall_all", 
      height = 893, width = 1619, load_timeout = 6000)
  app$set_inputs(`data_download-accordion` = character(0))
  app$set_inputs(tabs = "Numbers")
  Sys.sleep(100)
  app$set_window_size(width = 1619, height = 893)
  app$expect_screenshot()
})
