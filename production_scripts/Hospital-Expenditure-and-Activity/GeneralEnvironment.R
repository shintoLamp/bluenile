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
library(dtplyr)   # Lazy data tables

hea_constants <- list(
  health_boards = c(
    "Ayrshire and Arran", "Ayrshire & Arran", "Borders", "Dumfries and Galloway", "Dumfries & Galloway",
    "Fife", "Forth Valley", "Greater Glasgow and Clyde", "Greater Glasgow & Clyde", "Grampian",
    "Highland", "Lanarkshire", "Lothian", "Orkney", "Shetland", "Tayside", "Western Isles"
  ),
  delegated_specs = c(
    "Accident & Emergency", "Forensic Psychiatry", "General Medicine", "General Psychiatry", "Geriatric Medicine",
    "GP Other than Obstetrics", "Learning Disability", "Palliative Medicine", "Psychiatry of Old Age",
    "Rehabilitation Medicine", "Respiratory Medicine"
  ),
  all_spec_names = c(
    "All", "Accident & Emergency", "Acute Medicine", "Adolescent Psychiatry", "Allergy", "Anaesthetics", "Cardiac Surgery", "Cardiology", "Cardiothoracic Surgery",
    "Child & Adolescent Psychiatry", "Child Psychiatry", "Clinical Oncology", "Communicable Diseases", "Community Dental Practice", "Dermatology", "Diabetes", "Diagnostic Radiology",
    "Ear, Nose & Throat (ENT)", "Endocrinology", "Endocrinology & Diabetes", "Forensic Psychiatry", "Gastroenterology", "General Medicine", "General Psychiatry", "General Surgery",
    "General Surgery (excl Vascular, Maxillofacial)", "Geriatric Medicine", "GP Other than Obstetrics", "Gynaecology", "Haematology", "Homoeopathy", "Immunology", "Learning Disability", "Medical Oncology",
    "Medical Paediatrics", "Nephrology", "Neurology", "Neurosurgery", "Ophthalmology", "Oral & Maxillofacial Surgery", "Oral Medicine", "Oral Surgery", "Orthopaedics", "Paediatric Dentistry",
    "Pain Management", "Palliative Medicine", "Plastic Surgery", "Psychiatry of Old Age", "Rehabilitation Medicine", "Respiratory Medicine", "Restorative Dentistry", "Rheumatology", "Surgical Paediatrics",
    "Thoracic Surgery", "Urology", "Vascular Surgery"
  ),
  key_vars_lca = c(
    "year", "recid", "mapcode", "hbrescode", "hbtreatcode", "hb_region_format", "hbresname", "lca", "lcaname",
    "ca2018", "location", "age_grp", "specname", "specialty_grp", "treated_board", "ipdc", "cij_pattype", "locality"
  ),
  key_vars_gp = c(
    "year", "recid", "prac", "practice_name", "cluster", "hbrescode", "hbtreatcode", "hb_region_format", "hbresname",
    "lca", "lcaname", "lca_practice", "ca2018", "age_grp", "specname", "specialty_grp", "treated_board", "ipdc", "cij_pattype"
  ),
  key_vars_board = c(
    "year", "recid", "mapcode", "hbrescode", "hbtreatcode", "hb_region_format", "hbresname", "age_grp", 
    "specname", "specialty_grp", "treated_board", "ipdc", "cij_pattype"
  )
)

# Read in a list of hospital location codes and the service they offer. These can be Acute, Community, or Mental Health.
get_hospital_services <- function() {
  hosp_services <- read_sav("/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/02-PLICS/Hosp_Services.sav") %>%
    # Ensure variable names are in R-friendly format
    clean_names() %>% 
    # Tidy up the variables for recoding later
    mutate(across(where(is.numeric), ~ as.character(.x))) %>% 
    mutate(service_offered = str_c(acute, community, mental_health)) %>% 
    select(-acute, -community, -mental_health)
  return(hosp_services)
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

# Returns the Speciality lookup file. Argument specifies the columns to choose
get_spec_lookup <- function(columns) {
  spec_lookup <- haven::read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/Specialty_Groupings.sav", col_select = all_of(columns))
  return(spec_lookup)
}

# Returns the Location code to Location name lookup file. Argument specifies the columns to choose
get_hosp_lookup <- function(columns) {
  hosp_lookup <- haven::read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav", col_select = columns)
  return(hosp_lookup)
}

# This function is hard-coded with the standard age groups we use in the Source platform.
# Do not use if you need different age groups.
standard_age_groups <- function(dataset, age_variable) {
  agerecoded <- dplyr::mutate(dataset,
    age_grp = dplyr::case_when(
      {{ age_variable }} < 18 ~ "0-17",
      dplyr::between({{ age_variable }}, 18, 44) ~ "18-44",
      dplyr::between({{ age_variable }}, 45, 64) ~ "45-64",
      dplyr::between({{ age_variable }}, 65, 74) ~ "65-74",
      dplyr::between({{ age_variable }}, 75, 84) ~ "75-84",
      {{ age_variable }} >= 85 ~ "85+",
      TRUE ~ "Missing"
    )
  )
  return(agerecoded)
}

# Function to split a large file (usually SLF) into manageable chunks for matching on lookups
managed_lookup <- function(dataset, lookup, matchby) {
  test <- dataset %>%
    dplyr::group_by(ca2018) %>%
    dplyr::left_join(
      {
        lookup
      },
      by = {
        matchby
      }
    ) %>%
    dplyr::ungroup()
  return(test)
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

# Function to use Location code to determine Health Board at said location
where_is_hospital <- function(dataset, locationcode, hbcode) {
  temp <- dataset %>% dplyr::mutate(
    hosp_board = dplyr::case_when(
      stringr::str_sub({{ locationcode }}, end = 1) == "A" ~ "Ayrshire & Arran Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "B" ~ "Borders Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "Y" ~ "Dumfries & Galloway Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "F" ~ "Fife Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "V" ~ "Forth Valley Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "N" ~ "Grampian Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "G" ~ "Greater Glasgow & Clyde Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "D" ~ "Golden Jubilee",
      stringr::str_sub({{ locationcode }}, end = 1) == "H" ~ "Highland Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "L" ~ "Lanarkshire Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "S" ~ "Lothian Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "R" ~ "Orkney Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "Z" ~ "Shetland Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "T" ~ "Tayside Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "W" ~ "Western Isles Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S08000007" ~ "Greater Glasgow & Clyde Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S08000008" ~ "Highland Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S27000001" ~ "Private Care"
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

# Converts year to financial year for the NRAC inputs
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

# Creation of variable hb when given an lcaname as argument
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

# Function for replacing commonly missing hospital location names
missing_locs <- function(df) {
  df <- df %>% mutate(locname = case_when(
    location == "A217H" ~ "Woodland View",
    location == "E006V" ~ "The Farndon Unit",
    location == "G503H" ~ "Drumchapel Hospital",
    location == "G517H" ~ "Beatson West of Scotland Cancer Centre",
    location == "G518V" ~ "Quayside Nursing Home",
    location == "G584V" ~ "Robin House Childrens Hospice Association Scotland",
    location == "G604V" ~ "NE Class East Social Work Day Unit",
    location == "G611H" ~ "Netherton",
    location == "G614H" ~ "Orchard View",
    location == "H220V" ~ "Highland Hospice",
    location == "H239V" ~ "Howard Doris Centre",
    location == "T317V" ~ "Rachel House Childrens Hospice",
    location == "T319H" ~ "Whitehills Health and Community Care Centre",
    location == "Y146H" ~ "Dumfries & Galloway Royal Infirmary",
    location == "Y177C" ~ "Mountainhall Treatment Centre",
    location == "A114H" ~ "Warrix Avenue Mental Health Community Rehabilitation Unit",
    location == "S320H" ~ "East Lothian Community Hospital",
    location == "R103H" ~ "The Balfour",
    TRUE ~ locname)
    )
}

# Function for determining whether a hospital is NHS, Private Care, Contractual, or Other
# based on the 5-character location code
hospital_type <- function(df) {
  df <- df %>% mutate(type = case_when(
    str_sub(location, 5, 5) == "H" ~ "NHS Hospital",
    str_sub(location, 5, 5) == "V" ~ "Private Care",
    str_sub(location, 5, 5) == "K" ~ "Contractual Hospital",
    TRUE ~ "Other"
  ))
}

# Function to handle when practices are closed or have merged
# Must be checked against a spreadsheet from the Primary Care team before each run
closed_practices <- function(df, pracvar) {
  df <- df %>% mutate(prac = case_when(
    {{ pracvar }} == (10751 | 10799) ~ 10746,
    {{ pracvar }} == 20165 ~ 20170,
    {{ pracvar }} == 21806 ~ 21811,
    {{ pracvar }} == 25116 ~ 25121,
    {{ pracvar }} == 25296 ~ 25883,
    {{ pracvar }} == (31112 | 31121) ~ 30769,
    {{ pracvar }} == (31422 | 31441) ~ 31461,
    {{ pracvar }} == (38101 | 38121 | 38140 | 38224) ~ 38239,
    {{ pracvar }} == (40116 | 40313) ~ 40737,
    {{ pracvar }} == (46377 | 46108) ~ 46625,
    {{ pracvar }} == (61057 | 61490 | 61227 | 61428) ~ 61630,
    {{ pracvar }} == (61409 | 60069) ~ 60228,
    {{ pracvar }} == (62830 | 62811) ~ 62830,
    {{ pracvar }} == (70037 | 70643) ~ 71449,
    {{ pracvar }} == (80895 | 80683) ~ 80895, 
    {{ pracvar }} == (86054 | 86162 | 86110) ~ 86360, 
    {{ pracvar }} == (87216 | 87221) ~ 87240,
    {{ pracvar }} == (90007 | 90026) ~ 90187, 
    {{ pracvar }} == (90064 | 90079 | 90083) ~ 90191,
    TRUE ~ {{ pracvar }}
  ))
}

# Converts ca2018 to ca2011 for use with Tableau security filters
security_codes <- function(df) {
  df <- df %>% mutate(lacode = case_when(
    lcaname == "Clackmannanshire & Stirling" ~ "S12000005",
    ca2018 == "S12000047" ~ "S12000015",
    ca2018 == "S12000048" ~ "S12000024",
    TRUE ~ ca2018)) %>% 
    select(-ca2018)
}
