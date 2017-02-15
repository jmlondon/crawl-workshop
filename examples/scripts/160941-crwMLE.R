## This is a template R script for setting up the final data table for input
## into the `crwMLE()` function. 

library(tidyverse)
library(lubridate)
library(crawl)

crawl_input <- readRDS('input_tbl.rds')

obsData <- crawl_input %>% 
  dplyr::mutate(percent_dry = 1 - percent_dry/100) %>%
  dplyr::rename(activity = percent_dry,
                date_time = date_time) %>%
  dplyr::arrange(deployid, date_hour, date_time)

obsData <- obsData[!duplicated(obsData$date_time),]

diag_data = model.matrix(
  ~ error_semi_major_axis + error_semi_minor_axis +
    error_ellipse_orientation,
  model.frame(~ .,obsData, na.action = na.pass)
)[,-1]

obsData <- cbind(obsData, crawl::argosDiag2Cov(
  diag_data[,1],
  diag_data[,2],
  diag_data[,3]
)) %>% 
  dplyr::arrange(deployid, date_hour, date_time)

init = list(a = c(obsData$x[1], 0,
                  obsData$y[1], 0),
            P = diag(c(10^2, 10^2,
                       10^2, 10^2)))

fixPar = c(1,1,NA,NA,0)

constr = list(lower = c(-Inf, -4), upper = (c(Inf, 4)))

ln_prior = function(par){dnorm(par[2], 4, 4, log=TRUE)}

lap_prior = function(par){-abs(par[2] - 4)/1000}
reg_prior = function(par){dt(par[2] - 3,
                             df = 1,
                             log = TRUE)}

fit <- crawl::crwMLE(
  #crawl::displayPar(
  mov.model =  ~ 1,
  activity = ~ I(activity),
  err.model = list(
    x =  ~ ln.sd.x - 1,
    y =  ~ ln.sd.y - 1,
    rho =  ~ error.corr
  ),
  data = obsData,
  Time.name = "date_time",
  initial.state = init,
  fixPar = fixPar,
  # prior = lap_prior,
  constr = constr,
  attempts = 1,
  control = list(maxit = 30, trace = 0,REPORT = 1),
  initialSANN = list(maxit = 1000, 
                     trace = 1, REPORT = 1)
)


if (inherits(fit,"try-error") || any(is.nan(fit$se))) {
  message(paste("I had issues. going full Brownian"))
  fixPar = c(1, 1, NA, 4, 0)
  
  obsData <- obsData %>% 
    dplyr::arrange(speno, date_hour, date_time)
  
  fit <- crawl::crwMLE(
    #crawl::displayPar(
    mov.model =  ~ 1,
    activity = ~ I(activity),
    err.model = list(
      x =  ~ ln.sd.x - 1,
      y =  ~ ln.sd.y - 1,
      rho =  ~ error.corr
    ),
    data = obsData,
    Time.name = "date_time",
    initial.state = init,
    fixPar = fixPar,
    attempts = 3,
    control = list(maxit = 30, trace = 0,REPORT = 1),
    initialSANN = list(maxit = 1800, 
                       trace = 1, REPORT = 1)
  )
}
