##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~######################################
########## STEP BY STEP GUIDE TO CREATE AN R PACKAGE --------- #############
##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~######################################
#### some guidance can be found at these sites ###
## https://r-pkgs.org/man.html
## https://www.mjandrews.org/blog/how-to-make-an-R-package/
## https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/
## https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html


library(devtools)
library(usethis)
library(roxygen2)
library(sinew)
library(knitr)



### STEP 1. WRITE CODE -------

### STEP 2. CREATE PACKAGE BACKBONE -------
devtools::create("move2ch")

### manually amend the DESCRIPTION file in a text editor (this doesn't work with the cat command above)
# Package: move2ch
# Title: Convert tracking data into encounter history
# Version: 1.0.0
# Authors@R:
#   person("Steffen", "Oppel", , "steffen.oppel@vogelwarte.ch", role = c("aut", "cre"),
#          comment = c(ORCID = "0000-0002-8220-3789"))
# Description: This tool downloads tracking data from Movebank and then creates an encounter history to facilitate survival analysis.
# License: `use_mit_license()`
# Encoding: UTF-8


### STEP 3. MOVE THE R FUNCTION FILES INTO THE R FOLDER OF THE PACKAGE DIRECTORY -------


### STEP 4. WRITE DOCUMENTATION INTO CODE -------
### add the header information to your function code file
### write a vignette as R markdown (.rmd) file
# usethis::use_vignette(name="move2ch")
devtools::load_all(path="./move2ch")
sinew::makeOxygen(obj=move2ch)  ### this creates the list of all functions that you can copy into the header of your R function


### STEP 5. CREATING THE DOCUMENTATION FOR THE PACKAGE -------
roxygen2::roxygenize(package.dir = "./move2ch")
devtools::document(pkg="./move2ch")


### close this script and move it inside the created R package folder and also move the functions into the /R subfolder
## you need to run this function from inside the package OR MANUALLY ADD 'export("%>%")' to the NAMESPACE
### creates a utility function for the pipe operator
usethis::use_pipe()
usethis::use_package('move2')
usethis::use_package('lubridate')
usethis::use_package('tidyr')
usethis::use_package('dplyr')
devtools::document()

### STEP 6. OPTIONAL - ADD DATA IF YOUR PACKAGE COMES WITH DATA -------
# kite.tracks <- fread("whateverdata.csv"))
# usethis::use_data(kite.tracks)

### STEP 7. OPTIONAL - CREATE THE README VIGNETTE FOR YOUR PACKAGE -------
knit(input="README.rmd", output = "README.md") #see ?knit for more options


### STEP 8. INSTALL THE PACKAGE LOCALLY ON YOUR COMPUTER -------
devtools::load_all()
devtools::install()

## you can now test whether it works:
library(move2ch)
move2ch(study_id=37350671,occasion="2 weeks",start_cut=ymd("2012-01-10"),end_cut=ymd("2023-01-10"))


### STEP 9. PUBLISH THE PACKAGE IN A GIT HUB REPO SO OTHERS CAN USE IT -------
## https://medium.com/@abertozz/turning-an-r-package-into-a-github-repo-aeaebacfe1c
## if you encounter problems with git credentials check out: https://usethis.r-lib.org/articles/articles/git-credentials.html
usethis::use_git()
usethis::use_github()


### STEP 10. DOWNLOAD, INSTALL, and TEST ON ANOTHER MACHINE-------
devtools::install_github("steffenoppel/move2ch")
library(move2ch)
?move2ch
move2ch(study_id=37350671,occasion="3 weeks",start_cut=ymd("2012-01-10"),end_cut=ymd("2023-01-10"))


