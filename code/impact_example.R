# Example estimation of impact


library(tidyr)
library(bsts)
library(CausalImpact)

#dates - needed for time series
dates <- seq.Date(from = as.Date("1990-01-01"), to = as.Date("2016-12-01"), by="quarter")

#read in the QCEW data
df <- read_csv("data/out/qcew/emp.csv")



#synthetic data
df <- data.frame(
  date = dates,
  sf_emp_private = cumsum(rnorm(192, mean = 20, sd = 100)) + 1000,
  sf_hours_private = cumsum(rnorm(192, mean = 35, sd = 10)),
  sf_hourly_earnings_private = cumsum(rnorm(192, mean = 10, sd = 5)),
  abq_emp_private = cumsum(rnorm(192, mean = 20, sd = 100)) + 1000,
  abq_hours_private = cumsum(rnorm(192, mean = 35, sd = 10)),
  abq_hourly_earnings_private = cumsum(rnorm(192, mean = 10, sd = 5))
)
sf_emp_retail <- df$sf_emp_private * (0.1 + (rnorm(192, 0, 0.1))^2) * c(rep(1,78), rep(0.9, 114))

data <- zoo(cbind(sf_emp_retail, df[, 2:ncol(df)]), dates)

#when the new minimum wage took effect
pre_period <- as.Date(c("2000-01-01", "2006-06-01"))
post_period <- as.Date(c("2006-07-01", "2015-12-01"))

#now determine the impact 
impact <- CausalImpact(data, pre_period, post_period, model.args = list(nseasons = 4, season.duration = 3))
plot(impact)
summary(impact, "report")

####
# But maybe we want to specify our own prediction model

# first get Y, then set it to NA since unobserved in counterfactual
post_period_response <- sf_emp_retail[df$date >= as.Date("2006-07-01")]
sf_emp_retail[df$date >= as.Date("2006-07-01")] <- NA

# create our own model
ss <- AddLocalLevel(list(), sf_emp_retail)
bsts_model <- bsts(y ~ , ss, niter = 1000)
bsts_model <- 


# Measure the impact
impact2 <- CausalImpact(bsts.model = bsts_model, post.period.response = post_period_response)

