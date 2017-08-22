# Example estimation of impact
library(data.table)
library(zoo)
library(bsts)
library(CausalImpact)

#read in the QCEW data in long format
dt <- fread("data/out/qcew/emp.csv", stringsAsFactors = FALSE)

#convert to wide format
dt_final <- dcast(dt, year + qtr ~ area_fips + industry_code, value.var = (names(dt)[5:8]))

#dates - needed for time series
pre_period <- as.Date(c("1990-01-01", "2004-06-01"))
post_period <- as.Date(c("2004-07-01", "2015-12-01"))
dates <- seq.Date(from = as.Date("1990-01-01"), to = as.Date("2015-12-01"), by="quarter")
nrows <- length(dates)
pre_periods <- length(dates[dates >= pre_period[1] & dates <= pre_period[2]])
post_periods <- length(dates[dates >= post_period[1] & dates <= post_period[2]])

#synthetic data - alternative for testing
# df <- data.frame(
#   date = dates,
#   sf_emp_private = cumsum(rnorm(nrows, mean = 20, sd = 100)) + 1000,
#   sf_hours_private = cumsum(rnorm(nrows, mean = 35, sd = 10)),
#   sf_hourly_earnings_private = cumsum(rnorm(nrows, mean = 10, sd = 5)),
#   abq_emp_private = cumsum(rnorm(nrows, mean = 20, sd = 100)) + 1000,
#   abq_hours_private = cumsum(rnorm(nrows, mean = 35, sd = 10)),
#   abq_hourly_earnings_private = cumsum(rnorm(nrows, mean = 10, sd = 5))
# )

# Seperate the dependent and independent variables
X <- dt_final[, -c("emp_35049_722", "year", "qtr"), with=F]
Y <- dt_final[, emp_35049_722]

# Time series data
data <- zoo(cbind(Y, X), dates)

#now determine the impact 
impact <- CausalImpact(data, pre_period, post_period, model.args = list(nseasons = 4, season.duration = 1))

p <- plot(impact)
p
summary(impact)

#Save the plot file
png(filename = "output/figures/qcew_impact.png")
p
dev.off()

####
# But maybe we want to specify our own prediction model

# first get Y, then set it to NA since unobserved in counterfactual
post_period_response <- sf_emp_retail[df$date >= as.Date("2006-07-01")]
sf_emp_retail[df$date >= as.Date("2006-07-01")] <- NA

# create our own model
ss <- AddLocal(list(), sf_emp_retail)
ss <- AddLocalLinearTrend(list(), data$sf_emp_private)
ss <- AddSeasonal(ss, sf_emp_retail, nseasons = 4)

bsts_model <- bsts(sf_emp_retail ~ data, ss, niter = 1000)


# Measure the impact
impact2 <- CausalImpact(bsts.model = bsts_model, post.period.response = post_period_response)
plot(impact2)
summary(impact2)  
