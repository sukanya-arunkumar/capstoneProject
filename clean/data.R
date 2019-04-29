library(tidyr)
library(dplyr)
library(ggplot2)
library(ggmap)
library(geosphere)
library(psych)

#load yellow and green datasets
yellowData2014 <-
  read.csv('./yellow_2014.csv', stringsAsFactors = FALSE)
yellowData2015 <-
  read.csv('./yellow_2015.csv', stringsAsFactors = FALSE)

greenData2014 <-
  read.csv('./green_2014.csv', stringsAsFactors = FALSE)
greenData2015 <-
  read.csv('./green_2015.csv', stringsAsFactors = FALSE)


addTaxiColorColumn <- function(data, color){
  data$taxi_color <- color
  data
}


cleanLatLngData <-function (data, columnPrefix) {
  
  latColumnName <-
    paste(columnPrefix, "latitude", sep = "")
  lngColumnName <-
    paste(columnPrefix, "longitude", sep = "")
  
  data <-
    data[data[,eval(latColumnName)] >= -85 & data[,eval(latColumnName)] <= 85, ]
  data <-
    data[data[,eval(lngColumnName)] >= -180 & data[,eval(lngColumnName)] <= 180, ]
  
  #calculate distance to new york lat lng
  newYorkLatLng = c(-73.935242, 40.730610)
  data <- data  %>% mutate(distance_from_center = mapply(
    function(lg, lt)
      distm(newYorkLatLng, cbind(eval(data[[lg]]), eval(data[[lt]])), fun = distHaversine),
    lngColumnName,
    latColumnName
  ) / 1609)
  
  # remove records with locations outside of manhattan
  data <- data[data$distance_from_center < 100, ]
  data
}

cleanTripDistance <- function(data){
  
  #remove all rows with a trip distance greater than 100 miles
  data <- data[data$trip_distance < 100, ]
  data
}

wrangleDateTimeData <- function (data, columnPrefix) {
  dateTimeColumnName <-
    paste(columnPrefix, "datetime", sep = "")
  
  data <- data %>% mutate(
    !!paste(columnPrefix, 'year', sep = '') := mapply(
      function(datetime)
        as.POSIXlt(data[[datetime]], format = "%Y-%m-%d %H:%M:%S")$year + 1900 ,
      dateTimeColumnName
    ),!!paste(columnPrefix, 'month', sep = '') := mapply(
      function(datetime)
        as.POSIXlt(data[[datetime]], format = "%Y-%m-%d %H:%M:%S")$mon + 1 ,
      dateTimeColumnName
    ),!!paste(columnPrefix, 'day', sep = '') := mapply(
      function(datetime)
        as.POSIXlt(data[[datetime]], format = "%Y-%m-%d %H:%M:%S")$mday ,
      dateTimeColumnName
    ),!!paste(columnPrefix, 'hour', sep = '') := mapply(
      function(datetime)
        as.POSIXlt(data[[datetime]], format = "%Y-%m-%d %H:%M:%S")$hour ,
      dateTimeColumnName
    ),!!paste(columnPrefix, 'minute', sep = '') := mapply(
      function(datetime)
        as.POSIXlt(data[[datetime]], format = "%Y-%m-%d %H:%M:%S")$min ,
      dateTimeColumnName
    )
  )
  data
}

cleanDataFrame <- function(data, taxiColor){
  
  # clean lat lng for pickup and dropoff locations
  data <- cleanLatLngData(data, 'pickup_')
  data <- cleanLatLngData(data, 'dropoff_')
  
  # remove all trip distance above 100miles
  data <- cleanTripDistance(data)
  
  # create separate columns for datetime pickup and dropoff values
  # this function would create 5 new columns contining the year, month, day, hour and minutes
  data <- wrangleDateTimeData(data, 'pickup_')
  data <- wrangleDateTimeData(data, 'dropoff_')
  
  # add a taxi color column
  data <- addTaxiColorColumn(data,taxiColor)
  
  data
}

# clean datasets
yellowData2014 <- cleanDataFrame(yellowData2014, 'yellow')
yellowData2015 <- cleanDataFrame(yellowData2015, 'yellow')
greenData2014 <- cleanDataFrame(greenData2014, 'green')
greenData2015 <- cleanDataFrame(greenData2015, 'green')


# combine 2014 and 2015 datasets
yellowData <- rbind(yellowData2014,yellowData2015)
greenData <- rbind(greenData2014,greenData2015)

# create a dataset for yellow and green taxi 
communColumns <- c('pickup_latitude','pickup_longitude','dropoff_latitude','dropoff_longitude',
                   'pickup_year','pickup_month','pickup_day','pickup_hour','pickup_minute',
                   'dropoff_year','dropoff_month','dropoff_day','dropoff_hour','dropoff_minute',
                   'dropoff_datetime','passenger_count','trip_distance','payment_type',
                   'fare_amount', 'taxi_color')

yellowGreenData <- rbind(yellowData[names(yellowData) %in% communColumns], greenData[names(greenData) %in% communColumns])
write.csv(yellowGreenData, file = "clean_yellow_green_data.csv")

# create a dataset for only yellow taxi data
write.csv(yellowData, file = "clean_yellow_data.csv")
