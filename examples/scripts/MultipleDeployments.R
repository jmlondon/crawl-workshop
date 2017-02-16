library(tidyverse)
library(purrr)
library(lubridate)
library(argosfilter)
library(crawl)
library(sp)

fix_colnames <- function(x) {
  colnames(x) <- gsub(" ", "_", colnames(x))
  colnames(x) <- gsub("-", "_", colnames(x))
  colnames(x) <- tolower(colnames(x))
  x
}

sp_coords <- function(x) {
  sp::coordinates(x) <- ~ longitude + latitude
  proj4string(x) <- "+init=epsg:4326"
  x
}

file_paths <- list.files('examples/data/',
                         "*-Locations.csv",
                         full.names = TRUE)

my_cols <- cols(
  DeployID = col_character(),
  Ptt = col_integer(),
  Instr = col_character(),
  Date = col_datetime("%H:%M:%S %d-%b-%Y"),
  Quality = col_character(),
  Latitude = col_double(),
  Longitude = col_double(),
  `Error radius` = col_integer(),
  `Error Semi-major axis` = col_integer(),
  `Error Semi-minor axis` = col_integer(),
  `Error Ellipse orientation` = col_integer(),
  Offset = col_character(),
  `Offset orientation` = col_character(),
  `GPE MSD` = col_character(),
  `GPE U` = col_character(),
  Count = col_character(),
  Comment = col_character()
)


file_paths %>% 
  purrr::map(read_csv,col_types = my_cols) %>% 
  purrr::map(fix_colnames) %>%  
  purrr::map(~ dplyr::rename(.x, 
                      date_time = date)) %>% 
  purrr::map(~ dplyr::arrange(.x, 
                       deployid, date_time)) %>% 
  purrr::map(~ dplyr::filter(.x,
                       !(is.na(error_radius) & type=='Argos'))) %>% 
  purrr::map(~ dplyr::mutate(.x,
                       error_semi_major_axis = ifelse(
                         type=='FastGPS',50,
                         error_semi_major_axis),
                       error_semi_minor_axis = ifelse(
                         type=='FastGPS',50,
                         error_semi_minor_axis),
                       error_ellipse_orientation = ifelse(
                         type=='FastGPS',0,
                         error_ellipse_orientation)
                       )
                       ) %>% 
  purrr::map(~ dplyr::mutate(.x,
                             error_semi_major_axis = ifelse(
                               type=='User',100,
                               error_semi_major_axis),
                             error_semi_minor_axis = ifelse(
                               type=='User',100,
                               error_semi_minor_axis),
                             error_ellipse_orientation = ifelse(
                               type=='User',0,
                               error_ellipse_orientation)
  )
  ) -> 
  my_data

for (i in 1:length(my_data)) {
my_data[[i]]$filtered <- argosfilter::sdafilter(
  lat = my_data[[i]]$latitude,
  lon = my_data[[i]]$longitude,
  dtime = my_data[[i]]$date_time,
  lc = my_data[[i]]$quality,
  vmax = 5)
}

my_data %>%
  purrr::map(~ dplyr::filter(.x,
    filtered %in% c("not", "end location"))) %>% 
  purrr::map(~ dplyr::select(.x,-filtered)) %>% 
  map(~ dplyr::arrange(.x, deployid,date_time)) ->
  my_data


diag_data <- my_data %>% 
  map( ~ model.matrix(
  ~ error_semi_major_axis + error_semi_minor_axis +
    error_ellipse_orientation,
  model.frame(~ .,.x, na.action = na.pass)
)[,-1]) %>% 
  map(~ crawl::argosDiag2Cov(
  .x[,1], .x[,2], .x[,3]
))

input_tbls <- map2(my_data,diag_data,
            bind_cols) %>% 
  map(sp_coords) %>% 
  map(sp::spTransform,CRS("+init=epsg:3571"))

source('fit_crawl.R')

fits <- pmap(list(input_tbls),fit_crawl)
names(fits) <- c("seal160941","seal164831")

predicts <- pmap(list(fits),crwPredict())
