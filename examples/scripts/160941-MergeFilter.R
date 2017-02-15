## This is a template R script for merging the location and percent timeline
## data from the 160941-ReadData.R script. After merging, we will also run
## the data through a course speed filter using the `argosfilter` package.
## 
## Objectives:
## 
## 1. Read data into R using readRDS()
## 2. Merge/Join the two tables based on date-time/hour
## 3. Speed filter w/ `argosfilter`

library(tidyverse)
library(lubridate)
library(argosfilter)

tbl160941_locs <- readRDS('tbl160941_locs.rds')
tbl160941_histos <- readRDS('tbl160941_histos.rds')

str(tbl160941_locs)
str(tbl160941_histos)

# We want to merge these two tables based on the location date-time and the
# percent timeline hour. In other words, every location within an hour should
# match with the corresponding hour record from the *_histos table.
# 
# We will use the `left_join()` function from `dplyr` for this
tbl160941_locs %>% nrow()

tbl160941_locs$filtered <- argosfilter::sdafilter(
  lat = tbl160941_locs$latitude,
  lon = tbl160941_locs$longitude,
  dtime = tbl160941_locs$date_time,
  lc = tbl160941_locs$quality,
  vmax = 5)

tbl160941_locs <- tbl160941_locs %>%
  dplyr::filter(filtered %in% c("not", "end location")) %>% 
  dplyr::select(-filtered)

tbl160941_locs %>% nrow()

tbl160941_locs <- tbl160941_locs %>% 
  mutate(date_hour = lubridate::floor_date(date_time,'hour')) %>% 
  arrange(date_time)

## observations with duplicate time values but differing coordinates
## are not uncommon in Argos data. For example:

tbl160941_locs %>% 
  slice(550:555) %>% 
  select(date_time,latitude,longitude)

## the `xts` pakcage has a `make.time.unique()` function that we can use
## to bump any duplicate times by 1 second.

library(xts)

unique_times <- xts::make.time.unique(tbl160941_locs$date_time, 
                                      eps=1)
unique_times[550:555]

tbl160941_locs$date_time <- unique_times

## convert to sp object and project to appropriate projection
## 

library(sp)

coordinates(tbl160941_locs) <- ~ longitude + latitude
proj4string(tbl160941_locs) <- "+init=epsg:4326"

## these data are from the Aleutian Islands, we'll go with epsg:3571
## for our projection of choice

tbl160941_locs <- sp::spTransform(tbl160941_locs,CRS("+init=epsg:3571"))

## note the coordinates are now in meters instead of longlat

head(coordinates(tbl160941_locs))

plot(tbl160941_locs)
lines(as(tbl160941_locs,"SpatialLines"))

## at this point, if we weren't using the activity parameter of `crwMLE()`,
## we could proceed to crawl. But, we have some more work to do

## let's convert from a SpatialPointsDataFrame back to a data frame

tbl160941_locs <- data.frame(tbl160941_locs) %>% 
  dplyr::rename(x = longitude,y = latitude)

## now let's read in release data w/ starting locations and date-time
## plus add in columns we will want to fix before joining with our
## location data

release_data <- readr::read_csv("examples/data/deploy_data.csv") %>% 
  dplyr::rename(deployid = splash_deployid, 
                date_time = release_dt,
                latitude = release_lat,
                longitude = release_long) %>% 
  dplyr::mutate(error_radius = 25L,
                error_semi_major_axis = 25L,
                error_semi_minor_axis = 25L,
                error_ellipse_orientation = 0L,
                date_hour = lubridate::floor_date(date_time,'hour'),
                quality = "3", instr = 'GPS', percent_dry = 0) %>% 
  dplyr::select(deployid,date_time,date_hour,latitude,longitude,
                error_radius,error_semi_major_axis,
                error_semi_minor_axis, error_ellipse_orientation,
                quality,instr, percent_dry)

## let's get this into the correct projection coordinates

coordinates(release_data) <- ~ longitude + latitude
proj4string(release_data) <- "+init=epsg:4326"

release_data <- sp::spTransform(release_data, CRS("+init=epsg:3571"))

release_data <- data.frame(release_data) %>% 
  dplyr::rename(x = longitude, y = latitude)

input_tbl <- tbl160941_histos %>% 
  dplyr::left_join(tbl160941_locs, by = c("deployid","date_hour")) %>% 
  dplyr::filter(between(date_hour,
                        lubridate::floor_date(min(date_time,na.rm=TRUE),'hour'),
                        max(date_time,na.rm=TRUE))) %>% 
  dplyr::bind_rows(release_data) %>% 
  dplyr::mutate(date_time = ifelse(is.na(date_time),date_hour,date_time)) %>% 
  dplyr::arrange(deployid,date_time)

head(input_tbl)

saveRDS(input_tbl,'input_tbl.rds')
