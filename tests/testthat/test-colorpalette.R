# colorpalette: returns exactly N brand-aligned colours. The ≤8 branch
# must subset the anchor palette to `num_colors`, not return all 8 —
# scale_*_manual is fed one colour per group and silently mis-maps if
# handed extras.

test_that("returns exactly num_colors from the brand anchors when <= 8", {
  for (n in 1:8) {
    out <- colorpalette(n)
    expect_length(out, n)
    expect_identical(out, urbnpalette[seq_len(n)])
  }
})

test_that("interpolates beyond the 8 anchor colours", {
  out <- colorpalette(12)
  expect_length(out, 12)
  # endpoints stay pinned to the brand anchors (colorRampPalette upper-cases hex)
  expect_identical(toupper(out[1]), toupper(urbnpalette[1]))
  expect_identical(toupper(out[12]), toupper(urbnpalette[length(urbnpalette)]))
})

test_that("honours a custom anchor palette", {
  pal <- c("#111111", "#222222", "#333333")
  expect_identical(colorpalette(2, palette = pal), pal[1:2])
})
