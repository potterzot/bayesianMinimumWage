library(RCurl)
library(jsonlite)
library(assertthat)
library(blsAPI)

###################
# Get data from BLS

# function to fetch and process a BLS series
get_bls <- function(series) {
  url_base <- "https://api.bls.gov/publicAPI/v1/timeseries/data/"
  url <- paste0(url_base, series)
  response <- getURLContent(url)
  res <- fromJSON(response)$Results[[1]]
  tmp <- res[[2]][[1]]
  tmp$series <- res[[1]]
  tmp
}

#test series
#s <- "SMU35421400500000001"
#d <- blsAPI(s)

# Iterate over locations and fetch data
loc_codes <- list("sf" = "35421", "abq" = "35107")
series_codes <- list(
  "emp_private" = "400500000001",
  "emp_retail" = "404200000001",
  "emp_hosp"   = "407000000001",
  "hours_private" = "400500000002",
  "hourly_earnings_private" = "400500000003",
  "weekly_earnings_private" = "400500000011"
)

series <- sapply(names(loc_codes), function(loc) {
  sapply(names(series_codes), function(ser) {
    paste0("SMU", loc_codes[[loc]], series_codes[[ser]])
  })
})

params <- list("seriesid"=series, startyear="1970", endyear="2015")
response <- blsAPI(params)
data <- fromJSON(response)
write.csv(data, file = "data/raw/bls.csv")

