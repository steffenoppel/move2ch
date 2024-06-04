---
title: "move2ch"
author: "steffen oppel"
date: "2024-05-30"
output: html_document
---



# move2ch

This R package is intended to help with estimating survival probability from animal tracking data. To facilitate such analyses, the package downloads the tracking data from Movebank and then creates an encounter history for survival analysis.

This package was developed to demonstrate how to create an R package and the utility of the function has not been tested on other Movebank studies.

## Installation

This package is not available on CRAN and must therefore be installed from [GitHub](https://github.com/steffenoppel/move2ch) with the following command. Note that depending on the R version and operating system you are working on, you may need to specify the download options. See [here](https://cran.r-project.org/web/packages/remotes/readme/README.html) for options for other operating systems (only Windows OS option shown in code below):


```r
library(remotes)
options(download.file.method="wininet")  ### for Windows OS 
remotes::install_github("steffenoppel/move2ch", dependencies=TRUE)
library(move2ch)
```


# How to use move2ch

There is only one function and you only need to enter two input parameters - the Movebank study id and the time span for an occasion. You can optionally also add a temporal cutoff for the beginning and end of the study.


```r
myCH <- move2ch(study_id=37350671,
                occasion="2 weeks",
                start_cut=ymd("2012-01-10"),
                end_cut=ymd("2023-01-10"))
```

That's it!
