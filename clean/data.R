library(tidyr)
library(dplyr)
library(ggplot2) 
library(ggmap)
library(geosphere)

register_google(key=[key])


#load yellow and green datasets
yellowData2014 <- read.csv('./yellow_2014.csv', stringsAsFactors = FALSE)
yellowData2015 <- read.csv('./yellow_2015.csv', stringsAsFactors = FALSE)

greenData2014 <- read.csv('./green_2014.csv', stringsAsFactors = FALSE)
greenData2015 <- read.csv('./green_2015.csv', stringsAsFactors = FALSE)

visualizeAndCleanPickupLatLngData <- function (data, drawPlots = FALSE) {
  
  # set ggplot limits
  min_lat <- min(data$pickup_latitude)
  max_lat <- max(data$pickup_latitude)
  min_long <- min(data$pickup_longitude)
  max_long <- max(data$pickup_longitude)
  
  if(drawPlots){
    plot <- ggplot(data, aes(x=pickup_longitude, y=pickup_latitude)) +
      geom_point(size=0.06) +
      scale_x_continuous(limits=c(min_long, max_long)) +
      scale_y_continuous(limits=c(min_lat, max_lat)) 
    
    plot
  }
  
  data <- data[data$pickup_latitude >= -85 & data$pickup_latitude <= 85,]
  data <- data[data$pickup_longitude >= -180 & data$pickup_longitude <= 180,]
  
  #calculate distance to new york lat lng
  newYorkLatLng = c(-73.935242, 40.730610)
  data <- data  %>% mutate(
    distance_from_center = mapply(function(lg, lt) distm(newYorkLatLng, c(lg, lt), fun=distHaversine), pickup_longitude, pickup_latitude)/ 1609
  )
  
  #remove all rows with a distance greater than 100 miles
  data <- data[data$distance_from_center < 100,]
  
  #round longitude and latitude with a 4 precision
  data$pickup_latitude <-  round(data$pickup_latitude, 4)
  data$pickup_longitude <-  round(data$pickup_longitude, 4)
  
  # set ggplot limits
  min_lat <- min(data$pickup_latitude)
  max_lat <- max(data$pickup_latitude)
  min_long <- min(data$pickup_longitude)
  max_long <- max(data$pickup_longitude)
  
  if(drawPlots){
    
    plot <- ggplot(data, aes(x=pickup_longitude, y=pickup_latitude)) +
      geom_point(size=0.06) +
      scale_x_continuous(limits=c(min_long, max_long)) +
      scale_y_continuous(limits=c(min_lat, max_lat)) 
    
    plot
    
    # draw pickup data on google maps
    ggmap(get_map("New York",
                  zoom = 10, scale = "auto",
                  source = "google"),
          extent="device",
          legend="topright"
    ) + geom_point(aes(x=pickup_longitude, y=pickup_latitude), 
                   data=data, 
                   col="red", alpha=0.2
    ) 
  }
  
  data <- data %>% mutate(
    pickup_year = mapply(function(datetime) as.POSIXlt(datetime)$year+1900 , pickup_datetime),
    pickup_month = mapply(function(datetime) as.POSIXlt(datetime)$mon+1 , pickup_datetime),
    pickup_day = mapply(function(datetime) as.POSIXlt(datetime)$mday , pickup_datetime),
    pickup_hour = mapply(function(datetime) as.POSIXlt(datetime)$hour , pickup_datetime),
    pickup_minute = mapply(function(datetime) as.POSIXlt(datetime)$min , pickup_datetime)
  ) 
  
  data
}



visualizeAndCleanDropoffLatLngData <- function (data, drawPlots = FALSE) {
  
  # set ggplot limits
  min_lat <- min(data$dropoff_latitude)
  max_lat <- max(data$dropoff_latitude)
  min_long <- min(data$dropoff_longitude)
  max_long <- max(data$dropoff_longitude)
  
  if(drawPlots){
    plot <- ggplot(data, aes(x=dropoff_longitude, y=dropoff_latitude)) +
      geom_point(size=0.06) +
      scale_x_continuous(limits=c(min_long, max_long)) +
      scale_y_continuous(limits=c(min_lat, max_lat)) 
    
    plot
  }
  
  data <- data[data$dropoff_latitude >= -85 & data$dropoff_latitude <= 85,]
  data <- data[data$dropoff_longitude >= -180 & data$dropoff_longitude <= 180,]
  
  #calculate distance to new york lat lng
  newYorkLatLng = c(-73.935242, 40.730610)
  data <- data  %>% mutate(
    distance_from_center = mapply(function(lg, lt) distm(newYorkLatLng, c(lg, lt), fun=distHaversine), dropoff_longitude, dropoff_latitude)/ 1609
  )
  
  #remove all rows with a distance greater than 100 miles
  data <- data[data$distance_from_center < 100,]
  
  #round longitude and latitude with a 4 precision
  data$dropoff_latitude <-  round(data$dropoff_latitude, 4)
  data$dropoff_longitude <-  round(data$dropoff_longitude, 4)
  
  # set ggplot limits
  min_lat <- min(data$dropoff_latitude)
  max_lat <- max(data$dropoff_latitude)
  min_long <- min(data$dropoff_longitude)
  max_long <- max(data$dropoff_longitude)
  
  if(drawPlots){
    plot <- ggplot(data, aes(x=dropoff_longitude, y=dropoff_latitude)) +
      geom_point(size=0.06) +
      scale_x_continuous(limits=c(min_long, max_long)) +
      scale_y_continuous(limits=c(min_lat, max_lat)) 
    
    plot
    
    # draw pickup data on google maps
    ggmap(get_map("New York",
                  zoom = 10, scale = "auto",
                  source = "google"),
          extent="device",
          legend="topright"
    ) + geom_point(aes(x=dropoff_longitude, y=dropoff_latitude), 
                   data=data, 
                   col="red", alpha=0.2
    ) 
  }
  
  data <- data %>% mutate(
    dropoff_year = mapply(function(datetime) as.POSIXlt(datetime)$year+1900 , dropoff_datetime),
    dropoff_month = mapply(function(datetime) as.POSIXlt(datetime)$mon+1 , dropoff_datetime),
    dropoff_day = mapply(function(datetime) as.POSIXlt(datetime)$mday , dropoff_datetime),
    dropoff_hour = mapply(function(datetime) as.POSIXlt(datetime)$hour , dropoff_datetime),
    dropoff_minute = mapply(function(datetime) as.POSIXlt(datetime)$min , dropoff_datetime)
    
    )

  data
}

yellowData2014 <- visualizeAndCleanPickupLatLngData(yellowData2014)
yellowData2015 <- visualizeAndCleanPickupLatLngData(yellowData2015)
greenData2014 <- visualizeAndCleanPickupLatLngData(greenData2014)
greenData2015 <- visualizeAndCleanPickupLatLngData(greenData2015)


yellowData2014 <- visualizeAndCleanDropoffLatLngData(yellowData2014)
yellowData2015 <- visualizeAndCleanDropoffLatLngData(yellowData2015)
greenData2014 <- visualizeAndCleanDropoffLatLngData(greenData2014)
greenData2015 <- visualizeAndCleanDropoffLatLngData(greenData2015)


write.csv(yellowData2014, file = "clean_yellow_2014.csv")
write.csv(yellowData2015, file = "clean_yellow_2015.csv")
write.csv(greenData2014, file = "clean_green_2014.csv")
write.csv(greenData2015, file = "clean_green_2015.csv")
