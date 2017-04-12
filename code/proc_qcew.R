#First extract the files we want
# * Function definitions
# * Global variables
# * Extract files
# * Read and merge data
# * Tidy data
# * Subset and Save

library(tidyr)
library(dplyr)

########################
# * Function definitions

#extract specific year-sector files from zip files
extract_qcew <- function(year, sector) {
  zipfile <- paste0("data/raw/qcew/", year, "_qtrly_by_industry.zip")
  sectorfile <- paste0(year, ".q1-q4.by_industry/", year, ".q1-q4 ", sector, ".csv")
  unz(zipfile, sectorfile)
}

#read in extracted csv files
read_qcew <- function(year, sector) {
  sectorfile <- paste0("data/raw/qcew/", year, ".q1-q4.by_industry/", year, ".q1-q4 ", sector, ".csv")
  read.csv(sectorfile)
}


####################
# * Global variables
#years and sectors we want
years <- 1990:2016
sectors <- c("10 Total, all industries",
             "722 Food services and drinking places"
             )

#################
# * Extract files
#test
#extract_qcew(years[1], sectors[1])
sapply(years, function(y) {
  sapply(sectors, function(ind) {
    extract_qcew(y, ind)
  })
})


# * Read and merge data
csv_list <- list.files(pattern="*.csv")
data <- lapply(csv_list, read.csv)

#############
# * Tidy data

# keep only columns and rows that we want, so
# remove rows:    government employment
# remove rows:    not in Santa Fe, Bernalillo Counties or NM total
# remove columns: not having to do with employment and wages
keep_cols <- c("area_fips", "industry_code", "year", "qtr", "qtrly_estabs_count", "month1_emplvl", "month2_emplvl", "month3_emplvl", "total_qtrly_wages", "taxable_qtrly_wages", "avg_weekly_wage")

tmp_df_sub <- filter(data, area_fips %in% c(35049, 35001, 35000), own_code == 5)

#create quarterly avg of employment
emp_cols <- c("month1_emplvl", "month2_emplvl", "month3_emplvl")
tmp_df <- mutate(tmp_df_sub, emp = mean(month1_emplvl, month2_emplvl, month3_emplvl))

# * Subset and Save
dir.create("data/out/qcew")
write.csv(tmp_df[, -emp_cols], "data/out/qcew/emp.csv")




