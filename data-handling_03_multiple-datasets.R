### Creating multiple datasets from raw EBD download              ###
###                                                               ###
### Importing data from the extracted ebd .txt file and creating  ###
### multiple different data files for different projects.         ###


# Make sure you are in the correct RStudio project/directory, and data file is present.


library(tidyverse)
library(lubridate)

rawpath <- "ebd_IN_relOct-2021.txt"

preimp <- c("GLOBAL.UNIQUE.IDENTIFIER","CATEGORY","COMMON.NAME","SCIENTIFIC.NAME","OBSERVATION.COUNT",
            "LOCALITY.ID","LOCALITY.TYPE","REVIEWED","APPROVED","STATE","COUNTY","LAST.EDITED.DATE",
            "LATITUDE","LONGITUDE","OBSERVATION.DATE","TIME.OBSERVATIONS.STARTED","OBSERVER.ID",
            "PROTOCOL.TYPE","DURATION.MINUTES","EFFORT.DISTANCE.KM","LOCALITY","BREEDING.CODE",
            "NUMBER.OBSERVERS","ALL.SPECIES.REPORTED","GROUP.IDENTIFIER","SAMPLING.EVENT.IDENTIFIER",
            "TRIP.COMMENTS","HAS.MEDIA")

nms <- names(read.delim(rawpath, nrows = 1, sep = "\t", header = T, quote = "", stringsAsFactors = F,
                        na.strings = c(""," ", NA)))
nms[!(nms %in% preimp)] <- "NULL"
nms[nms %in% preimp] <- NA

data <- read.delim(rawpath, colClasses = nms, sep = "\t", header = T, quote = "",
                   stringsAsFactors = F, na.strings = c(""," ",NA)) # 7.5 min (16 GB RAM)


met_week <- function(dates) {
  require(lubridate)
  normal_year <- c((0:363 %/% 7 + 1), 52)
  leap_year   <- c(normal_year[1:59], 9, normal_year[60:365])
  year_day    <- yday(dates)
  return(ifelse(leap_year(dates), leap_year[year_day], normal_year[year_day])) 
}

data <- data %>% 
  mutate(GROUP.ID = ifelse(is.na(GROUP.IDENTIFIER),SAMPLING.EVENT.IDENTIFIER, 
                           GROUP.IDENTIFIER), 
         OBSERVATION.DATE = as.Date(OBSERVATION.DATE), 
         YEAR = year(OBSERVATION.DATE), 
         MONTH = month(OBSERVATION.DATE),
         DAY.M = day(OBSERVATION.DATE),
         DAY.Y = yday(OBSERVATION.DATE),
         WEEK.Y = met_week(OBSERVATION.DATE),
         S.YEAR = if_else(DAY.Y <= 151, YEAR-1, YEAR),
         WEEK.SY = if_else(WEEK.Y > 21, WEEK.Y-21, 52-(21-WEEK.Y))) # 4.5 min


# Saving full dataset for India
rm(list = setdiff(ls(envir = .GlobalEnv), c("data")), pos = ".GlobalEnv")
save.image("ebd_IN_relOct-2021.RData") # <5 min


# Saving data for year 2020 (as in first exercise)
data1 <- data %>% filter(YEAR == 2020) # <10 sec
save(data1, file = "ebd_IN_relOct-2021_2020.RData") # 1 min
rm(data1)


# Saving data for south India
data2 <- data %>% filter(STATE %in% c("Kerala","Tamil Nadu","Karnataka",
                                      "Andhra Pradesh","Telangana")) # 45 sec
save(data2, file = "ebd_IN_relOct-2021_S-IN.RData") # 3 min
rm(data2)


# Saving data for Aquila eagles
data3 <- data %>% filter(grepl("Aquila", SCIENTIFIC.NAME)) # 5 sec
save(data3, file = "ebd_IN_relOct-2021_Aquila.RData")
rm(data3)


# Saving data for Indian Pitta from Maharashtra
data4 <- data %>% filter(COMMON.NAME == "Indian Pitta" &
                           STATE == "Maharashtra") # <2 sec
save(data4, file = "ebd_IN_relOct-2021_InPi-MH.RData")
rm(data4)


# Various such subsets can be created for different analytical purposes, and the respective
# .RData files can be used (instead of importing the .txt) each time. 

rm(data)
