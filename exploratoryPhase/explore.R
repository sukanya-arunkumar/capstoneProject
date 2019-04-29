library(tidyr)
library(dplyr)
library(ggplot2)
library(ggmap)
library(geosphere)
library(psych)

#load yellow and green datasets
taxiData <-
  read.csv('./clean_yellow_green_data.csv', stringsAsFactors = FALSE)
