# truncate_to_topn collapses long-tail groups (e.g. 900+ Metro Areas)
# into a single "Other (k)" row by ranking on value_col across other
# dimensions. The legend would otherwise overflow and ggiraph would
# render hundreds of paths.

test_that("returns table unchanged when groups <= n", {
  df <- tibble::tibble(
    Year = c(2022, 2022, 2022),
    Metro = c("A", "B", "C"),
    Value = c(10, 20, 30)
  )
  out <- truncate_to_topn(df, group_col = "Metro", value_col = "Value", n = 15)
  expect_equal(nrow(out), 3)
  expect_setequal(out$Metro, c("A", "B", "C"))
})

test_that("keeps top-N and lumps remainder into Other (k)", {
  df <- tibble::tibble(
    Year = rep(2022L, 20),
    Metro = paste0("M", sprintf("%02d", 1:20)),
    Value = 20:1  # M01=20 (largest), M20=1 (smallest)
  )
  out <- truncate_to_topn(df, group_col = "Metro", value_col = "Value", n = 15)
  # 15 top + 1 Other row
  expect_equal(nrow(out), 16)
  expect_true("Other (5)" %in% out$Metro)
  # Sum of the 5 smallest values (M16..M20 → 5,4,3,2,1) = 15
  expect_equal(out$Value[out$Metro == "Other (5)"], 15)
  # Top group preserved
  expect_true("M01" %in% out$Metro)
})

test_that("preserves the Year axis when collapsing", {
  # Two years × 20 metros; truncation should keep per-year totals
  df <- tibble::tibble(
    Year = rep(c(2021L, 2022L), each = 20),
    Metro = rep(paste0("M", sprintf("%02d", 1:20)), 2),
    Value = c(20:1, 20:1)
  )
  out <- truncate_to_topn(df, group_col = "Metro", value_col = "Value", n = 15)
  # 16 groups per year
  expect_equal(nrow(out), 32)
  per_year <- out |>
    dplyr::group_by(Year) |>
    dplyr::summarise(total = sum(Value), .groups = "drop")
  expect_equal(per_year$total, c(sum(20:1), sum(20:1)))
})

test_that("ranks by total across years (not single-year peaks)", {
  # M_BIG has high value only in one year; M_STEADY has steady mid value
  # across two years. With n=1, ranking by total should pick M_STEADY
  # because 50+50=100 > 90 from M_BIG alone.
  df <- tibble::tibble(
    Year = c(2021L, 2022L, 2021L, 2022L),
    Metro = c("M_BIG", "M_BIG", "M_STEADY", "M_STEADY"),
    Value = c(90, 0, 50, 50)
  )
  out <- truncate_to_topn(df, group_col = "Metro", value_col = "Value", n = 1)
  expect_true("M_STEADY" %in% out$Metro)
  expect_true(any(grepl("^Other", out$Metro)))
})

test_that("sums extra_sum_cols alongside value_col when collapsing", {
  # Simulates the proportion case: rank by Nonprofits, also sum HasDAF.
  df <- tibble::tibble(
    Year = rep(2022L, 5),
    Metro = c("A", "B", "C", "D", "E"),
    HasDAF = c(10, 8, 6, 4, 2),
    Nonprofits = c(100, 80, 60, 40, 20)
  )
  out <- truncate_to_topn(
    df,
    group_col = "Metro",
    value_col = "Nonprofits",
    n = 2,
    extra_sum_cols = "HasDAF"
  )
  # Top 2 (A=100, B=80) + Other (C+D+E)
  expect_equal(nrow(out), 3)
  other_row <- out[out$Metro == "Other (3)", ]
  expect_equal(other_row$Nonprofits, 60 + 40 + 20)
  expect_equal(other_row$HasDAF, 6 + 4 + 2)
})

test_that("NULL or empty table is passed through unchanged", {
  expect_null(truncate_to_topn(NULL, "Metro", "Value"))
  empty <- tibble::tibble(Metro = character(), Value = numeric())
  expect_equal(nrow(truncate_to_topn(empty, "Metro", "Value")), 0)
})

test_that("missing group_col is a no-op (defensive guard)", {
  df <- tibble::tibble(Year = 2022L, Value = 1)
  out <- truncate_to_topn(df, group_col = "Metro", value_col = "Value")
  expect_identical(out, df)
})
