library(quantmod)
library(ggplot2)
library(xts)
library(tseries)

getSymbols("TOTALSA", src="FRED")   # Total Vehicle Sales
getSymbols("PAYEMS", src="FRED")    # US Payroll Jobs
getSymbols("DFF", src="FRED")       # Federal Fund Rates
getSymbols("UNRATE", src="FRED")    # Unemployment Rate
getSymbols("NASDAQCOM", src="FRED") # NASDAQ Stock Index
getSymbols("USSTHPI", src="FRED")   # Housing Market Prices
getSymbols("CUSR0000SETB01", src="FRED") # Gasoline Price


autoplot(TOTALSA) + ggtitle("Total Vehicle Sales")
autoplot(PAYEMS) + ggtitle("US Payroll Jobs")
autoplot(DFF) + ggtitle("Federal Fund Rates")
autoplot(UNRATE) + ggtitle("Unemployment Rate")
autoplot(nasdaq_quarterly) + ggtitle("NASDAQ Stock Index")
autoplot(USSTHPI) + ggtitle("Housing Market Prices")
autoplot(CUSR0000SETB01) + ggtitle("Gasoline Price")


total_sales_quarterly <- apply.quarterly(TOTALSA,FUN = function(x) mean(x, na.rm = TRUE))
payroll_jobs_quarterly <- apply.quarterly(PAYEMS, FUN = function(x) mean(x, na.rm = TRUE))
fed_fund_rate_quarterly <- apply.quarterly(DFF, FUN = function(x) mean(x, na.rm = TRUE))
unemployment_rate_quarterly <- apply.quarterly(UNRATE, FUN = function(x) mean(x, na.rm = TRUE))
nasdaq_quarterly <- apply.quarterly(NASDAQCOM, FUN = function(x) mean(x, na.rm = TRUE))
housing_prices_quarterly <- apply.quarterly(USSTHPI, FUN = function(x) mean(x, na.rm = TRUE))
gasoline_prices_quarterly <- apply.quarterly(CUSR0000SETB01, FUN = function(x) mean(x, na.rm = TRUE))
plot(payroll_jobs_quarterly, main="US Payroll Jobs (Quarterly)", ylab="Total Sales", col="blue")
plot(total_sales_quarterly, main="Total Vehicle Sales (Quarterly)", ylab="Total Sales", col="blue")
# Set the training window for Total Vehicle Sales (Quarterly)
total_sales_quarterly_train <- window(total_sales_quarterly, start="1976-04-01", end="2023-06-30")
payroll_jobs_quarterly_train <- window(payroll_jobs_quarterly, start="1976-04-01", end="2023-06-30")
fed_fund_rate_quarterly_train <- window(fed_fund_rate_quarterly, start="1976-04-01", end="2023-06-30")
unemployment_rate_quarterly_train <- window(unemployment_rate_quarterly, start="1976-04-01", end="2023-06-30")
nasdaq_quarterly_train <- window(nasdaq_quarterly, start="1976-04-01", end="2023-06-30")
housing_prices_quarterly_train <- window(housing_prices_quarterly, start="1976-04-01", end="2023-06-30")
gasoline_prices_quarterly_train <- window(gasoline_prices_quarterly, start="1976-04-01", end="2023-06-30")



# Check stationarity for each time series
adf.test(total_sales_quarterly_train)
adf.test(payroll_jobs_quarterly_train)
adf.test(fed_fund_rate_quarterly_train)
adf.test(unemployment_rate_quarterly_train)

adf.test(housing_prices_quarterly_train)
adf.test(gasoline_prices_quarterly_train)

# Remove NA values after differencing
total_sales_quarterly_diff <- na.omit(diff(total_sales_quarterly_train))
payroll_jobs_quarterly_diff <- na.omit(diff(payroll_jobs_quarterly_train))
nasdaq_quarterly_diff <- na.omit(diff(nasdaq_quarterly_train))
housing_prices_quarterly_diff <- na.omit(diff(housing_prices_quarterly_train))
gasoline_prices_quarterly_diff <- na.omit(diff(gasoline_prices_quarterly_train))
unemployment_rate_quarterly_diff <- na.omit(diff(unemployment_rate_quarterly_train))
# Check the differenced series with ADF test
adf.test(total_sales_quarterly_diff)
adf.test(payroll_jobs_quarterly_diff)
adf.test(nasdaq_quarterly_diff)
adf.test(housing_prices_quarterly_diff)
adf.test(gasoline_prices_quarterly_diff)
adf.test(unemployment_rate_quarterly_diff)
# Trim the longer series to match the length of the other series
fed_fund_rate_quarterly_train <- fed_fund_rate_quarterly_train[1:188]

# Combine all the stationary/differenced series into a data frame
combined_df <- data.frame(
  total_sales = coredata(total_sales_quarterly_diff),
  payroll_jobs = coredata(payroll_jobs_quarterly_diff),
  fed_fund_rate = coredata(fed_fund_rate_quarterly_train),  # Already stationary
  unemployment_rate = coredata(unemployment_rate_quarterly_diff),  
  nasdaq = coredata(nasdaq_quarterly_diff),
  housing_prices = coredata(housing_prices_quarterly_diff),
  gasoline_prices = coredata(gasoline_prices_quarterly_diff)
)

# Remove rows with NA values (due to differencing)
combined_df <- na.omit(combined_df)

# Inspect the data
head(combined_df)

ols_model <- lm(TOTALSA ~ PAYEMS + UNRATE + USSTHPI + CUSR0000SETB01, data = combined_df)

# View the model summary
summary(ols_model)



# Fit an ARMA model to Predictor1
model_UNRATE <- auto.arima(combined_df$UNRATE)

# Fit an ARMA model to Predictor2
model_PAYEMS <- auto.arima(combined_df$PAYEMS)

# Fit an ARMA model to Predictor3
model_USSTHPI <- auto.arima(combined_df$USSTHPI)

# Fit an ARMA model to Predictor4
model_CUSR0000SETB01 <- auto.arima(combined_df$CUSR0000SETB01)

forecast_UNRATE <- forecast(model_UNRATE, h = 4)  # Forecast 4 quarters ahead
forecast_PAYEMS <- forecast(model_PAYEMS, h = 4)
forecast_USSTHPI <- forecast(model_USSTHPI, h = 4)  # Forecast 4 quarters ahead
forecast_CUSR0000SETB01 <- forecast(model_CUSR0000SETB01, h = 4)

# Create a new data frame for the forecasted explanatory variables
forecasted_explanatory_vars <- data.frame(
  PAYEMS = as.numeric(forecast_PAYEMS$mean),
  UNRATE = as.numeric(forecast_UNRATE$mean),
  USSTHPI = as.numeric(forecast_USSTHPI$mean),
  CUSR0000SETB01 = as.numeric(forecast_CUSR0000SETB01$mean)
)

# Inspect the forecasted explanatory variables
print(forecasted_explanatory_vars)

# Forecast total vehicle sales using the OLS model
forecasted_car_sales <- predict(ols_model, newdata = forecasted_explanatory_vars)

# Print the forecasted total vehicle sales
print(forecasted_car_sales)
# Combine historical and forecasted sales for visualization
combined_sales <- c(coredata(total_sales_quarterly_diff), forecasted_car_sales)

# Create a time index for both historical and forecasted periods
time_index <- seq(start(total_sales_quarterly), by = "quarter", length.out = length(combined_sales))

# Create a data frame for visualization
sales_forecast_df <- data.frame(
  Date = time_index,
  Sales = combined_sales
)

# Plot the historical and forecasted vehicle sales
ggplot(sales_forecast_df, aes(x = Date, y = Sales)) +
  geom_line(color = "blue") +
  ggtitle("Historical and Forecasted Total Vehicle Sales") +
  xlab("Year") + ylab("Total Vehicle Sales")
actual_sales <- window(total_sales_quarterly, start = "2023-07-01", end = "2024-06-30")
# Assuming actual_car_sales is the actual data for 2023Q3 to 2024Q2
rmse <- sqrt(mean((forecasted_car_sales - actual_sales)^2))
print(paste("RMSE:", rmse))



# Fit an ARMA model directly to Total Vehicle Sales (stationary series)
model_total_sales <- auto.arima(total_sales_quarterly_diff)

# Forecast Total Vehicle Sales for the next 4 quarters (2023Q3 to 2024Q2)
forecast_total_sales <- forecast(model_total_sales, h = 4)

# Print the forecasted Total Vehicle Sales
print(forecast_total_sales$mean)

# Combine the historical and forecasted Total Vehicle Sales for comparison
combined_total_sales <- c(coredata(total_sales_quarterly_diff), forecast_total_sales$mean)

# Create a time index for both historical and forecasted periods
time_index_total_sales <- seq(start(total_sales_quarterly), by = "quarter", length.out = length(combined_total_sales))

# Create a data frame for visualization
total_sales_forecast_df <- data.frame(
  Date = time_index_total_sales,
  Sales = combined_total_sales
)

# Plot the historical and forecasted Total Vehicle Sales (Reduced-form model)
ggplot(total_sales_forecast_df, aes(x = Date, y = Sales)) +
  geom_line(color = "blue") +
  ggtitle("Historical and Forecasted Total Vehicle Sales (Reduced-form Model)") +
  xlab("Year") + ylab("Total Vehicle Sales")

# Calculate RMSE between actual and forecasted values
rmse_reduced_form <- sqrt(mean((forecast_total_sales$mean - actual_sales)^2, na.rm = TRUE))
print(paste("Reduced-form Model RMSE:", rmse_reduced_form))




library(dplyr)


# Create lagged Total Vehicle Sales (Car Sales at time t-1)
lagged_total_sales <- lag(total_sales_quarterly_diff, n = 1)
# Combine lagged Total Vehicle Sales with other predictors
combined_lagged_df <- data.frame(
  total_sales = coredata(total_sales_quarterly_diff),
  lagged_total_sales = coredata(lagged_total_sales),
  payroll_jobs = coredata(payroll_jobs_quarterly_diff),
  fed_fund_rate = coredata(fed_fund_rate_quarterly_train[1:188]),  # Already stationary
  unemployment_rate = coredata(unemployment_rate_quarterly_diff),
  nasdaq = coredata(nasdaq_quarterly_diff),
  housing_prices = coredata(housing_prices_quarterly_diff),
  gasoline_prices = coredata(gasoline_prices_quarterly_diff)
)
# Remove rows with NA values due to lagging
combined_lagged_df <- na.omit(combined_lagged_df)
# Fit a dynamic regression model using the lagged total sales and other predictors
dynamic_model <- lm(TOTALSA ~ TOTALSA.1 + PAYEMS +  UNRATE + USSTHPI + CUSR0000SETB01, 
                    data = combined_lagged_df)

# View the model summary
summary(dynamic_model)
# Forecast the explanatory variables (assuming forecasts are already available)
forecasted_explanatory_vars_lagged <- data.frame(
  TOTALSA.1 = tail(combined_lagged_df$TOTALSA, 1),  # The most recent value of TOTALSA as lagged value
  PAYEMS = as.numeric(forecast_PAYEMS$mean),
  UNRATE = as.numeric(forecast_UNRATE$mean),
  USSTHPI = as.numeric(forecast_USSTHPI$mean),
  CUSR0000SETB01 = as.numeric(forecast_CUSR0000SETB01$mean)
)

# Forecast future total vehicle sales using the dynamic regression model
forecasted_dynamic_car_sales <- predict(dynamic_model, newdata = forecasted_explanatory_vars_lagged)

# Print the forecasted car sales
print(forecasted_dynamic_car_sales)
# Assuming actual_car_sales contains the actual data for the forecasted period
rmse_dynamic <- sqrt(mean((forecasted_dynamic_car_sales - actual_sales)^2))
print(paste("Dynamic Model RMSE:", rmse_dynamic))


