# Declared parquet schema contract.
#
# This is the dashboard's view of what the producer (sector-in-brief-data,
# per ADR 0010/0011) must publish for each panel. validate_parquet_schemas()
# checks the actual files against this list at app startup so a producer
# schema drift surfaces as a clear boot-time failure with the exact diff,
# instead of as a cryptic dplyr error mid-pipeline.
#
# Update this file in lockstep with producer schema changes (the producer
# repo lives at ../sector-in-brief-data).

.geo_org_schema <- c(
  "Organization Type" = "string",
  "Subsector"         = "string",
  "Size"              = "int32",
  "Census Region"     = "string",
  "Census State"      = "string",
  "Census County"     = "string",
  "Metro/Micro Area"  = "string",
  "Year"              = "int32"
)

expected_parquet_schemas <- list(
  "number_nonprofits.parquet" = c(
    .geo_org_schema,
    "Number of Nonprofits" = "int32"
  ),
  "finances.parquet" = c(
    .geo_org_schema,
    "Total Revenues" = "double",
    "Total Expenses" = "double",
    "Total Assets"   = "double",
    "Total Benefits" = "double"
  ),
  "pf_grants.parquet" = c(
    .geo_org_schema,
    "Total Contributions" = "double"
  ),
  "government_grants.parquet" = c(
    .geo_org_schema,
    "Total Government Grants" = "double"
  ),
  "program_related_investments.parquet" = c(
    .geo_org_schema,
    "Total Program-Related Investments" = "double"
  ),
  "daf.parquet" = c(
    .geo_org_schema,
    "Number of Nonprofits" = "int32",
    "Number of DAFs"       = "double",
    "Total Contributions"  = "double",
    "Total Grants"         = "double",
    "Total Value"          = "double",
    "Has DAF"              = "int32"
  )
)
