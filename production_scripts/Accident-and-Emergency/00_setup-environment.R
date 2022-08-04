######################################################################
# Name of Script - 00_setup-environment.R                            #   
# Publication - Accident & Emergency Workbook                        #
# Original Author - Ryan Harris                                      #
# Original date - October 2021                                       #   
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
library(data.table)    # For quicker aggregates
library(dtplyr)        # Data table manipulation

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
# Define population years 
population_years <- as.character(c(2017:2020))

# Define output path
filepath <- "/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/" 


# Define LTC names (according to columns in SLF)
ltc_names <- c(
  "cvd", "copd", "dementia", "diabetes", "chd", "hefailure", "refailure", "epilepsy",
  "asthma", "atrialfib", "cancer", "arth", "parkinsons", "liver", "ms"
)

is_missing <- function(x) {
  if (typeof(x) != "character") {
    rlang::abort(
      message = glue::glue("You must supply a character vector, but {class(x)} was supplied.")
    )
  }
  return(is.na(x) | x == "")
}


# Returns the Locality/Datazone lookup file dated with the argument "appendeddate"
get_dz_lookup <- function(appendeddate, columns) {
  fullpath <- fs::path(stringr::str_glue(
    "/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_{appendeddate}.rds"
  ))
  dz_lookup <- readr::read_rds(fullpath)
  dz_lookup %<>% dplyr::select(dplyr::all_of(columns))
  dz_lookup %<>% tibble::as_tibble(dz_lookup)
  return(dz_lookup)
}


# Returns the Location code to Location name lookup file. Argument specifies the columns to choose
get_hosp_lookup <- function(columns) {
  hosp_lookup <- haven::read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav", col_select = columns)
  return(hosp_lookup)
}

#Read in lca lookup as new file
LCA_lookup <- read_sav("/conf/irf/05-lookups/04-geography/LCA_lookup.sav")
lca_lookup_2 <- LCA_lookup %>% mutate(lca = str_trim(LCAcode, side = c("both"))) %>% 
  mutate(lcalength = str_length(lca)) %>% 
  select(lca, LCAname)

#Read in age group population lookup data, modify sex and lca variables to match main file
#Pop_2021 <- read_sav(str_glue("/conf/sourcedev/TableauUpdates/A&E/Outputs/Population_Data/agegroups202021.sav"))
#Pop_1920 <- read_sav(str_glue("/conf/sourcedev/TableauUpdates/A&E/Outputs/Population_Data/agegroups201920.sav"))
#Pop_1819 <- read_sav(str_glue("/conf/sourcedev/TableauUpdates/A&E/Outputs/Population_Data/agegroups201819.sav"))
#Pop_1718 <- read_sav(str_glue("/conf/sourcedev/TableauUpdates/A&E/Outputs/Population_Data/agegroups201718.sav"))
#Pop <- bind_rows(Pop_2021, Pop_1920, Pop_1819, Pop_1718)
#Pop <- mutate(Pop, Sex = as.character(Sex))
#Pop <- mutate(Pop, lca = as.character(lca))

# This function is hard-coded with the standard age groups we use in the Source platform.
# Do not use if you need different age groups.
standard_age_groups <- function(dataset, age_variable) {
  agerecoded <- dplyr::mutate(dataset,
                              age_group = dplyr::case_when(
                                {{ age_variable }} < 18 ~ "0-17",
                                dplyr::between({{ age_variable }}, 18, 44) ~ "18-44",
                                dplyr::between({{ age_variable }}, 45, 64) ~ "45-64",
                                dplyr::between({{ age_variable }}, 65, 74) ~ "65-74",
                                dplyr::between({{ age_variable }}, 75, 84) ~ "75-84",
                                {{ age_variable }} >= 85 ~ "85+",
                                {{ age_variable }} == 999 ~ "Unknown",
                                is.na({{ age_variable }}) ~ "Unknown"
                              )
  )
  return(agerecoded)
}


# Function to create small extracts for Tabstore
tabstore <- function(dataset, lcavariable, workbookname) {
  small <- dplyr::distinct(dataset, {{ lcavariable }}, .keep_all = TRUE)
  haven::write_sav(small, stringr::str_glue(workbookname, "Small_", "{Sys.Date()}", ".sav"))
  return(small)
}


lcaname_to_hb <- function(dataset, lcaname) {
  return <- dataset %>% dplyr::mutate(
    Hbres = dplyr::case_when(
      {{ lcaname }} == "East Ayrshire" | {{ lcaname }} == "North Ayrshire" | {{ lcaname }} == "South Ayrshire" ~ "Ayrshire & Arran Region",
      {{ lcaname }} == "Scottish Borders" ~ "Borders Region",
      {{ lcaname }} == "Dumfries & Galloway" ~ "Dumfries & Galloway Region",
      {{ lcaname }} == "Fife" ~ "Fife Region",
      {{ lcaname }} == "Clackmannanshire" | {{ lcaname }} == "Falkirk" | {{ lcaname }} == "Stirling" | {{ lcaname }} == "Clackmannanshire & Stirling" ~ "Forth Valley Region",
      {{ lcaname }} == "Aberdeen City" | {{ lcaname }} == "Aberdeenshire" | {{ lcaname }} == "Moray" | {{ lcaname }} == "Grampian" ~ "Grampian Region",
      {{ lcaname }} == "East Dunbartonshire" | {{ lcaname }} == "East Renfrewshire" | {{ lcaname }} == "Glasgow City" | {{ lcaname }} == "Inverclyde" | {{ lcaname }} == "Renfrewshire" | {{ lcaname }} == "West Dunbartonshire" ~ "Greater Glasgow & Clyde Region",
      {{ lcaname }} == "Argyll & Bute" | {{ lcaname }} == "Argyll and Bute" | {{ lcaname }} == "Highland" ~ "Highland Region",
      {{ lcaname }} == "North Lanarkshire" | {{ lcaname }} == "South Lanarkshire" ~ "Lanarkshire Region",
      {{ lcaname }} == "City of Edinburgh" | {{ lcaname }} == "Edinburgh City" | {{ lcaname }} == "Midlothian" | {{ lcaname }} == "East Lothian" | {{ lcaname }} == "West Lothian" ~ "Lothian Region",
      {{ lcaname }} == "Orkney Islands" ~ "Orkney Region",
      {{ lcaname }} == "Shetland Islands" ~ "Shetland Region",
      {{ lcaname }} == "Angus" | {{ lcaname }} == "Dundee City" | {{ lcaname }} == "Perth & Kinross" | {{ lcaname }} == "Perth and Kinross" ~ "Tayside Region",
      {{ lcaname }} == "Comhairle nan Eilean Siar" | {{ lcaname }} == "Na h-Eileanan Siar" ~ "Western Isles Region",
      {{ lcaname }} == "" | {{ lcaname }} == "Other Non Scottish Residents" ~ "Other Non Scottish Residents"
    ))
}


lcaname_to_code <- function(dataset, lcaname) {
  return <- dataset %>% dplyr::mutate(
    LA_CODE = dplyr::case_when(
      {{ lcaname }} == "Scottish Borders" ~ "S12000026",
      {{ lcaname }} == "Fife" ~ "S12000015",
      {{ lcaname }} == "Orkney Islands" ~ "S12000023",
      {{ lcaname }} == "Comhairle nan Eilean Siar" ~ "S12000013",
      {{ lcaname }} == "Dumfries & Galloway" ~ "S12000006",
      {{ lcaname }} == "Shetland Islands" ~ "S12000027",
      {{ lcaname }} == "North Ayrshire" ~ "S12000021",
      {{ lcaname }} == "South Ayrshire" ~ "S12000028",
      {{ lcaname }} == "East Ayrshire" ~ "S12000008",
      {{ lcaname }} == "East Dunbartonshire" ~ "S12000045",
      {{ lcaname }} == "Glasgow City" ~ "S12000046",
      {{ lcaname }} == "East Renfrewshire" ~ "S12000011",
      {{ lcaname }} == "West Dunbartonshire" ~ "S12000039",
      {{ lcaname }} == "Renfrewshire" ~ "S12000038",
      {{ lcaname }} == "Inverclyde" ~ "S12000018",
      {{ lcaname }} == "Highland" ~ "S12000017",
      {{ lcaname }} == "Argyll & Bute" ~ "S12000035",
      {{ lcaname }} == "North Lanarkshire" ~ "S12000044",
      {{ lcaname }} == "South Lanarkshire" ~ "S12000029",
      {{ lcaname }} == "Aberdeen City" ~ "S12000033",
      {{ lcaname }} == "Aberdeenshire" ~ "S12000034",
      {{ lcaname }} == "Moray" ~ "S12000020",
      {{ lcaname }} == "East Lothian" ~ "S12000010",
      {{ lcaname }} == "West Lothian" ~ "S12000040",
      {{ lcaname }} == "Midlothian" ~ "S12000019",
      {{ lcaname }} == "Edinburgh City" ~ "S12000036",
      {{ lcaname }} == "Perth & Kinross" ~ "S12000024",
      {{ lcaname }} == "Dundee City" ~ "S12000042",
      {{ lcaname }} == "Angus" ~ "S12000041",
      {{ lcaname }} == "Clackmannanshire" ~ "S12000005",
      {{ lcaname }} == "Falkirk" ~ "S12000014",
      {{ lcaname }} == "Stirling" ~ "S12000030"
  ))
}


hbcode_to_hb <- function(dataset, hbtreatcode) {
  return <- dataset %>% dplyr::mutate(
    Hb_Treatment = dplyr::case_when(
          {{ hbtreatcode }} == "S08000015" ~ "Ayrshire & Arran Region",
          {{ hbtreatcode }} == "S08000016" ~ "Borders Region",
          {{ hbtreatcode }} == "S08000017" ~ "Dumfries & Galloway Region",
          {{ hbtreatcode }} == "S08000029" ~ "Fife Region",
          {{ hbtreatcode }} == "S08000019" ~ "Forth Valley Region",
          {{ hbtreatcode }} == "S08000020" ~ "Grampian Region",
          {{ hbtreatcode }} == "S08000021" ~ "Greater Glasgow & Clyde Region",
          {{ hbtreatcode }} == "S08000022" ~ "Highland Region",
          {{ hbtreatcode }} == "S08000023" ~ "Lanarkshire Region",
          {{ hbtreatcode }} == "S08000024" ~ "Lothian Region",
          {{ hbtreatcode }} == "S08000025" ~ "Orkney Region",
          {{ hbtreatcode }} == "S08000026" ~ "Shetland Region",
          {{ hbtreatcode }} == "S08000030" ~ "Tayside Region",
          {{ hbtreatcode }} == "S08000028" ~ "Western Isles Region",
          {{ hbtreatcode }} == "All" ~ "All"
  ))
}
