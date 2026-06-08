# geo_filter_module helpers: code-keyed, de-duplicated dropdown choices
# and the code->name resolution used for chips/captions/notes (ADR 0021).

geo_df_fixture <- function() {
  data.frame(
    Census.State     = c("MI", "MI", "MI", "MO", "MO"),
    Census.County    = c("Wayne County", "Monroe County", "Alcona County",
                         "Jackson County", "Cass County"),
    County.FIPS      = c("26163", "26115", "26001", "29095", "29037"),
    Metro.Micro.Area = c("Detroit-Warren-Dearborn, MI", "Monroe, MI", NA,
                         "Kansas City, MO-KS", "Kansas City, MO-KS"),
    CBSA.Code        = c("19820", "33780", NA, "28140", "28140"),
    Census.Region    = rep("Midwest", 5),
    CBSA.Type        = c("Metropolitan Statistical Area",
                         "Micropolitan Statistical Area", NA,
                         "Metropolitan Statistical Area",
                         "Metropolitan Statistical Area"),
    stringsAsFactors = FALSE,
    check.names      = FALSE
  )
}

test_that("geo_named_choices returns label=name, value=code for a state's counties", {
  ch <- geo_named_choices(geo_df_fixture(), "MI", "County.FIPS", "Census.County")
  expect_equal(unname(ch[["Wayne County"]]), "26163")
  expect_setequal(names(ch), c("Wayne County", "Monroe County", "Alcona County"))
  expect_type(ch, "character")
})

test_that("metro choices are de-duplicated by CBSA code (one row per metro)", {
  ch <- geo_named_choices(geo_df_fixture(), "MO", "CBSA.Code", "Metro.Micro.Area")
  # Two MO counties share the Kansas City CBSA — it must appear once.
  expect_equal(length(ch), 1)
  expect_equal(unname(ch), "28140")
  expect_equal(names(ch), "Kansas City, MO-KS")
})

test_that("CBSA Type narrows the metro list to Metropolitan vs Micropolitan", {
  g <- geo_df_fixture()
  all_mi   <- geo_named_choices(g, "MI", "CBSA.Code", "Metro.Micro.Area", type = "All")
  metro_mi <- geo_named_choices(g, "MI", "CBSA.Code", "Metro.Micro.Area",
                                type = "Metropolitan Statistical Area")
  micro_mi <- geo_named_choices(g, "MI", "CBSA.Code", "Metro.Micro.Area",
                                type = "Micropolitan Statistical Area")
  expect_setequal(names(all_mi), c("Detroit-Warren-Dearborn, MI", "Monroe, MI"))
  expect_equal(names(metro_mi), "Detroit-Warren-Dearborn, MI")
  expect_equal(names(micro_mi), "Monroe, MI")
})

test_that("geo_code_to_name resolves selected codes back to display names", {
  g <- geo_df_fixture()
  expect_equal(
    geo_code_to_name(c("26163", "26115"), g, "County.FIPS", "Census.County"),
    c("Wayne County", "Monroe County")
  )
  expect_equal(
    geo_code_to_name("28140", g, "CBSA.Code", "Metro.Micro.Area"),
    "Kansas City, MO-KS"
  )
  expect_length(geo_code_to_name(character(0), g, "County.FIPS", "Census.County"), 0)
})

test_that("geo_code_to_name falls back to the raw code when unmatched", {
  expect_equal(
    geo_code_to_name("99999", geo_df_fixture(), "County.FIPS", "Census.County"),
    "99999"
  )
})

test_that("geo_filter_server exposes county_label/cbsa_label resolving codes to names", {
  shiny::testServer(
    geo_filter_server,
    args = list(geo_df = geo_df_fixture()),
    {
      session$setInputs(county = c("26163", "26115"))
      expect_equal(session$returned$county_label(),
                   c("Wayne County", "Monroe County"))
      session$setInputs(cbsa = "28140")
      expect_equal(session$returned$cbsa_label(), "Kansas City, MO-KS")
    }
  )
})
