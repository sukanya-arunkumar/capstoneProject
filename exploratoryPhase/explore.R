library(tidyr)
library(dplyr)
library(ggplot2)
library(ggmap)
library(geosphere)
library(psych)
library(rgdal)
library(sf)

register_google(key = "AIzaSyDOHYjR93Vi0ols4DpE88pdPOppaO_aShg")


#load yellow and green datasets
taxiData <-
  read.csv('./clean_yellow_green_data.csv', stringsAsFactors = FALSE)

threshold <- quantile(taxiData$trip_distance, probs=0.9)
taxiData <- taxiData[taxiData$trip_distance < threshold,]
threshold <- quantile(taxiData$fare_amount, probs=0.9)
taxiData <- taxiData[taxiData$fare_amount < threshold,]

utils::unzip('./neighborhoodTabulationAreas.zip')
shp <- readOGR(dsn = file.path('./geo_export_3b02421d-4a31-4bc5-ad76-6d5084b470f5.shp'), stringsAsFactors = F)

map <- ggmap(get_map("New York",
                     zoom = 10, scale = "auto",
                     source = "google"),
             extent="device",
             legend="topright"
)+ geom_point(aes(x=pickup_longitude, y=pickup_latitude, color=taxi_color), 
              data=taxiData, 
               alpha=0.2
)  + 
  geom_polygon(data = shp, aes(x = long, y = lat, group = group), colour = "black", fill = NA)

map + theme_void()

specialTaxiData <- taxiData
coordinates(specialTaxiData)=~pickup_longitude+pickup_latitude
nhood2 = spTransform(shp, CRS("+proj=longlat +datum=WGS84"))

proj4string(specialTaxiData) = proj4string(nhood2)
specialTaxiData$nhoodID <- over(specialTaxiData, nhood2)
taxiData$ntaname <- unlist(specialTaxiData$nhoodID['ntaname'])
taxiData$ntacode <- unlist(specialTaxiData$nhoodID['ntacode'])


ggplot(taxiData, aes(x=pickup_longitude, y=pickup_latitude)) + 
  geom_point(aes(color=ntacode, alpha=0.2))+ theme(legend.position = "none")  + 
  geom_polygon(data = shp, aes(x = long, y = lat, group = group), colour = "black", fill = NA)


nhoodSummary <- taxiData %>% group_by(ntacode) %>%
  summarise(count=n())
colnames(nhoodSummary) <- c("ntacode", "value")

first15NH <- nhoodSummary %>% arrange(desc(value)) %>% head(15) 
d <- taxiData[taxiData$ntacode %in% first15NH$ntacode,]

ggplot(d, aes(x=ntacode)) +
  geom_bar()






merge(ntacode, taxiData, by.x = "ntacode", by.y = "ntacode")

taxiData$test <- factor(taxiData$ntacode)
selectedColumns <- c("trip_distance", "fare_amount", "ntacode")
view <- taxiData[ ,(names(taxiData) %in% selectedColumns)]

pairs.panels(view, 
             method = "pearson",
             hist.col = "#00AFBB",
             density = TRUE,
             ellipses = TRUE
)


ggplot(taxiData, aes(x=ntacode, fill=taxi_color, alpha=I(0.4))) + 
  geom_bar() + 
  scale_fill_manual(values=c("#006600", "#e5e500"))





threshold <- quantile(taxiData$trip_distance, probs=0.9)

taxiData <- taxiData[taxiData$trip_distance < threshold,]

threshold <- quantile(view$fare_amount, probs=0.9)

taxiData <- view[view$fare_amount < threshold,]

view <- view[ ,(names(taxiData) %in% selectedColumns)]

max(view$trip_distance)


specialTaxiData <- taxiData
coordinates(specialTaxiData)=~pickup_longitude+pickup_latitude
nhood2 = spTransform(shp, CRS("+proj=longlat +datum=WGS84"))

specialTaxiData$nhoodID <- over(specialTaxiData, nhood2)

selectedColumns <- c( "passengar_count",
                      "fare_amount", "trip_distance", "ntaname")
names(taxiData)
taxiData$ntaname <- taxiData$nhoodID['ntaname']
view <- taxiData[ ,(names(taxiData) %in% selectedColumns)]
pairs.panels(view, 
             method = "pearson",
             hist.col = "#00AFBB",
             density = TRUE,
             ellipses = TRUE
)

dfnew5 <- subset(taxiData, select=c( "fare_amount", "trip_distance","passenger_count"))
pairs.panels(dfnew5, 
             method = "pearson",
             hist.col = "#00AFBB",
             density = TRUE,
             ellipses = TRUE
)


taxiData <-
  read.csv('../clean_yellow_green_data.csv', stringsAsFactors = FALSE)

threshold <- quantile(taxiData$fare_amount, probs=0.9)
amount_type_label <- c('TRUE' = paste('Fare Amount > ', threshold), 'FALSE' = paste('Fare Distance <= ', threshold))
ggplot(transform(taxiData,
                 long_distance = trip_distance > threshold), aes(x=trip_distance, fill=taxi_color, alpha=I(0.4))) + 
  geom_density() + 
  scale_fill_manual(values=c("#006600", "#e5e500")) +
  facet_grid (~long_distance,scales = "free", labeller=as_labeller(amount_type_label)) +
  labs(fill = 'Taxi Color', x = 'Fare Amount', y = 'Density')

ggplot(taxiData, aes(x=fare_amount, fill=taxi_color, alpha=I(0.4))) + 
  geom_density() + 
  scale_fill_manual(values=c("#006600", "#e5e500")) +
  #facet_grid (~long_distance,scales = "free", labeller=as_labeller(distance_type_label)) +
  #labs(fill = 'Taxi Color', x = 'Trip Distance (in miles)', y = 'Density')
  
  
  
  
  taxiData <-
  read.csv('./clean_yellow_green_data.csv', stringsAsFactors = FALSE)
threshold <- quantile(taxiData$trip_distance, probs=0.9)
taxiData <- taxiData[taxiData$trip_distance < threshold,]
threshold <- quantile(taxiData$fare_amount, probs=0.9)
taxiData <- taxiData[taxiData$fare_amount < threshold,]


selectedColumns <- c( "passengar_count",
                      "fare_amount", "trip_distance")
view <- taxiData[ ,(names(taxiData) %in% selectedColumns)]
pairs.panels(view, 
             method = "pearson",
             hist.col = "#00AFBB",
             density = TRUE,
             ellipses = TRUE
)

register_google(key = "AIzaSyDOHYjR93Vi0ols4DpE88pdPOppaO_aShg")
newYorkLatLng = c(-73.935242, 40.730610)

res <- revgeocode(newYorkLatLng, output="address")
res$postal_code
res$neighborhood