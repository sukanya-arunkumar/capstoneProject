library(tidyr)
library(dplyr)
library(ggplot2) 
library(ggmap)
library(geosphere)

#load yellow and green datasets
yellowData2014 <- read.csv('../yellow_2014.csv', stringsAsFactors = FALSE)
yellowData2015 <- read.csv('../yellow_2015.csv', stringsAsFactors = FALSE)

greenData2014 <- read.csv('../green_2014.csv', stringsAsFactors = FALSE)
greenData2015 <- read.csv('../green_2015.csv', stringsAsFactors = FALSE)

# set ggplot limits
min_lat <- min(yellowData2014$pickup_latitude)
max_lat <- max(yellowData2014$pickup_latitude)
min_long <- min(yellowData2014$pickup_longitude)
max_long <- max(yellowData2014$pickup_longitude)

plot <- ggplot(yellowData2014, aes(x=pickup_longitude, y=pickup_latitude)) +
  geom_point(size=0.06) +
  scale_x_continuous(limits=c(min_long, max_long)) +
  scale_y_continuous(limits=c(min_lat, max_lat)) 

plot



#calculate distance to new york lat lng
newYorkLatLng = c(-73.935242, 40.730610)
yellowData2014 <- yellowData2014  %>% mutate(
  distance_from_center = mapply(function(lg, lt) distm(newYorkLatLng, c(lg, lt), fun=distHaversine), pickup_longitude, pickup_latitude)/ 1609
)

#remove all rows with a distance greater than 400 miles
yellowData2014 <- yellowData2014[yellowData2014$distance_from_center < 400,]

#round longitude and latitude with a 4 precision
yellowData2014$pickup_latitude <-  round(yellowData2014$pickup_latitude, 4)
yellowData2014$pickup_longitude <-  round(yellowData2014$pickup_longitude, 4)

# set ggplot limits
min_lat <- min(yellowData2014$pickup_latitude)
max_lat <- max(yellowData2014$pickup_latitude)
min_long <- min(yellowData2014$pickup_longitude)
max_long <- max(yellowData2014$pickup_longitude)

plot <- ggplot(yellowData2014, aes(x=pickup_longitude, y=pickup_latitude)) +
  geom_point(size=0.06) +
  scale_x_continuous(limits=c(min_long, max_long)) +
  scale_y_continuous(limits=c(min_lat, max_lat)) 

plot


# draw pickup data on google maps
ggmap(get_map("New York",
              zoom = 12, scale = "auto",
              source = "google",
              api_key = "AIzaSyDOHYjR93Vi0ols4DpE88pdPOppaO_aShg"),
      extent="device",
      legend="topright"
) + geom_point(aes(x=pickup_longitude, y=pickup_latitude), 
               data=data, 
               col="red", alpha=0.2
) + geom_point(aes(x=pickup_longitude, y=pickup_latitude), 
               data= yellowData2014[yellowData2014$fare_amount < 3,], 
               col="blue", alpha=0.2
)
