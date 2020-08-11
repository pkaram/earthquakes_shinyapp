#load libraries needed (should be already installed)
library(gdata)
library(shiny)
library(leaflet)
library(dplyr)
#earthquake catalogue for Greece and adjacent areas since 1900)
data_temp<-read.xls("http://www.gein.noa.gr/services/1900-2009_mkk.xls",sheet=1)
#apply some data transformations
data_temp<-data_temp %>% mutate(date_time=paste(YEAR,MONTH,DAY,HOUR,MIN,SEC))
data_temp<-data_temp %>% mutate(date_time=as.POSIXct(date_time,format="%Y %m %d %H %M %S"))
data_temp<-data_temp %>% select(Date=date_time,
                      Latitude=LAT,
                      Longitude=LON,
                      Depth=DEP,
                      Magnitude_Ms=Ms,
                      Magnitude_Mw=Mw
                      )
