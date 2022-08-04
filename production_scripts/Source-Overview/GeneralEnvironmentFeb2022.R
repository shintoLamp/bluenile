library(readr)    # Read .RDS files
library(fs)       # Easier file paths
library(dplyr)    # General tidyverse
library(haven)    # Read/write .sav
library(slfhelper) # Open SLFs easier
library(stringr)  # String manipulation
library(tidyr)    # General
library(magrittr) # Pipe function
library(fst)      # Read/write fst
library(purrr)    # Mapping functions over lists
library(phsmethods) # PHS functions
library(styler)   # Code styling
library(rlang)    # General
library(tictoc)   # Timing functions
library(labelled) # Adding/removing variable labels
library(skimr)    # Easy-to-read data summaries
library(janitor)  # Cleaning data

# Returns the Locality/Datazone lookup file dated with the argument "appendeddate"
#get_dz_lookup <- function(appendeddate, columns) {
#  fullpath <- fs::path(stringr::str_glue(
#    "/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_{appendeddate}.rds"
#  ))
#  dz_lookup <- readr::read_rds(fullpath) %>% 
#    dplyr::select(dplyr::all_of(columns)) %>% 
#    tibble::as_tibble(dz_lookup)
#  return(dz_lookup)
#}    -----------> as_tibble was causing an error thus was removed and changed as follows: <-----------

get_dz_lookup <- function(appendeddate, columns) {
  fullpath <- fs::path(stringr::str_glue(
    "/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_{appendeddate}.rds"
  ))
  dz_lookup <- readr::read_rds(fullpath) %>% 
    dplyr::select(dplyr::all_of(columns)) %>%
    return(dz_lookup)
}

# Returns the Speciality lookup file. Argument specifies the columns to choose
get_spec_lookup <- function(columns) {
  spec_lookup <- haven::read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/Specialty_Groupings.sav", 
                                 col_select = columns)
  return(spec_lookup)
}

# Returns the Location code to Location name lookup file. Argument specifies the columns to choose
get_hosp_lookup <- function(columns) {
  hosp_lookup <- haven::read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav", 
                                 col_select = columns)
  return(hosp_lookup)
}

# This function is hard-coded with the standard age groups we use in the Source platform.
# Do not use if you need different age groups.
standard_age_groups <- function(dataset, age_variable) {
  agerecoded <- dplyr::mutate(dataset,
    age_grp = dplyr::case_when(
      {{ age_variable }} < 18 ~ "<18",
      dplyr::between({{ age_variable }}, 18, 44) ~ "18-44",
      dplyr::between({{ age_variable }}, 45, 64) ~ "45-64",
      dplyr::between({{ age_variable }}, 65, 74) ~ "65-74",
      dplyr::between({{ age_variable }}, 75, 84) ~ "75-84",
      {{ age_variable }} >= 85 ~ "85+",
      {{ age_variable }} == (999 | NA) ~ "Unknown"
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

# Function to use Location code to determine Health Board at said location
location_to_hb <- function(dataset, locationcode) {
  temp <- dataset %>% dplyr::mutate(
    hosp_hb_code = dplyr::case_when(
      stringr::str_sub({{ locationcode }}, end = 1) == "A" ~ "S08000015",
      stringr::str_sub({{ locationcode }}, end = 1) == "B" ~ "S08000016",
      stringr::str_sub({{ locationcode }}, end = 1) == "Y" ~ "S08000017",
      stringr::str_sub({{ locationcode }}, end = 1) == "F" ~ "S08000018",
      stringr::str_sub({{ locationcode }}, end = 1) == "V" ~ "S08000019",
      stringr::str_sub({{ locationcode }}, end = 1) == "N" ~ "S08000020",
      stringr::str_sub({{ locationcode }}, end = 1) == "G" ~ "S08000021",
      stringr::str_sub({{ locationcode }}, end = 1) == "H" ~ "S08000022",
      stringr::str_sub({{ locationcode }}, end = 1) == "L" ~ "S08000023",
      stringr::str_sub({{ locationcode }}, end = 1) == "S" ~ "S08000024",
      stringr::str_sub({{ locationcode }}, end = 1) == "R" ~ "S08000025",
      stringr::str_sub({{ locationcode }}, end = 1) == "Z" ~ "S08000026",
      stringr::str_sub({{ locationcode }}, end = 1) == "T" ~ "S08000027",
      stringr::str_sub({{ locationcode }}, end = 1) == "W" ~ "S08000028"
    )
  )
  return(temp)
}

# Function to assign 2-digit LCA codes based on CA2011/CA2018 codes
ca_to_2digitla <- function(dataset, cacode) {
  return <- dataset %>% dplyr::mutate(
    lca = dplyr::case_when(
      {{ cacode }} == "S12000026" ~ 5,
      {{ cacode }} == "S12000015" ~ 16,
      {{ cacode }} == "S12000023" ~ 24,
      {{ cacode }} == "S12000013" ~ 32,
      {{ cacode }} == "S12000006" ~ 08,
      {{ cacode }} == "S12000027" ~ 27,
      {{ cacode }} == "S12000021" ~ 22,
      {{ cacode }} == "S12000028" ~ 28,
      {{ cacode }} == "S12000008" ~ 10,
      {{ cacode }} == "S12000045" ~ 11,
      {{ cacode }} == "S12000046" ~ 17,
      {{ cacode }} == "S12000011" ~ 13,
      {{ cacode }} == "S12000039" ~ 7,
      {{ cacode }} == "S12000038" ~ 26,
      {{ cacode }} == "S12000018" ~ 19,
      {{ cacode }} == "S12000017" ~ 18,
      {{ cacode }} == "S12000044" ~ 23,
      {{ cacode }} == "S12000029" ~ 29,
      {{ cacode }} == "S12000033" ~ 1,
      {{ cacode }} == "S12000034" ~ 2,
      {{ cacode }} == "S12000020" ~ 21,
      {{ cacode }} == "S12000010" ~ 12,
      {{ cacode }} == "S12000040" ~ 31,
      {{ cacode }} == "S12000019" ~ 20,
      {{ cacode }} == "S12000036" ~ 14,
      {{ cacode }} == "S12000024" ~ 25,
      {{ cacode }} == "S12000042" ~ 9,
      {{ cacode }} == "S12000041" ~ 3,
      {{ cacode }} == "S12000005" ~ 6,
      {{ cacode }} == "S12000014" ~ 15,
      {{ cacode }} == "S12000030" ~ 30,
      {{ cacode }} == "S12000035" ~ 4
    )
  )
}

# Function to convert 2-digit LA codes to Hb codes
twodigitla_to_hb <- function(dataset, lcacodename) {
  return <- dataset %>% dplyr::mutate(
    hbres = dplyr::case_when(
      {{ lcacodename }} == 1 ~ "S08000020",
      {{ lcacodename }} == 2 ~ "S08000020",
      {{ lcacodename }} == 3 ~ "S08000027",
      {{ lcacodename }} == 4 ~ "S08000022",
      {{ lcacodename }} == 5 ~ "S08000016",
      {{ lcacodename }} == 6 ~ "S08000019",
      {{ lcacodename }} == 7 ~ "S08000021",
      {{ lcacodename }} == 8 ~ "S08000017",
      {{ lcacodename }} == 9 ~ "S08000027",
      {{ lcacodename }} == 10 ~ "S08000015",
      {{ lcacodename }} == 11 ~ "S08000021",
      {{ lcacodename }} == 12 ~ "S08000024",
      {{ lcacodename }} == 13 ~ "S08000021",
      {{ lcacodename }} == 14 ~ "S08000024",
      {{ lcacodename }} == 15 ~ "S08000019",
      {{ lcacodename }} == 16 ~ "S08000018",
      {{ lcacodename }} == 17 ~ "S08000021",
      {{ lcacodename }} == 18 ~ "S08000022",
      {{ lcacodename }} == 19 ~ "S08000021",
      {{ lcacodename }} == 20 ~ "S08000024",
      {{ lcacodename }} == 21 ~ "S08000020",
      {{ lcacodename }} == 22 ~ "S08000015",
      {{ lcacodename }} == 23 ~ "S08000023",
      {{ lcacodename }} == 24 ~ "S08000025",
      {{ lcacodename }} == 25 ~ "S08000027",
      {{ lcacodename }} == 26 ~ "S08000021",
      {{ lcacodename }} == 27 ~ "S08000026",
      {{ lcacodename }} == 28 ~ "S08000015",
      {{ lcacodename }} == 29 ~ "S08000023",
      {{ lcacodename }} == 30 ~ "S08000019",
      {{ lcacodename }} == 31 ~ "S08000024",
      {{ lcacodename }} == 32 ~ "S08000028"
    )
  )
}

population_fin_year <- function(dataset, yearvariable) {
  dataset <- dataset %>% 
    dplyr::mutate(year2 = as.integer( {{yearvariable}} ) + 1) %>% 
    mutate(year2 = as.character(year2)) %>% 
    mutate(year = str_c( {{yearvariable}}, "/", str_sub(year2, start = 3, end = 4))) %>% 
    select(-year2)
}

## Add 'all' group for given var
add_all <- function(df, var) {
  # Sorts variables into character type and numerical type, assigns to vector
  categorical_vars <- map_lgl(df, ~is.character(.x) | is.factor(.x))
  # Fills vector with the names of the categorical variables
  categorical_vars <- names(categorical_vars)[categorical_vars]
  
  # Create new data frame
  df_all <- df
  # Put a variable as the value 'All'
  df_all[[var]] <- "All"
  
  df_all %>% 
    # Group by all of the categorical variables
    group_by(across(all_of(categorical_vars))) %>% 
    # Summarise only the numeric variables
    summarise(across(where(is.numeric), sum),
              .groups = "drop")
}

lcaname_to_hb <- function(dataset, lcaname) {
  return <- dataset %>% dplyr::mutate(
    hb = dplyr::case_when(
      {{ lcaname }} == "East Ayrshire" | {{ lcaname }} == "North Ayrshire" | {{ lcaname }} == "South Ayrshire" ~ "NHS Ayrshire & Arran",
      {{ lcaname }} == "Scottish Borders" ~ "NHS Borders",
      {{ lcaname }} == "Dumfries & Galloway" ~ "NHS Dumfries & Galloway",
      {{ lcaname }} == "Fife" ~ "NHS Fife",
      {{ lcaname }} == "Clackmannanshire" | {{ lcaname }} == "Falkirk" | {{ lcaname }} == "Stirling" | {{ lcaname }} == "Clackmannanshire & Stirling" ~ "NHS Forth Valley",
      {{ lcaname }} == "Aberdeen City" | {{ lcaname }} == "Aberdeenshire" | {{ lcaname }} == "Moray" | {{ lcaname }} == "Grampian" ~ "NHS Grampian",
      {{ lcaname }} == "East Dunbartonshire" | {{ lcaname }} == "East Renfrewshire" | {{ lcaname }} == "Glasgow City" | {{ lcaname }} == "Inverclyde" | {{ lcaname }} == "Renfrewshire" | {{ lcaname }} == "West Dunbartonshire" ~ "NHS Greater Glasgow & Clyde",
      {{ lcaname }} == "Argyll & Bute" | {{ lcaname }} == "Highland" ~ "NHS Highland",
      {{ lcaname }} == "North Lanarkshire" | {{ lcaname }} == "South Lanarkshire" ~ "NHS Lanarkshire",
      {{ lcaname }} == "City of Edinburgh" | {{ lcaname }} == "Midlothian" | {{ lcaname }} == "East Lothian" | {{ lcaname }} == "West Lothian" ~ "NHS Lothian",
      {{ lcaname }} == "Orkney" ~ "NHS Orkney",
      {{ lcaname }} == "Shetland" ~ "NHS Shetland",
      {{ lcaname }} == "Angus" | {{ lcaname }} == "Dundee City" | {{ lcaname }} == "Perth & Kinross" ~ "NHS Tayside",
      {{ lcaname }} == "Western Isles" ~ "NHS Western Isles",
      {{ lcaname }} == "" | {{ lcaname }} == "Other Non Scottish Residents" ~ "Other Non Scottish Residents"
    ))
}

valid_lca_hb_check <- function(df) {
  df <- df %>%
    dplyr::mutate(
      invalid = dplyr::case_when(
        hbrescode == "S08000001" & (lca != "10" & lca != "22" & lca != "28") ~ TRUE,
        hbrescode == "S08000015" & (lca != "10" & lca != "22" & lca != "28") ~ TRUE,
        hbrescode == "S08000002" & lca != "05" ~ TRUE,
        hbrescode == "S08000016" & lca != "05" ~ TRUE,
        hbrescode == "S08000004" & (lca != "16") ~ TRUE,
        hbrescode == "S08000018" & (lca != "16") ~ TRUE,
        hbrescode == "S08000007" & (lca != "07" & lca != "11" & lca != "13" & lca != "17" &
          lca != "19" & lca != "26") ~ TRUE,
        hbrescode == "S08000021" & (lca != "07" & lca != "11" & lca != "13" & lca != "17" &
          lca != "19" & lca != "26") ~ TRUE,
        hbrescode == "S08000008" & (lca != "04" & lca != "18") ~ TRUE,
        hbrescode == "S08000022" & (lca != "04" & lca != "18") ~ TRUE,
        hbrescode == "S08000009" & (lca != "23" & lca != "29") ~ TRUE,
        hbrescode == "S08000023" & (lca != "23" & lca != "29") ~ TRUE,
        hbrescode == "S08000006" & (lca != "01" & lca != "02" & lca != "21") ~ TRUE,
        hbrescode == "S08000020" & (lca != "01" & lca != "02" & lca != "21") ~ TRUE,
        hbrescode == "S08000011" & lca != "24" ~ TRUE,
        hbrescode == "S08000025" & lca != "24" ~ TRUE,
        hbrescode == "S08000012" & lca != "27" ~ TRUE,
        hbrescode == "S08000026" & lca != "27" ~ TRUE,
        hbrescode == "S08000010" & (lca != "12" & lca != "14" & lca != "20" & lca != "31") ~ TRUE,
        hbrescode == "S08000024" & (lca != "12" & lca != "14" & lca != "20" & lca != "31") ~ TRUE,
        hbrescode == "S08000013" & (lca != "03" & lca != "09" & lca != "25") ~ TRUE,
        hbrescode == "S08000027" & (lca != "03" & lca != "09" & lca != "25") ~ TRUE,
        hbrescode == "S08000005" & (lca != "06" & lca != "15" & lca != "30") ~ TRUE,
        hbrescode == "S080000019" & (lca != "06" & lca != "15" & lca != "30") ~ TRUE,
        hbrescode == "S08000014" & lca != "32" ~ TRUE,
        hbrescode == "S08000028" & lca != "32" ~ TRUE,
        hbrescode == "S08000003" & lca != "08" ~ TRUE,
        hbrescode == "S08000017" & lca != "08" ~ TRUE,
        TRUE ~ FALSE
      )
    )
}
