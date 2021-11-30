### Cleaning and setting up data for analysis using best practices               ###
###                                                                              ###
### This succeeds the steps in "data-handling_01_extract-and-import.R".          ###
### Think deep about kinds of analysis to be done, and modify data accordingly.  ###


# Make sure you are in the correct RStudio project/directory, and data file is present.


library(tidyverse)
library(lubridate)
# Load in imported data from .RData file
load("data2020.RData")


### Cleaning and setting up data ############


# Creating a function that calculates week-of-year from a date value.
# This will be used to create some new useful columns in our dataset.
met_week <- function(dates) {
  require(lubridate)
  normal_year <- c((0:363 %/% 7 + 1), 52)
  leap_year   <- c(normal_year[1:59], 9, normal_year[60:365])
  year_day    <- yday(dates)
  return(ifelse(leap_year(dates), leap_year[year_day], normal_year[year_day])) 
}

# Adding useful columns to data. Ignore some if not necessary on case-by-case basis. 
# (1 min for all columns, 16 GB RAM)
data <- data %>% 
  mutate(GROUP.ID = ifelse(is.na(GROUP.IDENTIFIER),SAMPLING.EVENT.IDENTIFIER, 
                           GROUP.IDENTIFIER), # useful to later remove duplicate lists
         OBSERVATION.DATE = as.Date(OBSERVATION.DATE), # convert from character to date 
         YEAR = year(OBSERVATION.DATE), # calendar year
         MONTH = month(OBSERVATION.DATE), # month
         DAY.M = day(OBSERVATION.DATE), # day-of-month 
         DAY.Y = yday(OBSERVATION.DATE), # day-of-year
         WEEK.Y = met_week(OBSERVATION.DATE), # week-of-year
         M.YEAR = if_else(DAY.Y <= 151, YEAR-1, YEAR), # migratory year (from 1st June to 31st May)
         WEEK.MY = if_else(WEEK.Y > 21, WEEK.Y-21, 52-(21-WEEK.Y)) # week-of-migratory-year
  )

# Overwrites earlier .RData file with updated data. If undesired use different name. (<2 min)
save(data, file = "data2020.RData") 


# Filtering for unique checklists (removing duplicates). This is particularly important
# when analysing frequency of reporting of species, because the shared lists are all part of
# the same birding event, and not separate ones in which the species was reported. Skipping
# this step will result in these lists incorrectly inflating the frequencies of the species.
# (4 min; data reduced by 25%)
data0 <- data %>% 
  group_by(COMMON.NAME,GROUP.ID) %>% slice(1) # retains only 1 birding event-species combination


# Filtering for complete checklists. This is also important when analysing frequencies and 
# species trends over time, as complete lists hold information about non-detections too. This
# enables sound inferences on relative abundances at any point of time, as well as over time.
# (<1 min; data reduced by 4%)
data1 <- data0 %>% # uses data with duplicate lists already removed; else use the object "data"
  filter(ALL.SPECIES.REPORTED == 1) # removes incomplete lists, retains only unique & complete 



### Saving current workspace as .RData file ############

# Once a fair way into the analysis, you may not need the full imported data used at the start.
# Hence, it can be removed from the environment, and the rest of the environment can be saved 
# and reloaded in future sessions.

# As always, make sure you are in the specific RStudio project/directory. Otherwise, data/RData 
# files from different projects will get mixed up and overwritten (especially those named 
# "data" and "temp"). Carefully consider which data objects will be necessary and mention them
# in the command below. (Here, we assume only "data1" will be needed.)
rm(list = setdiff(ls(envir = .GlobalEnv), c("data1")), pos = ".GlobalEnv")
save.image("temp.RData") # < 2 mins
