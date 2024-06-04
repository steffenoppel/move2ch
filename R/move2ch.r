##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~######################################
########## PREPARE CAPTURE HISTORY FOR SURVIVAL ESTIMATION  FROM TRACKING DATA #############
##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~######################################

#' Prepare an encounter history in matrix format from telemetry data of tracked individuals.
#'
#' \code{move2ch} extracts telemetry data from Movebank and converts them into an encounter history for survival estimation where there is
#' one column for each primary occasion and one row for each individual contained in the data.
#'
#'
#' @param study_id numeric. Study-id of a tracking study on Movebank that can be used to download data from \link[=https://movebank.org/]{Movebank}.
#' Must be publicly accessible.
#' @param occasion can be specified in different way compatible with \code{base::seq.Date}. Either as numeric value, which will be taken in days,
#' or as a character string , containing one of "day", "week", "month", "quarter" or "year". This can optionally be preceded by an integer and a space, or followed by "s".
#' @param start_cut date. Optional cut-off date for the start of the study if some data before that date should be eliminated. Defaults to today-30 years.
#' @param end_cut  date. Optional cut-off date for the end of the study if some data after that date should be eliminated. Defaults to today.

#' @return Returns a tibble with one row for each individual and one column for each primary occasion (specified by \code{occasion}). The numbers in each matrix cell are the number of GPS locations for that individual in that occasion period.
#'
#'
#' @export 
#' @importFrom lubridate years days
#' @importFrom move2 movebank_download_deployment movebank_retrieve
#' @importFrom dplyr rename left_join select filter join_by mutate group_by summarise ungroup arrange pull bind_cols
#' @importFrom tidyr spread


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SET UP FUNCTION INPUT VALUES ----------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

move2ch <- function(study_id=37350671,
                    occasion="1 month",
                    start_cut=Sys.time()-lubridate::years(30),
                    end_cut=Sys.time()){


options(warn=-1)  ## suppresses warnings that some numbers will yield NA
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DOWNLOAD MOVEBANK DATA AND ANIMAL INFO ----------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
deployments<-move2::movebank_download_deployment(study_id=study_id, 'license-md5'='5540d8f05d233b288cca6f255431a3ed') # only needed for troubleshooting because move2 objects have no individual ID
birds<-move2::movebank_retrieve(study_id=study_id, entity_type="individual", 'license-md5'='5540d8f05d233b288cca6f255431a3ed') %>%
  dplyr::rename(individual_id=id,bird_id=local_identifier) %>%
  dplyr::left_join(deployments[,1:4], by="individual_id") %>%
  dplyr::select(individual_id,deployment_id, bird_id,sex)
locs<-move2::movebank_retrieve(study_id=study_id, 'license-md5'='5540d8f05d233b288cca6f255431a3ed',
                         entity_type="event",
                         sensor_type_id="gps",
                         progress=T)%>%
  dplyr::left_join(birds, by="individual_id") %>%
  dplyr::filter(timestamp>=start_cut & timestamp<=end_cut)




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE TIMELINE WITH COLUMN INDICES FOR EACH PRIMARY PERIOD
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### CREATE A TIME SERIES DATA FRAME ###
mindate<-min(locs$timestamp)-lubridate::days(1)
maxdate<-max(locs$timestamp)+lubridate::days(1)
timeseries<-data.frame(date=seq(mindate, maxdate, occasion)) %>%
  mutate(OCC=seq_along(date))
dim(timeseries)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE MATRIX OF ENCOUNTERS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CH<-locs %>%
  dplyr::filter(!is.na(timestamp)) %>%
  dplyr::filter(!is.na(location_long)) %>%
  dplyr::filter(!is.na(bird_id)) %>%
  dplyr::filter(!is.na(location_lat)) %>%
  dplyr::left_join(timeseries, dplyr::join_by(closest(timestamp > date))) %>%
  dplyr::mutate(count=1) %>%
  dplyr::group_by(individual_id,OCC) %>%
  dplyr::summarise(N=sum(count)) %>%
  dplyr::ungroup() %>%
  tidyr::spread(key=OCC,value=N, fill=0)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# INSERT MISSING COLUMNS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
missoccs<-which(!(timeseries$OCC %in% as.numeric(names(CH))))
if(length(missoccs)>0) {
  CHnew<-CH %>%
  `[<-`(., as.character(missoccs), value = 0)
  CHnew<-CHnew %>% dplyr::select(
  data.frame(x=colnames(CHnew)[-1]) %>%
    dplyr::arrange(as.numeric(x)) %>% dplyr::pull(x)
  )
  CH<-dplyr::bind_cols(CH[,1],CHnew)
}

return(CH)


}  ### END FUNCTION
