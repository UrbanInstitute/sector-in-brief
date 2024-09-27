# Script to download raw data if it doesn't exist
options(timeout = max(300, getOption("timeout")))


current_files <- list.files("data/")

files <- c(
  "number_nonprofits.parquet",
  "daf.parquet",
  "finances.parquet",
  "pf_grants.parquet",
  "nested_geographies.csv"
)

for (file in files){
  if (! file %in% current_files){
    message(paste0("Downloading ", file))
    url <- paste0("https://nccsdata.s3.amazonaws.com/dataexplorer/visuals/", 
                  file)
    destfile <- paste0("data/", file)
    download.file(url = url, destfile = destfile)
  }
}
