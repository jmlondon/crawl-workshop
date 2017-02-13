
<!-- README.md is generated from README.Rmd. Please edit that file -->
crawl-workshop
--------------

slides, data and code in support of workshops at AFSC and SWFSC for the R package `crawl`

### Logistics and Schedule

14-16 February, 2017
9am - 5pm
MML Conference Room, 2039

NOAA Western Regional Center
Alaska Fisheries Science Center (Bldg 4)
7600 Sand Point Way NE, Seattle, WA

[Identification Requirements for Accessing the WRC](http://www.wrc.noaa.gov/NewIdRequirements.htm)

Nearest Hotel: [Silver Cloud (University)](https://www.silvercloud.com/university/)

### Workshop Agenda

#### Day 1:

1.  Introductions/Why are you here?
2.  The Theory of Crawling (Devin Johnson)
3.  Lunch
4.  Practical Guide to Crawling (Josh London)

#### Day 2:

1.  Hands-on w/ example datasets

#### Day 3:

1.  BYODHF (Bring Your Own Data, Have Fun)

### What To Bring and Have Installed

1.  A laptop computer with the following software installed
    1.  R 3.3.2
    2.  RStudio 1.0.136
    3.  (Windows users) [RTools34](https://cran.r-project.org/bin/windows/Rtools/)

2.  The following R packages from CRAN: `devtools`, `tidyverse`, `lubridate`, `sp`, `raster`, `argosfilter`, `doParallel`, `xts` (see below for installation code)
3.  THe following R packages installed from github: `crawl`, `crawlr`, `nPacMaps`
4.  AFSC staff should work with IT to insure they are signed up for the EduRoam campus wifi network. Visitors will use the NOAA Guest wifi.
5.  A healthy does of curiosity and patience. This will be the first time teaching this workshop, so it won't be perfect

### Installation of R Packages

``` r
library(devtools)

devtools::install_github("NMML/crawl",ref = "devel")
devtools::install_github("jmlondon/nPacMaps")
devtools::install_github("jmlondon/crawlr")

pkgs <- c(
  "tidyverse",
  "lubridate",
  "sp",
  "raster",
  "doParallel",
  "argosfilter"
)

install.packages(pkgs = pkgs)
```
