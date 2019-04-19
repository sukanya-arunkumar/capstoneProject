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

visualizeLatLngData <- function (data) {
  
  # set ggplot limits
  min_lat <- min(data$pickup_latitude)
  max_lat <- max(data$pickup_latitude)
  min_long <- min(data$pickup_longitude)
  max_long <- max(data$pickup_longitude)
  
  plot <- ggplot(data, aes(x=pickup_longitude, y=pickup_latitude)) +
    geom_point(size=0.06) +
    scale_x_continuous(limits=c(min_long, max_long)) +
    scale_y_continuous(limits=c(min_lat, max_lat)) 
  
  plot
  
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

visualizeLatLngData(yellowData2014)
visualizeLatLngData(yellowData2015)
visualizeLatLngData(greenData2014)
visualizeLatLngData(greenData2015)



