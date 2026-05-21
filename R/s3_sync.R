# Pull the sector-in-brief data vintage from S3 at app startup.
# Per ADR 0011 the dashboard reads from S3, not a committed data/ directory.
# Bump VINTAGE here when the producer publishes a new build; flip S3_PREFIX
# to "sector-in-brief" once the producer cuts over from sandbox to prod.
#
# Shell-out to `aws s3 sync` rather than arrow::s3_bucket so SSO profiles
# work locally and IAM roles work on the hosting tier without any
# credential plumbing in this code.

S3_BUCKET <- "nccsdata"
S3_PREFIX <- "sector-in-brief-sandbox"
VINTAGE   <- "v2026.05"

ensure_data_local <- function(data_dir = "data") {
  manifest <- file.path(data_dir, "_manifest.json")
  if (file.exists(manifest)) {
    have <- tryCatch(jsonlite::read_json(manifest)$vintage, error = function(e) NULL)
    if (identical(have, sub("^v", "", VINTAGE))) return(invisible())
  }
  if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)
  src <- sprintf("s3://%s/%s/%s/", S3_BUCKET, S3_PREFIX, VINTAGE)
  args <- c("s3", "sync", src, data_dir)
  # Local dev with AWS SSO: set SIB_AWS_PROFILE in .Renviron. Hosted tiers
  # (shinyapps.io, EC2) leave it empty and use the default IAM credential chain.
  profile <- Sys.getenv("SIB_AWS_PROFILE", "")
  if (nzchar(profile)) args <- c(args, "--profile", profile)
  status <- system2("aws", args)
  if (status != 0) {
    stop("aws s3 sync failed (exit ", status, ") from ", src,
         " - check AWS credentials")
  }
  invisible()
}

# Export the parquet data dictionary as a CSV under www/ so the static
# "Download data dictionary" links in visual_text.R can resolve to it.
publish_data_dictionary <- function(parquet_path = "data/data_dictionary.parquet",
                                    csv_path = "www/data_dictionary.csv") {
  if (!file.exists(parquet_path)) return(invisible())
  dir.create(dirname(csv_path), showWarnings = FALSE, recursive = TRUE)
  utils::write.csv(
    arrow::read_parquet(parquet_path),
    file = csv_path,
    row.names = FALSE
  )
  invisible()
}
