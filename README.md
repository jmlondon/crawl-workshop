
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
devtools::install_github("jmlondon/wcUtils", ref = "develop")

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

##### Disclaimer

<sub>This repository is a scientific product and is not official communication of the Alaska Fisheries Science Center, the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All AFSC Marine Mammal Laboratory (AFSC-MML) GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. AFSC-MML has relinquished control of the information and no longer has responsibility to protect the integrity, confidentiality, or availability of the information. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.</sub>
