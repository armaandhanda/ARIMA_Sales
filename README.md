# This project aims to build and evaluate various statistical and machine learning models to forecast sales, using historical data with multiple explanatory variables. The workflow includes data preprocessing, stationarity checks, model fitting, and validation using RMSE across multiple models.

# Tools and Libraries
R Libraries:
quantmod: To fetch financial and economic data from FRED.
ggplot2: For visualizing time series data.
tseries: For conducting stationarity tests (ADF test).
dynlm: For dynamic regression modeling.
forecast: For ARIMA modeling and forecasting.
data.table: For efficient data manipulation.
lubridate: For handling date and time data.
readxl: For reading Excel files.
stringr: For string manipulation.
# Data Sources
FRED Data:

Total Vehicle Sales (TOTALSA)
Payroll Jobs (PAYEMS)
Federal Fund Rates (DFF)
Unemployment Rate (UNRATE)
NASDAQ Stock Index (NASDAQCOM)
Housing Market Prices (USSTHPI)
Gasoline Prices (CUSR0000SETB01)
Sales Data:

Time series data for daily sales (TVlift.xlsx).
# Key Steps
1. Data Preparation
Quarterly averages for all FRED time series were computed using apply.quarterly.
Stationarity was checked for each series using the Augmented Dickey-Fuller (ADF) test.
Differencing was applied to non-stationary series to make them stationary.
Missing values after differencing were handled using na.omit.
2. Exploratory Data Analysis (EDA)
Visualized time series data for all predictors and the dependent variable (TOTALSA) using autoplot and ts.plot.
Analyzed relationships between predictors and sales through dynamic regression models.
3. Model Development: The project involves fitting three types of models:

  #### Reduced-Form Models: Built an Ordinary Least Squares (OLS) regression model using predictors like payroll jobs, unemployment rate, and gasoline prices.
  #### ARIMA Models: Fitted ARIMA models for individual predictors (e.g., unemployment rate, payroll jobs) to forecast future values. Used these forecasts to predict total vehicle sales.
  #### Dynamic Models: Developed dynamic regression models that incorporate lagged values of sales and predictors. Included seasonal effects like day-of-week seasonality (factor(dow)).

  
4. Model Evaluation
Root Mean Squared Error (RMSE) was calculated for each model to assess accuracy.
Models were compared for both training and test datasets.
RMSE values for each model were stored in a results_df data frame for easy comparison.


Models Implemented
Part 1: FRED Data Modeling
Reduced-Form OLS Model:

Dependent Variable: Total Vehicle Sales (TOTALSA).
Independent Variables: Payroll Jobs (PAYEMS), Unemployment Rate (UNRATE), Housing Prices (USSTHPI), Gasoline Prices (CUSR0000SETB01).
ARIMA Models:

Individual ARIMA models were fit for predictors like unemployment rate and payroll jobs.
Forecasts from ARIMA models were combined to predict total sales.
Dynamic Regression Model:

Included lagged values of total vehicle sales and other predictors.
Incorporated day-of-week seasonality (dow) as a categorical variable.


Part 2: Sales Data Modeling
Linear Models:

fit01: Simple regression with sales as the dependent variable and predictors like TV ads.
fit02: Added day-of-week seasonality to fit01.
fit03 and fit04: Added lagged values of sales as predictors.
ARIMA Models:

Used the auto.arima function to fit ARIMA models on the sales data.
Forecasted future sales based on seasonal and trend components.
Complex Linear Models:

fit10 to fit13: Incorporated higher-order lags (e.g., 7-day and 30-day lags) and interaction terms for predictors.
Model Validation
Models were validated using the test dataset (rows 335–353).
RMSE was computed for each model to assess its performance on unseen data.
Forecasted values were compared with actual sales for the test period.
Key Outputs
Plots:

Time series plots of historical and forecasted values for each model.
Residual plots to check the goodness of fit.
Model Summaries:

Printed summaries for all models, including significant predictors (p < 0.05).
RMSE Comparison:

RMSE values for all models were stored in results_df, enabling direct comparison.
Insights
Seasonality Matters:

Adding day-of-week seasonality significantly improved model performance.
Lagged values of sales provided useful information for dynamic models.
Reduced-Form vs. Dynamic Models:

Dynamic models, which incorporated lagged values and interactions, outperformed reduced-form models in terms of RMSE.
ARIMA for Predictors:

Forecasting explanatory variables using ARIMA helped improve prediction accuracy for total sales.
