######################################################################
# Name of Script - 00_setup-environment.R
# Publication - Populations & Pathways Matrix
# Original Author - Gaby Carrillo based on the SPSS syntax
# Original Date - June 2022
# 
#              Note: Only the FY needs to be updated.
#
# Written/run on - R Studio Server
# Version of R - 3.6.1 (2019-07-05) -- "Action of the Toes"
#
# Description of content - Setup environment to run 01_create-data.R
#
# Running time: <1 minute
######################################################################

### 1 - Load packages ----
library(dplyr)         # For data manipulation in the "tidy" way
library(janitor)       # For 'cleaning' variable names
library(magrittr)      # For %<>% operator
library(glue)          # For working with strings
library(slfhelper)
library(purrr)
library(tidyfst)
library(haven)
library(dtplyr)
library(stringr)
library(tidylog)

#########################################################################

### 2 - Define financial year in short and long format 
# ***** THIS IS THE ONLY BIT THAT NEEDS TO BE UPDATED EVERY TIME THE SCRIPT IS RUN # ***** 
fy <- 2021
fy_long <- "2020/21"

#########################################################################

### 3 - Create functions 

#########################################################################
### To read the Source Linkage Files 

# Read in chi lookup
chi_lookup <- tidyfst::import_fst("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.fst")
demo_lookup <- haven::read_spss(glue("/conf/hscdiip/SLF_Extracts/Cohorts/",
                                     "Demographic_Cohorts_",
                                     "{fy}.zsav")) %>% clean_names()

# These are the columns you'd keep if you setdiff all the variables with the list you provided in 
# the original select() command
# It might be worth figuring out exactly which columns you need to be more specific
slf_columns <- c("anon_chi", "gender", "age", "gpprac", "health_net_cost", "nsu", 
         "preventable_admissions", "preventable_beddays", "acute_episodes", 
         "acute_daycase_episodes", "acute_inpatient_episodes", "acute_el_inpatient_episodes", 
         "acute_non_el_inpatient_episodes", "acute_cost", "acute_daycase_cost", 
         "acute_inpatient_cost", "acute_el_inpatient_cost", "acute_non_el_inpatient_cost", 
         "acute_inpatient_beddays", "acute_el_inpatient_beddays", "acute_non_el_inpatient_beddays", 
         "mat_episodes", "mat_daycase_episodes", "mat_inpatient_episodes", 
         "mat_cost", "mat_daycase_cost", "mat_inpatient_cost", "mat_inpatient_beddays", 
         "mh_episodes", "mh_inpatient_episodes", "mh_el_inpatient_episodes", 
         "mh_non_el_inpatient_episodes", "mh_cost", "mh_inpatient_cost", 
         "mh_el_inpatient_cost", "mh_non_el_inpatient_cost", "mh_inpatient_beddays", 
         "mh_el_inpatient_beddays", "mh_non_el_inpatient_beddays", "gls_episodes", 
         "gls_inpatient_episodes", "gls_el_inpatient_episodes", "gls_non_el_inpatient_episodes", 
         "gls_cost", "gls_inpatient_cost", "gls_el_inpatient_cost", "gls_non_el_inpatient_cost", 
         "gls_inpatient_beddays", "gls_el_inpatient_beddays", "gls_non_el_inpatient_beddays", 
         "dd_noncode9_episodes", "dd_noncode9_beddays", "dd_code9_episodes", 
         "dd_code9_beddays", "op_newcons_attendances", "op_newcons_dnas", 
         "op_cost_attend", "op_cost_dnas", "ae_attendances", "ae_cost", 
         "pis_dispensed_items", "pis_cost", "ooh_cases", "ooh_homev", 
         "ooh_advice", "ooh_dn", "ooh_nhs24", "ooh_other", "ooh_pcc", 
         "ooh_consultation_time", "ooh_cost", "dn_episodes", "dn_contacts", 
         "dn_cost", "cmh_contacts", "ch_cis_episodes", "ch_beddays", "ch_cost", 
         "hc_episodes", "hc_personal_episodes", "hc_non_personal_episodes", 
         "hc_reablement_episodes", "hc_total_hours", "hc_personal_hours", 
         "hc_non_personal_hours", "hc_reablement_hours", "at_alarms", 
         "at_telecare", "sds_option_1", "sds_option_2", "sds_option_3", 
         "sds_option_4", "sc_living_alone", "sc_support_from_unpaid_carer", 
         "sc_social_worker", "sc_type_of_housing", "sc_meals", "sc_day_care", 
         "cij_el", "cij_non_el", "cij_mat", "cij_delay", "arth", "asthma", 
         "atrialfib", "cancer", "cvd", "liver", "copd", "dementia", "diabetes", 
         "epilepsy", "chd", "hefailure", "ms", "parkinsons", "refailure", 
         "lca", "locality", "cluster", "simd2020v2_hscp2019_quintile", 
         "ur8_2016", "hri_lcap", "hhg_end_fy", "demographic_cohort", "service_use_cohort", 
         "keep_population")

# Re-written to use the slfhelper package, which has good error handling and such
individual_slf <- function(){
  read_slf_individual(fy, columns = slf_columns) %>% 
  filter(lca != "") %>% 
  filter(keep_population == 1) %>%
  rename(c(
      total_cost = health_net_cost,
      ae2_cost = ae_cost,
      ae2_attendances = ae_attendances,
      prescribing_cost = pis_cost,
      outpatient_attendances = op_newcons_attendances,
      outpatient_cost = op_cost_attend,
      maternity_beddays = mat_inpatient_beddays,
      ch_admissions = ch_cis_episodes,
      gp_cost = ooh_cost,
      urban_rural = ur8_2016,
      simd_quintile = simd2020v2_hscp2019_quintile,
      hospital_emergency_attendance = cij_non_el,
      hospital_elective_attendance = cij_el,
      maternity_attendance = cij_mat))
}


### Create Partnership label based on lca number
partnership_label <- function(df) {
  df <- df %>% 
    mutate(partnership = case_when(
      lca == "01" ~ "Aberdeen City",
      lca == "02" ~ "Aberdeenshire",
      lca == "03" ~ "Angus",
      lca == "04" ~ "Argyll & Bute",
      lca == "05" ~ "Scottish Borders",
      lca == "06" ~ "Clackmannanshire",
      lca == "07" ~ "West Dunbartonshire",
      lca == "08" ~ "Dumfries & Galloway",
      lca == "09" ~ "Dundee City",
      lca == "10" ~ "East Ayrshire",
      lca == "11" ~ "East Dunbartonshire",
      lca == "12" ~ "East Lothian",
      lca == "13" ~ "East Renfrewshire",
      lca == "14" ~ "City of Edinburgh",
      lca == "15" ~ "Falkirk",
      lca == "16" ~ "Fife",
      lca == "17" ~ "Glasgow City",
      lca == "18" ~ "Highland", 
      lca == "19" ~ "Inverclyde",
      lca == "20" ~ "Midlothian",
      lca == "21" ~ "Moray",
      lca == "22" ~ "North Ayrshire",
      lca == "23" ~ "North Lanarkshire",
      lca == "24" ~ "Orkney Islands",
      lca == "25" ~ "Perth & Kinross",
      lca == "26" ~ "Renfrewshire",
      lca == "27" ~ "Shetland Islands",
      lca == "28" ~ "South Ayrshire",
      lca == "29" ~ "South Lanarkshire",
      lca == "30" ~ "Stirling",
      lca == "31" ~ "West Lothian",
      lca == "32" ~ "Na h-Eileanan Siar")
    )
}

### Categorise patients.

categorise_patients <- function(df) {
  df <- df %>%
    mutate(
      # Hospital (elective)
      hospital_elective_patients = reduce(
        select(., c("acute_daycase_episodes", "acute_el_inpatient_episodes", "mh_el_inpatient_episodes", "gls_el_inpatient_episodes")), `|`),
      # Hospital (emergency)
      hospital_emergency_patients = reduce(
        select(., c("acute_non_el_inpatient_episodes", "mh_non_el_inpatient_episodes", "gls_non_el_inpatient_episodes")), `|`),
      # Maternity
      maternity_patients = reduce(select(., c("mat_episodes")), `|`),
      # A&E
      ae2_patients = reduce(select(., c("ae2_attendances")), `|`),
      # Outpatient
      outpatients = reduce(select(., c("outpatient_attendances")), `|`),
      # PIS
      prescribing_patients = reduce(select(., c("pis_dispensed_items")), `|`),
      # Delayed
      delayed_patients = reduce(select(., c("dd_noncode9_episodes", "dd_code9_episodes")), `|`),
      # District nursing
      dn_patients = reduce(select(., c("dn_contacts")), `|`),
      # Care Home
      ch_patients = reduce(select(., c("ch_admissions")), `|`),
      # GP
      gp_patients = reduce(select(., c("gp_contacts")), `|`)
    )
}


### Create LTC flags
ltc_flags <- function(df){
  df <- df %>% 
    mutate(zero_ltc = case_when(
      ltc_total == 0 ~ 1,
      TRUE ~ as.numeric(0)
    ))
  df <- df %>% 
    mutate(one_ltc = case_when(
      ltc_total == 1 ~ 1,
      TRUE ~ as.numeric(0)
    ))
  df <- df %>% 
    mutate(two_ltc = case_when(
      ltc_total == 2 ~ 1,
      TRUE ~ as.numeric(0)
    ))
  df <- df %>% 
    mutate(three_ltc = case_when(
      ltc_total == 3 ~ 1,
      TRUE ~ as.numeric(0)
    ))
  df <- df %>% 
    mutate(four_ltc = case_when(
      ltc_total == 4 ~ 1,
      TRUE ~ as.numeric(0)
    ))
  df <- df %>% 
    mutate(five_ltc = case_when(
      ltc_total == 5 ~ 1,
      TRUE ~ as.numeric(0)
    ))
}


### Select variables for the patient aggregate file 
patient_aggregate <- function(df){
  df %>% 
    select(anon_chi, arth, asthma, atrialfib, cancer, cvd, liver, copd, dementia, diabetes, epilepsy, chd, 
           hefailure, ms, parkinsons, refailure, `end_of_life` = end_of_l_ife, frailty, high_cc, maternity, mh, substance, 
           medium_cc, low_cc, child_major, adult_major, comm_living, partnership, total_cost, ae2_cost, 
           ae2_attendances, prescribing_cost, outpatient_attendances, outpatient_cost, maternity_beddays, 
           ch_admissions, gp_cost, total_beddays, unplanned_beddays, hospital_elective_cost, 
           hospital_emergency_cost, maternity_cost, hospital_elective_beddays, hospital_emergency_beddays, 
           delayed_episodes, delayed_beddays, gp_contacts, hospital_elective_patients, 
           hospital_emergency_patients, maternity_patients, ae2_patients, outpatients, prescribing_patients, 
           delayed_patients, dn_patients, ch_patients, gp_patients, ltc_total, zero_ltc, one_ltc, two_ltc, 
           three_ltc, four_ltc, five_ltc, resource_group, hhg_risk_group, age_band, total_admissions, 
           locality,  service_use_cohort, demographic_cohort, simd_quintile, urban_rural, gender, 
           hospital_elective_attendance, hospital_emergency_attendance, maternity_attendance, ch_beddays, 
           ch_cost, dn_cost, dn_contacts, preventable_admissions, preventable_beddays) 
}


#**************************************************************************************
# Create the calculations based on LTC and Demographic Cohorts
#**************************************************************************************

reassign_measures <- function(df, var) {
  ltc_name <- colnames(df[{{ var }}])
  return <- df %>%
    filter(df[{{ var }}] == 1) %>%
    rename_with(
      ~ stringr::str_c(ltc_name, "_", .x),
      contains(c("total_cost", "total_admissions", "total_beddays", "unplanned_beddays", "ae2_attendances", "outpatient_attendances"))
    )
  return(return)
}

ltc_calculations <- function(df) {
  ltc_list <- list(
    full_data <- df,
    arth <- reassign_measures(df, "arth"),
    asthma <- reassign_measures(df, "asthma"),
    atrialfib <- reassign_measures(df, "atrialfib"),
    cancer <- reassign_measures(df, "cancer"),
    cvd <- reassign_measures(df, "cvd"),
    liver <- reassign_measures(df, "liver"),
    copd <- reassign_measures(df, "copd"),
    dementia <- reassign_measures(df, "dementia"),
    diabetes <- reassign_measures(df, "diabetes"),
    epilepsy <- reassign_measures(df, "epilepsy"),
    chd <- reassign_measures(df, "chd"),
    hefailure <- reassign_measures(df, "hefailure"),
    ms <- reassign_measures(df, "ms"),
    parkinsons <- reassign_measures(df, "parkinsons"),
    refailure <- reassign_measures(df, "refailure")
  )
  return <- reduce(ltc_list, left_join)
  return(return)
}

cohort_calculations <- function(df) {
  cohort_list <- list(
    full_data <- df,
    comm_living <- reassign_measures(df, "comm_living"),
    adult_major <- reassign_measures(df, "adult_major"),
    child_major <- reassign_measures(df, "child_major"),
    low_cc <- reassign_measures(df, "low_cc"),
    medium_cc <- reassign_measures(df, "medium_cc"),
    high_cc <- reassign_measures(df, "high_cc"),
    substance <- reassign_measures(df, "substance"),
    mh <- reassign_measures(df, "mh"),
    maternity <- reassign_measures(df, "maternity"),
    frailty <- reassign_measures(df, "frailty"),
    end_of_life <- reassign_measures(df, "end_of_life")
  )
  return <- reduce(cohort_list, left_join)
  return(return)
}

# Rename and shuffle variables based on service area ----

get_service_data <- function(df, service, service_area) {
  renamed <- df %>%
    filter(if_any(starts_with(service), ~ .x > 0)) %>%
    select(-total_cost, -no_patients, -matches("^total_beddays$")) %>%
    rename_with(
      ~ str_replace(.x, service, "total"),
      matches(c(
        str_c("^", service, "_cost$"),
        str_c("^", service, "_beddays$")
      ))
    ) %>%
    rename_with(
      ~ str_replace(.x, service, "no"),
      matches(str_c("^", service, "_patients$"))
    ) %>%
    rename_with(
      ~ str_replace(.x, service, "no_patient"),
      matches(str_c("^", service, "s$"))
    )
  
  if (!(service %in% c("prescribing"))) {
    renamed <- renamed %>% rename_with(
      ~ str_c(
        str_replace_all(str_split(.x, "_")[[1]][[1]], ".{1,}", "total"),
        "_",
        str_replace_all(str_split(.x, "_")[[1]][[2]], ".{1,}", "attendances")
      ),
      matches(
        c(
          str_c("^", service, "_attendances$"),
          str_c("^", service, "_attendance$"),
          str_c("^", service, "_admissions$"),
          str_c("^", service, "_contacts$")
        )
      )
    )
  } else {renamed <- renamed}

  if (service %in% c("ae2", "outpatient", "gp")) {
    changed_to_na <- renamed %>% mutate(total_beddays = NA)
  } else if (service == "prescribing") {
    changed_to_na <- renamed %>% mutate(
      total_beddays = NA,
      total_attendances = NA
    )
  } else if (service == "dn") {
    changed_to_na <- renamed %>% mutate(
      total_beddays = NA,
      total_cost = NA
    )
  } else if (service == "ch") {
    changed_to_na <- renamed %>% mutate(total_cost = NA)
  } else {
    changed_to_na <- renamed
  }

  return <- changed_to_na %>%
    mutate(
      service_area = service_area,
      data = "Service"
    ) %>%
    select(
      partnership, locality, service_use_cohort, demographic_cohort, simd_quintile, resource_group,
      age_band, urban_rural, ltc_total, gender, hhg_risk_group, no_patients, total_cost, total_beddays,
      total_attendances, data, service_area
    )

  return(return)
}

# Rename and shuffle variables based on LTC or demograph data

get_ltc_demograph_data <- function(df, ltc_or_demo_name, data_type, proper_name) {
  return <- df %>%
    filter({{ ltc_or_demo_name }} > 0) %>%
    select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>%
    rename(
      total_cost = str_c({{ ltc_or_demo_name }}, "_total_cost"),
      total_beddays = str_c({{ ltc_or_demo_name }}, "_total_beddays"),
      unplanned_beddays = str_c({{ ltc_or_demo_name }}, "_unplanned_beddays"),
      total_admissions = str_c({{ ltc_or_demo_name }}, "_total_admissions"),
      ae2_attendances = str_c({{ ltc_or_demo_name }}, "_ae2_attendances"),
      outpatient_attendances = str_c({{ ltc_or_demo_name }}, "_outpatient_attendances"),
      no_patients = {{ ltc_or_demo_name }}
    ) %>%
    mutate(
      data = data_type
    ) %>%
    {
      if (data_type == "LTC") mutate(., ltc_name = proper_name) else mutate(., demograph_name = proper_name)
    } %>%
    select(
      partnership, locality, service_use_cohort, demographic_cohort, simd_quintile, resource_group,
      age_band, urban_rural, ltc_total, gender, hhg_risk_group, no_patients, total_cost, total_beddays,
      unplanned_beddays, total_admissions, ae2_attendances, outpatient_attendances, data, ends_with("_name")
    )
}

### End of Script ### 