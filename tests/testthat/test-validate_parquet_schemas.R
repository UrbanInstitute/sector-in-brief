# Schema-contract enforcement at app boot. Producer schema drift should
# surface here with the exact diff rather than as a cryptic dplyr error
# deep in summarise_data().

# Write a parquet file with arbitrary columns/types to a temp dir.
write_parquet_with <- function(dir, name, schema, n = 3) {
  df <- as.data.frame(lapply(schema, function(t) {
    switch(t,
           "string" = letters[seq_len(n)],
           "int32"  = seq_len(n),
           "double" = as.numeric(seq_len(n)),
           stop("unhandled test type: ", t))
  }))
  names(df) <- names(schema)
  arrow::write_parquet(df, file.path(dir, name))
}

with_temp_data <- function(schemas, contents) {
  dir <- tempfile("sib-schema-")
  dir.create(dir)
  for (file in names(contents)) {
    write_parquet_with(dir, file, contents[[file]])
  }
  list(dir = dir, schemas = schemas)
}

test_that("passes when actual matches expected", {
  schema <- c(A = "string", B = "int32")
  ctx <- with_temp_data(
    schemas = list("good.parquet" = schema),
    contents = list("good.parquet" = schema)
  )
  expect_true(validate_parquet_schemas(ctx$dir, ctx$schemas))
})

test_that("aborts when a declared file is missing", {
  ctx <- with_temp_data(
    schemas = list("required.parquet" = c(A = "string")),
    contents = list()
  )
  expect_error(
    validate_parquet_schemas(ctx$dir, ctx$schemas),
    "file not found"
  )
})

test_that("aborts when a declared column is missing", {
  ctx <- with_temp_data(
    schemas  = list("a.parquet" = c(A = "string", B = "int32")),
    contents = list("a.parquet" = c(A = "string"))
  )
  expect_error(
    validate_parquet_schemas(ctx$dir, ctx$schemas),
    "missing columns: B"
  )
})

test_that("aborts when a column has the wrong type", {
  ctx <- with_temp_data(
    schemas  = list("a.parquet" = c(A = "int32")),
    contents = list("a.parquet" = c(A = "string"))
  )
  expect_error(
    validate_parquet_schemas(ctx$dir, ctx$schemas),
    "type mismatches.*got string expected int32"
  )
})

test_that("aggregates problems across multiple files into one error", {
  ctx <- with_temp_data(
    schemas = list(
      "a.parquet" = c(A = "string", B = "int32"),
      "b.parquet" = c(C = "int32")
    ),
    contents = list(
      "a.parquet" = c(A = "string"),         # missing B
      "b.parquet" = c(C = "double")          # wrong type
    )
  )
  err <- tryCatch(validate_parquet_schemas(ctx$dir, ctx$schemas),
                  error = function(e) conditionMessage(e))
  expect_match(err, "a.parquet.*missing columns: B")
  expect_match(err, "b.parquet.*type mismatches")
})

test_that("tolerates undeclared (extra) columns and emits an info message", {
  ctx <- with_temp_data(
    schemas  = list("a.parquet" = c(A = "string")),
    contents = list("a.parquet" = c(A = "string", X = "int32"))
  )
  expect_message(
    expect_true(validate_parquet_schemas(ctx$dir, ctx$schemas)),
    "undeclared columns \\(tolerated\\): X"
  )
})

test_that("real production schema matches the committed data fixtures", {
  # Sanity check: the contract in R/expected_schema.R matches the parquet
  # files in data/ at HEAD. This is the test that catches "you bumped the
  # vintage but forgot to update the contract" before deploy.
  skip_if_not(dir.exists("../../data"), "data/ not present in test run")
  skip_if_not(
    all(file.exists(file.path("../../data", names(expected_parquet_schemas)))),
    "parquet files not all synced locally"
  )
  expect_true(validate_parquet_schemas("../../data"))
})
