######################################################################
# Name of Script - 00_setup-environment.R                            #   
# Publication - HRI Long Term Conditions Wrokbook                    #
# Original Author - Federico Centoni                                 #
# Original date - August 2021                                        #   
#                                                                    #
# Written/run on - R Studio Server                                   #
# Version of R - 3.5.1                                               #
#                                                                    #
# Description of content - Setup environment to run 01_create-data.R #
######################################################################

### 1 - Load packages ----

library(dplyr)         # For data manipulation in the "tidy" way
library(readr)         # For reading in csv files
library(janitor)       # For 'cleaning' variable names
library(magrittr)      # For %<>% operator
library(lubridate)     # For dates
library(tidylog)       # For printing results of some dplyr functions
library(tidyr)         # For data manipulation in the "tidy" way
library(stringr)       # For string manipulation and matching
library(here)          # For the here() function
library(glue)          # For working with strings
library(purrr)         # For functional programming
library(fst)           # For reading source linkage files
library(haven)         # For writing sav files
library(slfhelper)     # For Source Linkage File data wrangling
library(phsmethods)    # For loading PHS data wrangling functions

### 2 - Define Whether Running on Server or Locally ----

if (sessionInfo()$platform %in% c("x86_64-redhat-linux-gnu (64-bit)",
                                  "x86_64-pc-linux-gnu (64-bit)")) {
  platform <- "server"
} else {
  platform <- "locally"
}

# Define root directory for stats server based on whether script is running 
# locally or on server
filepath <- dplyr::if_else(platform == "server",
                           "/conf/",
                           "//stats/") 

### 3 - House Keeping 

# Define financial years for extraction
finyear <- c("1718", "1819", "1920", "2021")

# Define output path
filepath <- "/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/data/basefiles/" 


# Define LTC names (according to columns in SLF)
ltc_names <- c(
  "cvd", "copd", "dementia", "diabetes", "chd", "hefailure", "refailure", "epilepsy",
  "asthma", "atrialfib", "cancer", "arth", "parkinsons", "liver", "ms"
)

