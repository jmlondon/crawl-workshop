## This is a template R script for loading of telemetry data from a
## comma-separated file downloaded from the Wildlife Computers Data Portal
## 
## Objectives:
## 
## 1. Read data into R using the `readr` package
## 2. Set the appropriate data types for each column/variable
## 3. Determine whether the data need to be tidy'd after import


library(tidyverse)
library(lubridate)

## Read data into R using the `readr` package's read_csv() function
## 

path_to_file <- "examples/data/160941-Locations.csv"
tbl160941_locs <- readr::read_csv(path_to_file)

## Examine structure of resulting data frame / tibble

str(tbl160941_locs)


## Note the Date column is read as a character data type. We want this
## to be a POSIXct date-time object. For more insight into specifying
## date formats, see help for `lubridate::parse_date_time` and `strptime`
## 
## Any other data types that should be changed?


## `readr::read_csv()` will provide a `cols()` output
## this tells you what data types read_csv() guessed.
## we can modify this and pass as a parameter to `read_csv`

my_cols <- cols(
  DeployID = col_character(),
  Ptt = col_integer(),
  Instr = col_character(),
  Date = col_datetime("%H:%M:%S %d-%b-%Y"), # changed from col_character()
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

tbl160941_locs <- readr::read_csv(path_to_file,col_types = my_cols)

## it is helpful to replace any spaces/hyphens in column names 
## with underscore and, then, change all to lower case

colnames(tbl160941_locs) <- gsub(" ", "_", colnames(tbl160941_locs))
colnames(tbl160941_locs) <- gsub("-", "_", colnames(tbl160941_locs))
colnames(tbl160941_locs) <- tolower(colnames(tbl160941_locs))

tbl160941_locs <- tbl160941_locs %>% 
  rename(date_time = date)


## the last bit of information we need to read in is haul-out activity.
## `crawl` provides the option to include haul-out activity as a parameter
## in the model fit. By including haul-out activity, the correlation (beta)
## parameter will go to zero when the animal is hauled out since the animal
## is very likely not moving.
## 
## We will use a similar approach using `readr`, `tidyr`, and `dplyr`

## I've already done the work to setup the cols() function for the
## 160941-Histos.csv

my_cols <- readr::cols(
  DeployID = readr::col_character(),
  Ptt = readr::col_character(),
  DepthSensor = readr::col_character(),
  Source = readr::col_character(),
  Instr = readr::col_character(),
  HistType = readr::col_character(),
  Date = readr::col_datetime("%H:%M:%S %d-%b-%Y"),
  `Time Offset` = readr::col_double(),
  Count = readr::col_integer(),
  BadTherm = readr::col_integer(),
  LocationQuality = readr::col_character(),
  Latitude = readr::col_double(),
  Longitude = readr::col_double(),
  NumBins = readr::col_integer(),
  Sum = readr::col_integer(),
  Bin1 = readr::col_double(),
  Bin2 = readr::col_double(),
  Bin3 = readr::col_double(),
  Bin4 = readr::col_double(),
  Bin5 = readr::col_double(),
  Bin6 = readr::col_double(),
  Bin7 = readr::col_double(),
  Bin8 = readr::col_double(),
  Bin9 = readr::col_double(),
  Bin10 = readr::col_double(),
  Bin11 = readr::col_double(),
  Bin12 = readr::col_double(),
  Bin13 = readr::col_double(),
  Bin14 = readr::col_double(),
  Bin15 = readr::col_double(),
  Bin16 = readr::col_double(),
  Bin17 = readr::col_double(),
  Bin18 = readr::col_double(),
  Bin19 = readr::col_double(),
  Bin20 = readr::col_double(),
  Bin21 = readr::col_double(),
  Bin22 = readr::col_double(),
  Bin23 = readr::col_double(),
  Bin24 = readr::col_double(),
  Bin25 = readr::col_double(),
  Bin26 = readr::col_double(),
  Bin27 = readr::col_double(),
  Bin28 = readr::col_double(),
  Bin29 = readr::col_double(),
  Bin30 = readr::col_double(),
  Bin31 = readr::col_double(),
  Bin32 = readr::col_double(),
  Bin33 = readr::col_double(),
  Bin34 = readr::col_double(),
  Bin35 = readr::col_double(),
  Bin36 = readr::col_double(),
  Bin37 = readr::col_double(),
  Bin38 = readr::col_double(),
  Bin39 = readr::col_double(),
  Bin40 = readr::col_double(),
  Bin41 = readr::col_double(),
  Bin42 = readr::col_double(),
  Bin43 = readr::col_double(),
  Bin44 = readr::col_double(),
  Bin45 = readr::col_double(),
  Bin46 = readr::col_double(),
  Bin47 = readr::col_double(),
  Bin48 = readr::col_double(),
  Bin49 = readr::col_double(),
  Bin50 = readr::col_double(),
  Bin51 = readr::col_double(),
  Bin52 = readr::col_double(),
  Bin53 = readr::col_double(),
  Bin54 = readr::col_double(),
  Bin55 = readr::col_double(),
  Bin56 = readr::col_double(),
  Bin57 = readr::col_double(),
  Bin58 = readr::col_double(),
  Bin59 = readr::col_double(),
  Bin60 = readr::col_double(),
  Bin61 = readr::col_double(),
  Bin62 = readr::col_double(),
  Bin63 = readr::col_double(),
  Bin64 = readr::col_double(),
  Bin65 = readr::col_double(),
  Bin66 = readr::col_double(),
  Bin67 = readr::col_double(),
  Bin68 = readr::col_double(),
  Bin69 = readr::col_double(),
  Bin70 = readr::col_double(),
  Bin71 = readr::col_double(),
  Bin72 = readr::col_double()
)

## use the previous examples to develop your own code using `readr::read_csv()`.
## additionally, we want to limit (hint: filter) the records to just those
## rows that represent percent timeline data. These records are identified by
## having a `HistType` of either 'Percent' or '1Percent'

## tbl160941_histos <- ...

tbl160941_histos <- readr::read_csv("examples/data/160941-Histos.csv",
                                    col_types = my_cols) %>% 
  dplyr::filter(HistType %in% c('Percent','1Percent')) %>% 
  dplyr::arrange(Date)

## it is helpful to eliminate any spaces in column names and lower case

colnames(tbl160941_histos) <- sub(" ", "_", colnames(tbl160941_histos))
colnames(tbl160941_histos) <- sub("-", "_", colnames(tbl160941_histos))
colnames(tbl160941_histos) <- tolower(colnames(tbl160941_histos))

## Refer to the tidy data example in the presentation to develop code
## for tidying the histos_tbl data
## 
## bins <- ...
## 
## tbl160941_histos <- ...
## 

## Create a tbl_df that Relates Bin Columns to Day Hours
bins <- tibble(bin=paste("bin",1:24,sep=""),hour=0:23)

## Chain Together Multiple Commands to Create Our Tidy Dataset
tbl160941_histos <- tbl160941_histos %>% 
  tidyr::gather(bin,percent_dry, starts_with('bin')) %>%
  dplyr::left_join(bins, by="bin") %>%
  dplyr::rename(date_hour = date) %>% 
  dplyr::mutate(date_hour = date_hour + lubridate::hours(hour)) %>%
  dplyr::select(deployid,date_hour,percent_dry) %>%
  dplyr::arrange(deployid,date_hour)

## Percent timeline data is often incomplete --- missing days during the
## deployment. For our movement model, we need a complete series of
## timeline records for each hour with NA values where missing.
## 

## let's create a sequence of hourly times that span the entire record
## of locations

min_date <- min(tbl160941_locs$date_time, na.rm = TRUE)
max_date <- max(tbl160941_locs$date_time, na.rm = TRUE)

t <- tibble(date_hour = seq(from = lubridate::floor_date(min_date,'hour'),
                                to = max_date,
                                by = '1 hour')
)

library(zoo)

tbl160941_histos <- tbl160941_histos %>% 
  right_join(t, by = "date_hour") %>% 
  mutate(percent_dry = ifelse(is.na(percent_dry), 33,
                                   percent_dry)) %>% 
  zoo::na.locf() %>% 
  mutate(date_hour = lubridate::ymd_hms(date_hour),
         percent_dry = as.numeric(percent_dry))

head(tbl160941_histos)
tail(tbl160941_histos)


## The final step is to save these two tables to a files. We will use the
## `saveRDS` function

saveRDS(tbl160941_locs,'path to save location.rds')
saveRDS(tbl160941_histos,'path to save location.rds')
