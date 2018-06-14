# Preliminary Steps -------------------------------------------------------
### FILE DESCRIPTION: Import data from Quandl and US Census Bureau; 
###                   Examine characteristics of time series object of interest.

### Data Source: Quandl Federal Reserve Economic Data (FRED), US Census Bureau, OECD.
### Census Bureau link: https://www.census.gov/econ/currentdata/dbsearch?program=MRTS&startYear=1992&endYear=2018&categories=44000&dataType=SM&geoLevel=US&notAdjusted=1&submit=GET+DATA&releaseScheduleId=
### OECD link: https://data.oecd.org/leadind/consumer-confidence-index-cci.htm

### Load necessary packages
library(forecast)
library(tseries)
library(astsa)
library(ggplot2)
library(RColorBrewer)
library(Quandl)
Quandl.api_key("k38BQJo9uik-sgVzgvN7")


# Import Data -------------------------------------------------------------
### Monthly sales, set to read in billions
sales <- ts(read.csv("retail_sales.csv")[2], start = c(1992,1), frequency = 12)
sales <- sales/1000

### Consumer Price Index, civilian labor force participation, personal disposable income
tsraw <- Quandl(c('FRED/CPIAUCSL',
               'FRED/CIVPART', 'FRED/DSPIC96'),
               collapse = "monthly", type = "ts",
               start_date = "1991-12-31", end_date = "2017-12-31")

### Consumer Confidence Index
CCI <- ts(read.csv("CCI.csv", skip = 384)[7],
          start= c(1992,1), frequency = 12) 
colnames(CCI) <- c("CCI")

### Join time series into single 'ts' object
ts <- ts.intersect(sales, tsraw, CCI)
colnames(ts) <- c("SALES", "CPI", "CIVLABPART", "DISPINC", "CCI")
rm(tsraw, CCI, sales)

### Examine prelimary correlations
cor(ts)


# Exploratory Analyses ----------------------------------------------------
### Define universal graphics options used repeatedly throughout analyses
test_xlim <- xlim(2013.000 , 2018.000)
title_center <- theme(plot.title = element_text(hjust = 0.5)) 

### Examine Sales TS Object
## Plot
plot_sales <- autoplot(ts[,"SALES"], ts.colour = "black") + 
                      labs(title = "Monthly Retail Sales (in billions)",
                           x = "Year", 
                           y = "Monthly Retail Sales (in billions)") + 
                      theme_bw() +
                      title_center
print(plot_sales)
ggsave("plot_sales-series.png")

## Seasonality
seasonplot_colors <- brewer.pal(9, "Reds")
seasonplot_colors <- colorRampPalette(seasonplot_colors)(26)
plot_seasonality <- ggseasonplot(ts[,"SALES"], col = seasonplot_colors) +
                                labs(title = "Seasonality in Monthly Retail Sales",
                                     x = "Month", 
                                     y = "Monthly Retail Sales (in billions)") + 
                                theme_bw() +
                                title_center 
print(plot_seasonality)
ggsave("plot_sales-seasonality.png")

## ACF and PACF
png("plot-sales_ACF2.png")
acf2(ts[, "SALES"], main = "ACF and PACF of Retail Sales Time Series")
dev.off()

## Unit root tests
adf.test(ts[,"SALES"])
kpss.test(ts[,"SALES"])
adf.test(diff(ts[,"SALES"]))

# Forecasting Set-up ------------------------------------------------------
### Split into training/test sets
time(ts)
train <- window(ts, end = 2012.917)
test  <- window(ts, start = 2013.000)


### Define Box Cox lambda parameter
sales_lambda <- BoxCox.lambda(ts[,"SALES"])

# Naive Forecast ----------------------------------------------------------
### Plot
naiveSALES <- naive(train[,"SALES"], h = 60, lambda = sales_lambda)
naive_plot <- autoplot(naiveSALES) + 
              forecast::autolayer(test[,"SALES"], series = "Test data") +
              labs(title = "Naive Forecast",
                   x = "Year" , 
                   y = "Retail Sales (in billions)", 
                   fill = "confidence interval") +
              test_xlim +
              title_center 
naive_plot
ggsave("plot-naive_forecast.png")

### Forecast Accuracy
accuracy(naiveSALES, test[,"SALES"])

### TS cross-validation code.
## Define TS CV RMSE function
# ROOTsq <- function(u){sqrt(u^2)}

## TSCV
# for (h in 1:12) {
#      ts[,"SALES"] %>% tsCV(forecastfunction = naive, h = h) %>%
#      ROOTsq() %>% mean(na.rm = TRUE) %>% print()
# }


# Holt-Winters Forecast ---------------------------------------------------
### Plot
hwSALES <- hw(train[,"SALES"], h = 60, seasonal = "multiplicative")
hw_plot <- autoplot(hwSALES, series = "Forecast") + 
           forecast::autolayer(test[,"SALES"], series = "Test data") +
           labs(title = "Holt-Winters Multiplicative Forecasts",
                x = "Year" , 
                y = "Retail Sales (in billions)",
                fill = "confidence interval") +
           test_xlim +
           title_center 
hw_plot
ggsave("plot-hw_forecast.png")

### Forecast Accuracy
accuracy(hwSALES, test[,"SALES"])


## TSCV
# for (h in 1:12) {
#     ts[,"SALES"] %>% tsCV(forecastfunction = hw, h = h) %>%
#     ROOTsq() %>% mean(na.rm = TRUE) %>% print()
# }


# ETS Forecast ------------------------------------------------------------
### Plot
etsSALES <- ets(train[,"SALES"], lambda = sales_lambda)
etsFCAST <- etsSALES %>% forecast(h = 60)
ets_plot <- autoplot(etsFCAST) + 
            forecast::autolayer(test[,"SALES"], series = "Test data") +
            labs(title = "ETS(A,Ad,A) Forecast",
                 x = "Year",
                 y = "Retail Sales (in billions)",
                 fill = "confidence interval") +
            test_xlim +
            title_center 
ets_plot
ggsave("plot-ets_forecast.png")

### Forecast Accuracy
accuracy(etsFCAST, test[,"SALES"])

## TSCV
# etsFUNC <- function(y, h, l) {
#   forecast(ets(y), h = h, lambda = sales_lambda)
# }
# for (h in 1:12) {
#     ts[,"SALES"] %>% tsCV(forecastfunction = etsFUNC, h = h) %>%
#     ROOTsq() %>% mean(na.rm = TRUE) %>% print()
# }


# ARIMA Forecast ----------------------------------------------------------
### Plot
arimaSALES <- auto.arima(train[,"SALES"], lambda = sales_lambda)
arimaFCAST <- arimaSALES %>% forecast(h = 60)
arima_plot <- arimaFCAST %>% autoplot() +
              autolayer(test[,"SALES"], series = "Test data") +
              labs(title = "ARIMA(2,1,1)(1,1,2)[12] Forecast",
                   x = "Year", 
                   y = "Retail Sales (in billions)",
                   fill = "confidence interval") +
              test_xlim +
              title_center 
arima_plot
ggsave("plot-arima_forecast.png")

### Forecast Accuracy
accuracy(arimaFCAST, test[,"SALES"])


# Harmonic Regression Forecast --------------------------------------------
### Find max order of Fourier terms
for (k in 3:6) {
  print(auto.arima(train[,"SALES"], xreg = fourier(train[,"SALES"], K = k),
                   lambda = "auto"))
}

### Plot (using max order = 6 for Fourier terms)
harmonicSALES <- auto.arima(train[,"SALES"], xreg = fourier(train[,"SALES"], K = 6),
                            lambda = sales_lambda)
harmonicFCAST <- harmonicSALES %>% forecast(xreg = fourier(train[,"SALES"], K = 6, h = 60))

harmonic_plot <- harmonicFCAST %>% autoplot() +
                 autolayer(test[,"SALES"], series = "Test data") +
                 labs(title = "Harmonic Forecast with Max Fourier Order = 6",
                      x = "Year" , 
                      y = "Retail Sales (in billions)",
                      fill = "confidence interval") +
                 test_xlim +
                 title_center 
harmonic_plot
ggsave("plot-harmonic_forecast.png")

### Forecast Accuracy
accuracy(harmonicFCAST, test[,"SALES"])


# TBATS Forecast ----------------------------------------------------------
tbatsSALES <- tbats(train[,"SALES"])
tbatsFCAST <- tbatsSALES %>% forecast(h = 60)
tbats_plot <- tbatsFCAST %>% autoplot() +
              autolayer(test[,"SALES"], series = "Test data") +
              labs(title = "TBATS Forecast",
                   x = "Year" ,
                   y = "Retail Sales (in billions)",
                   fill = "confidence interval") +
              test_xlim +
              title_center 
tbats_plot
ggsave("plot-tbats_forecast.png")

### Forecast Accuracy
accuracy(tbatsFCAST, test[,"SALES"])


# CPI XREG Forecast -------------------------------------------------------
### Examine CPI Series
## Plot
CPIplot <- autoplot(ts[,"CPI"], ts.colour = "black") + 
           labs(title = "Consumer Price Index",
                x = "Date", 
                y = "Consumer Price Index") + 
           theme_bw() +
           title_center
CPIplot
ggsave("plot-CPI_series.png")

## ACF/PACF
acf2(ts[,"CPI"])
acf2(diff(ts[,"CPI"]))

## Unit Root tests
adf.test(ts[,"CPI"]) # Unit root
kpss.test(ts[,"CPI"]) # Unit root

## Cross correlation plot for CPI and SALES
ccf2(ts[,"CPI"], diff(ts[,"SALES"]))


#### Model and forecast
## Fit XREG model
xregSALES <- auto.arima(train[,"SALES"], d = 1 , xreg = train[,"CPI"])

## Define forecast values for CPI as XREG
cpiARIMA <- auto.arima(train[,"CPI"])
cpiFCAST <- forecast(cpiARIMA, h = 60)

## Forecast sales using CPI ARIMA forecast values as XREG
xregFCAST <- xregSALES %>% forecast(h = 60, xreg = cpiFCAST$mean)


## Plot 
xreg_plot <- xregFCAST %>% autoplot() +
             autolayer(test[,"SALES"], series = "Test data") +
             labs(title = "Forecast with CPI Exogenous Regressor",
                  x = "Year" , 
                  y = "Retail Sales (in billions)",
                  fill = "confidence interval",
                  caption = "Forecast values for CPI based on ARIMA(0,1,3)(0,0,1)[12] model") +
             theme(plot.caption = element_text(size = 6)) +
             test_xlim +
             title_center 
xreg_plot
ggsave("plot-xreg_forecast.png")

## Forecast Accuracy
accuracy(xregFCAST, test[,"SALES"])