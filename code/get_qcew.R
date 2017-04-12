###############
# Download QCEW Data
get_qcew_by_ind <- function(year) {
  filename <- paste0(year, "_qtrly_by_industry.zip")
  url <- paste0("https://data.bls.gov/cew/data/files/", year, "/csv/", filename)
  local <- paste0("data/raw/qcew/", filename)
  download.file(url, local)
}

#create the directory to save into, then download
dir.create("data/raw/qcew")
for (year in 1990:2016) {
  get_qcew_by_ind(year)
}
