######################################################################
# Name of Script - 00_setup-environment.R                            #   
# Publication - Health & Social Care Expenditure Workbook            #
# Original Author - Ryan Harris                                      #
# Original date - June 2022                                          #   
#                                                                    #
# Written/run on - R Studio Server                                   #
# Version of R - 3.6.1                                               #
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

# Define financial years for extraction
year <- "2019-20"
Mapyear <- "2019"

# Define filepaths
filepath <- "/conf/sourcedev/TableauUpdates/H&SC Expenditure/H&SC Expenditure/data/"
filepath2 <- "/conf/sourcedev/TableauUpdates/H&SC Expenditure/H&SC Expenditure/output/"
lookup <- "/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Lookups/"