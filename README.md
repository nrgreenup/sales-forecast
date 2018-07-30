# Sales Forecast
Description: I examine the characteristics of monthly time series data on national retail sales (in the US). I then split the time series into training and testing subsets and evaluate four forecasting models: naive, Holt-Winters exponential smoothing, ARIMA, and dynamic regression using the Consumer Price Index as an exogenous regressor. 

## Analytical Report
The information in the README.md file below contains instructions and helpful information for replicating all analyses. For a detailed step-by-step report that walks through the analytical process, see visit my [website](https://nrgreenup.github.io/Retail-Sales-Forecasts/).

## Necessary Software 
You will need the following software and R packages installed to run code files and reproduce analyses.

Necessary software: `R` 

Necessary `R` packages: `forecast` , `tseries` , `astsa` , `ggplot2` , `RColorBrewer` , `Quandl`

## File Descriptions
      sales-forecasts.R : .R file that contains all data import, cleaning, and analyses
      /graphs/          : PNG files of all graphical output produced by sales-forecasts.R file
  
## Installation and File Execution
To begin, download sales-forecasts.R into a folder. When using `R`, set this folder as the working directory using `setwd`.

`R` script files are executable once a working directory to the folder containing data files is set. Running these scripts will reproduce all data cleaning procedures, plots, and analyses.

## Data Sources
 [US Census Bureau](https://www.census.gov/econ/currentdata/dbsearch?program=MRTS&startYear=1992&endYear=2018&categories=44000&dataType=SM&geoLevel=US&notAdjusted=1&submit=GET+DATA&releaseScheduleId=)   
 [Quandl's Federal Reserve Economic Data](https://www.quandl.com/data/FRED-Federal-Reserve-Economic-Data)   
 [OECD](https://data.oecd.org/leadind/consumer-confidence-index-cci.htm)   

## Acknowledgments 
[Hyndman and Athanasopoulos' "Forecasting:Principles and Practice](https://www.otexts.org/fpp): For an exceptionally detailed discussion of all things forecasting.   
[Hyndman's Forecasting Course on DataCamp](https://www.datacamp.com/courses/forecasting-using-r): For further forecasting discussions and code for using the `forecast` package.

## License
See LICENSE.md for licensing details for this project. 

