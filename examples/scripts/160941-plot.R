library(crawl)
library(crawlr)
library(tidyverse)
library(lubridate)

fit <- readRDS('fit.rds')
## we'll setup our predTimes based on the date_hour
## column in the fit$data
min_date <- min(fit$data$date_hour, na.rm = TRUE)
max_date <- max(fit$data$date_hour, na.rm = TRUE)

t <- tibble(date_hour = seq(from = min_date,
                            to = max_date,
                            by = '1 hour')
)

## now we use crwPredict to get a predicted track based on
## the most likely path. Our predTime starts one hour earlier
## than the first observation so it will throw a warning
p <- crawl::crwPredict(fit, predTime = t$date_hour)

## this will plot the x and y paths w/ standard errors
crawl::crwPredictPlot(p)

## load the nPacMaps library installed from jmlondon's github
library(nPacMaps)

## we need to convert the predicted path to a
## SpatialPointsDataFrame and set the projection
coordinates(p) <- ~ mu.x + mu.y
proj4string(p) <- "+init=epsg:3571"

## extend the bounding box/study area for plotting by
## 25km on each side.
e <- raster::extend(raster::extent(p),25000)

xlims <- bbox(e)[1,]
ylims <- bbox(e)[2,]

## we need to convert back to a data frame before relying
## on ggplot for plotting. We'll also limit the points to 
## the predicted times and convert date_time to POSIXct
p <- data.frame(p) %>% 
  dplyr::filter(locType == "p") %>% 
  dplyr::mutate(date_time = crawl::intToPOSIX(date_time))

## load the bering sea regional mamp from nPacMaps
bering_base <- nPacMaps::bering(resolution = "h")

## ggplot with the predicted path and points
bering_plot <- ggplot() + 
  geom_polygon(data = bering_base,
               aes(x = long,y = lat,group = group),
               fill = "grey60") +
  geom_point(data = p,
             aes(x = mu.x, y = mu.y),
             size = 0.5) +
  geom_path(data = p,
            aes(x = mu.x, y = mu.y)) +
  coord_equal(xlim=xlims, ylim=ylims) +
  xlab("easting (km)") + ylab("northing (km)") +
  scale_x_continuous(labels = nPacMaps::to_km()) +
  scale_y_continuous(labels = nPacMaps::to_km()) +
  ggtitle('Harbor Seal Predicted Locations')

bering_plot

## load the `crawlr` package for helper functions
library(crawlr)

## within `crawl`, `crwSimulator` and `crwPostIS` are used
## to generate a simulated track from the posterior
sim <- crwSimulator(fit, predTime = t$date_hour)
trk <- crwPostIS(sim)

## the `crawlr` package provides helper functions
## `get_sim_tracks` returns a list of simulated tracks
trks <- crawlr::get_sim_tracks(fit, iter = 20, pt = t$date_hour)

## the `get_sim_points` function returns a
## SpatialPointsDataFrame for all points along a simulated track
trks <- lapply(trks,
               function(x) crawlr::get_sim_points(list(x),
                                                  locType = "p",
                               crs = CRS("+init=epsg:3571"))
)

## convert the list of SpatialPointsDataFrames to data frame
## and then bind into a single data frame. Setting the
## .id = "trk" is important so the resulting data frame
## has an id column for each track
trks <- lapply(trks, function(x) data.frame(x)) %>% 
  bind_rows(.id = "trk")


## plot the predicted track and the 20 simulated tracks
bering_plot <- ggplot() + 
  geom_polygon(data = bering_base,
               aes(x = long,y = lat,group = group),
               fill = "grey60") +
  geom_point(data = p,
             aes(x = mu.x, y = mu.y),
             size = 0.5) +
  geom_path(data = trks,
            aes(x = mu.x, y = mu.y, group = trk),
            alpha=0.3, size = 0.3) +
  geom_path(data = p,
             aes(x = mu.x, y = mu.y)) +
  coord_equal(xlim=xlims, ylim=ylims) +
  xlab("easting (km)") + ylab("northing (km)") +
  scale_x_continuous(labels = nPacMaps::to_km()) +
  scale_y_continuous(labels = nPacMaps::to_km()) +
  ggtitle('Harbor Seal Predicted Locations')

bering_plot

## convert the trks data frame back to a SpatialPointsDataFrame
## so we can then pass it to ud_hexpolys() and create a 
## Utilization Distribution
coordinates(trks) <- ~ mu.x + mu.y
proj4string(trks) <- "+init=epsg:3571"

ud <- crawlr::ud_hexpolys(trks,
                          cellsize = 1000,
                          cellsize.override = FALSE)

## the broom package is required to convert the ud
## SpatialPolygonsDataFrame to a data frame appropriate for
## use within ggplot
ud$id <- rownames(ud@data)
ud_fortify <- broom::tidy(ud, region = "id") %>% 
  dplyr::left_join(ud@data, by="id") %>% 
  dplyr::filter(counts > 0) %>% 
  dplyr::mutate(counts = counts/20,
                log_counts = log(counts))

## viridis provides a nice color palette for the ud
library(viridis)

bering_plot <- ggplot() + 
  geom_polygon(data = bering_base,
               aes(x = long,y = lat,group = group),
               fill = "grey60") +
  geom_polygon(data = ud_fortify,
               aes(x = long, y = lat, 
                   group = id, fill = log_counts)) +
  coord_equal(xlim = xlims, ylim=ylims) +
  scale_fill_viridis() +
  xlab("easting (km)") + ylab("northing (km)") +
  scale_x_continuous(labels = nPacMaps::to_km()) +
  scale_y_continuous(labels = nPacMaps::to_km()) +
  ggtitle('Harbor Seal Predicted Locations')

bering_plot

