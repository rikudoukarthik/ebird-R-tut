### Two methods of importing data from the extracted EBD .txt file into R    ###
###                                                                          ###
### 1. Using auk package (pre-built functions for working with eBird data)   ###
### 2. Using base R & tidyverse (bare approach with greater flexibility)     ###


# Make sure you are in the correct RStudio project/directory, and data file is present.
# Install the necessary packages using install.packages("packagename") before loading with 
# library(packagename). Once installed, in subsequent sessions the package can be loaded 
# right away with library(packagename).


library(tidyverse)


### 1. Using auk ############

library(auk)

# Defining the input (the extracted .txt) and output files
f_in <- "ebd_IN_relOct-2021.txt"
f_out <- "ebd_IN_relOct-2021_filt.txt"


# Creating a vector containing names of columns of interest.
# Go through metadata file to decide which of 48 columns are necessary for your analysis,  
# and modify this vector accordingly.
preimp <- c("global unique identifier","category","common name","scientific name","observation count",
            "locality id","locality type","reviewed","approved","state","county","last edited date",
            "latitude","longitude","observation date","time observations started","observer id",
            "protocol type","duration minutes","effort distance km","locality","breeding code",
            "number observers","all species reported","group identifier","sampling event identifier",
            "trip comments","has media")


# Importing data and assigning it to object named "data"
data <- f_in %>% # where from
  auk_ebd() %>% # function that creates auk_ebd object
  auk_date(date = c("2020-01-01", "2020-12-31")) %>% # for observations from year 2020
  # Many other filter functions exist, refer to Cornell's webpage for auk (linked in article).
  # Also note: if you want to import entire data for India, none of these filters are to be used.
  auk_filter(file = f_out, keep = preimp, overwite = T) %>% 
  # Runs the filters + reads only those columns we have predefined in "preimp".
  read_ebd() # read new .txt file into R session as data.frame

# Took 13 minutes on a system with 16 GB RAM, after defining import filters. Probably not
# a great idea on systems with lower computational power. Hence, better to download filtered
# datasets or use second method.


# Save the cleaned data as .RData which can be loaded directly in future sessions.
save(data, file = "data2020.RData") # 1 minute with 16 GB RAM
rm(list = ls()) # clean R workspace (environment) completely
detach(package:auk, unload = T) # remove auk from session

load("data2020.RData") # 25 seconds with 16 GB RAM
# This is the command to be used in subsequent sessions to load the saved .RData file



### 2. Using base R & tidyverse ############

# Defining input file
rawpath <- "ebd_IN_relOct-2021.txt"


# Creating vector containing names of columns of interest.
# Go through metadata file to decide which of 48 columns are necessary for your analysis,  
# and modify this vector accordingly.
# (Syntax is different in both methods: note different letter case and delimiter.)
preimp <- c("GLOBAL.UNIQUE.IDENTIFIER","CATEGORY","COMMON.NAME","SCIENTIFIC.NAME","OBSERVATION.COUNT",
            "LOCALITY.ID","LOCALITY.TYPE","REVIEWED","APPROVED","STATE","COUNTY","LAST.EDITED.DATE",
            "LATITUDE","LONGITUDE","OBSERVATION.DATE","TIME.OBSERVATIONS.STARTED","OBSERVER.ID",
            "PROTOCOL.TYPE","DURATION.MINUTES","EFFORT.DISTANCE.KM","LOCALITY","BREEDING.CODE",
            "NUMBER.OBSERVERS","ALL.SPECIES.REPORTED","GROUP.IDENTIFIER","SAMPLING.EVENT.IDENTIFIER",
            "TRIP.COMMENTS","HAS.MEDIA")


# Defining which columns to import and which to not
nms <- names(read.delim(rawpath, nrows = 1, sep = "\t", header = T, quote = "", stringsAsFactors = F,
                        na.strings = c(""," ", NA)))
nms[!(nms %in% preimp)] <- "NULL"
nms[nms %in% preimp] <- NA

# IMPORTANT: always ensure that all the arguments are specified, to avoid import errors.
data <- read.delim(rawpath, colClasses = nms, sep = "\t", header = T, quote = "",
                   stringsAsFactors = F, na.strings = c(""," ",NA))
# Took 7.5 minutes on a system with 16 GB RAM, even without import filters. However, in 
# this import method, filtering by species, date, region, etc. is possible only after
# the above step, i.e., after the raw data is read in to R. On a system with 8 GB RAM,  
# this process might take 10-15 minutes. Hence, although this method is faster than the
# auk method, it still might not be ideal for systems with low computational power. In such
# cases, it might be better to download filtered datasets directly from the download page. 

library(lubridate)
data <- data %>% mutate(YEAR = year(OBSERVATION.DATE)) %>% 
  filter(YEAR == 2020) # gives observations from year 2020 (1-2 minutes with 16 GB RAM)

# Save the cleaned data as .RData which can be loaded directly in future sessions.
save(data, file = "data2020.RData") # <1 minute with 16 GB RAM
# Note that we have used the same file name as in method 1, so the earlier file will be
# overwritten. In normal scenarios, you will use only one method so this doesn't matter.
rm(list = ls()) # clean R workspace (environment) completely

load("data2020.RData") # 25 seconds with 16 GB RAM
# This is the command to be used in subsequent sessions to load the saved .RData file

