# caption_pf appends the 2016-2018 IRS-gap disclosure only for the Core
# Series PF Grants metric. It must NOT fire for other private-foundation
# panels (notably PRI, which is also PF-restricted but only spans
# 2021-2023), nor for non-PF org types.

test_that("PF Grants (private foundations + Total Contributions) gets the gap note", {
  out <- caption_pf("", "501(c)(3) - Private Foundations", "Total Contributions")
  expect_true(grepl("2016 through 2018", out))
})

test_that("PRI metric does not get the gap note even when PF-restricted", {
  out <- caption_pf("", "501(c)(3) - Private Foundations",
                    "Total Program-Related Investments")
  expect_false(grepl("2016 through 2018", out))
})

test_that("non-PF org type does not get the gap note", {
  out <- caption_pf("", "501(c)(3) - Public Charities", "Total Contributions")
  expect_false(grepl("2016 through 2018", out))
})
