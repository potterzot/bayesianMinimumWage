#First extract the files we want
# * Function definitions
# * Global variables
# * Extract files
# * Read and merge data
# * Tidy data
# * Subset and Save

library(data.table)

########################
# * Function definitions

#extract specific year-sector files from zip files
extract_qcew <- function(year, sector) {
  zipfile <- paste0("data/raw/qcew/", year, "_qtrly_by_industry.zip")
  sectorfile <- paste0(year, ".q1-q4.by_industry/", year, ".q1-q4 ", sector, ".csv")
  unzip(zipfile, files = sectorfile, exdir = "data/proc/qcew/", junkpaths = TRUE)
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
dir.create("data/proc/qcew", recursive = TRUE)
lapply(years, function(y) {
  lapply(sectors, function(ind) {
    extract_qcew(y, ind)
  })
})


# * Read and merge data

# need to define column types so no errors on rbind 
col_classes <- c(rep("character", 13), rep("numeric", 8), "character", rep("numeric", 8), "character", rep("numeric", 16))

csv_list <- list.files(path="data/proc/qcew", pattern="*.csv", full.names = TRUE)
data_raw <- rbindlist(lapply(csv_list, fread, colClasses = col_classes))
setkey(data_raw, year, qtr)

#############
# * Tidy data

# keep only columns and rows that we want, so
# remove rows:    government employment
# remove rows:    not in Santa Fe, Bernalillo Counties or NM total
# remove columns: not having to do with employment and wages
tmp_df <- data_raw[area_fips %in% c("35049", "35001", "35000") & own_code == 5]

#create quarterly avg of employment
emp_cols <- c("month1_emplvl", "month2_emplvl", "month3_emplvl")
tmp_df$emp <- rowMeans(tmp_df[, emp_cols, with=F])

# * Subset and Save
dir.create("data/out/qcew", recursive = TRUE)
keep_cols <- c("area_fips", "industry_code", "year", "qtr", "qtrly_estabs_count", "month1_emplvl", "month2_emplvl", "month3_emplvl", "total_qtrly_wages", "taxable_qtrly_wages", "avg_wkly_wage")

write.csv(tmp_df[, c(setdiff(keep_cols, emp_cols), "emp"), with=F], "data/out/qcew/emp.csv", row.names = FALSE)




