######################################################################
# Name of Script - 00_setup-environment.R
# Publication - PCI - Populations & Pathways Matrix
# Original Author - Gaby Carrillo based on the SPSS syntax
# Original Date - July 2022
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
library(slfhelper)     # For reading ths SLF 
library(phsopendata)
library(fs)

#########################################################################

### 2 - Define financial year in short and long format 
# ***** THIS IS THE ONLY BIT THAT NEEDS TO BE UPDATED EVERY TIME THE SCRIPT IS RUN # ***** 
fy <- 2021
fy_long <- "2020/21"
latest_update <- "Jun_2022"     #For GP lookup file
lookup_dir <- path("/conf/hscdiip/SLF_Extracts/Lookups")
#########################################################################

### 3 - Create functions 

#########################################################################
### To read the Source Linkage Files 
individual_slf <- function(){
  read_slf_individual(fy, columns = c("anon_chi", "gender", "age", "gpprac", "health_net_cost", "nsu", "preventable_admissions", "preventable_beddays", 
                                      "acute_episodes", "acute_daycase_episodes", "acute_inpatient_episodes", "acute_el_inpatient_episodes", 
                                      "acute_non_el_inpatient_episodes", "acute_cost", "acute_daycase_cost","acute_inpatient_cost", "acute_el_inpatient_cost", 
                                      "acute_non_el_inpatient_cost", "acute_inpatient_beddays", "acute_el_inpatient_beddays", "acute_non_el_inpatient_beddays",
                                      "mat_episodes", "mat_daycase_episodes", "mat_inpatient_episodes", "mat_cost", "mat_daycase_cost", "mat_inpatient_cost", 
                                      "mat_inpatient_beddays", "mh_episodes", "mh_inpatient_episodes", "mh_el_inpatient_episodes", "mh_non_el_inpatient_episodes", 
                                      "mh_cost","mh_inpatient_cost", "mh_el_inpatient_cost", "mh_non_el_inpatient_cost", "mh_inpatient_beddays", 
                                      "mh_el_inpatient_beddays", "mh_non_el_inpatient_beddays", "gls_episodes", "gls_inpatient_episodes", 
                                      "gls_el_inpatient_episodes", "gls_non_el_inpatient_episodes", "gls_cost", "gls_inpatient_cost","gls_el_inpatient_cost", 
                                      "gls_non_el_inpatient_cost", "gls_inpatient_beddays" , "gls_el_inpatient_beddays", "gls_non_el_inpatient_beddays", 
                                      "dd_noncode9_episodes", "dd_noncode9_beddays", "dd_code9_episodes", "dd_code9_beddays", "op_newcons_attendances", 
                                      "op_newcons_dnas", "op_cost_attend", "op_cost_dnas","ae_attendances", "ae_cost", "pis_dispensed_items", "pis_cost", "ooh_cases", 
                                      "ooh_homev", "ooh_advice", "ooh_dn", "ooh_nhs24", "ooh_other", "ooh_pcc", "ooh_consultation_time", "ooh_cost", 
                                      "dn_episodes","dn_contacts", "dn_cost", "cmh_contacts", "ch_cis_episodes", "ch_beddays", "ch_cost", "hc_episodes",
                                      "hc_personal_episodes", "hc_non_personal_episodes", "hc_reablement_episodes", "hc_total_hours", "hc_personal_hours", 
                                      "hc_non_personal_hours", "hc_reablement_hours", "hc_total_cost", "hc_personal_hours_cost","hc_non_personal_hours_cost", 
                                      "hc_reablement_hours_cost","at_alarms", "at_telecare", "sds_option_1", "sds_option_2", "sds_option_3", "sds_option_4", 
                                      "sc_living_alone", "sc_support_from_unpaid_carer", "sc_social_worker", "sc_type_of_housing", "sc_meals", "sc_day_care", "cij_el", 
                                      "cij_non_el", "cij_mat", "cij_delay", "arth", "asthma", "atrialfib", "cancer", "cvd", "liver", "copd", "dementia", "diabetes", 
                                      "epilepsy","chd", "hefailure", "ms", "parkinsons", "refailure", "lca", "locality", "simd2020v2_hscp2019_quintile", "ur8_2016", 
                                      "hri_lcap", "hhg_end_fy", "demographic_cohort","service_use_cohort", "keep_population")) %>% 
    filter(lca != "") %>% 
    filter(gpprac != is.na(gpprac)) %>% 
    #rename some variables
    rename(c(
      total_cost = health_net_cost,
      ae2_cost = ae_cost,
      ae2_attendances = ae_attendances,
      prescribing_cost = pis_cost,
      outpatient_attendances = op_newcons_attendances,
      outpatient_cost = op_cost_attend,
      maternity_beddays = mat_inpatient_beddays,
      urban_rural = ur8_2016,
      simd_quintile = simd2020v2_hscp2019_quintile,
      hospital_emergency_attendance = cij_non_el,
      hospital_elective_attendance = cij_el,
      maternity_attendance = cij_mat)) %>% 
    clean_names()
}

### Categorise patients.

categorise_patients <- function(df){
  #hospital_elective_patients
  df <- df %>%
    mutate(hospital_elective_patients = case_when(
      acute_daycase_episodes > 0 ~ 1,
      acute_el_inpatient_episodes > 0 ~ 1,
      mh_el_inpatient_episodes > 0 ~ 1,
      gls_el_inpatient_episodes > 0 ~ 1,
      TRUE ~ 0)
    )
  
  #hospital_emergency_patients
  df <- df %>%
    mutate(hospital_emergency_patients = case_when(
      acute_non_el_inpatient_episodes > 0 ~ 1,
      mh_non_el_inpatient_episodes > 0 ~ 1,
      gls_non_el_inpatient_episodes > 0 ~ 1,
      TRUE ~ 0)
    )
  
  #maternity_patients
  df <- df %>%
    mutate(maternity_patients = case_when(
      mat_episodes > 0 ~ 1,
      TRUE ~ 0)
    )
  
  #ae2_patients
  df <- df %>%
    mutate(ae2_patients = case_when(
      ae2_attendances > 0 ~ 1,
      TRUE ~ 0)
    )
  
  #outpatients
  df <- df %>%
    mutate(outpatients = case_when(
      outpatient_attendances > 0 ~ 1,
      TRUE ~ 0)
    )
  
  #prescribing_patients
  df <- df %>%
    mutate(prescribing_patients = case_when(
      pis_dispensed_items > 0 ~ 1,
      TRUE ~ 0)
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


#**************************************************************************************
# Create the calculations based on LTC
#**************************************************************************************

ltc_calculations <- function(df){
  #Arthritis
  df <- df %>% 
    mutate(arth_cost = case_when(
      arth == 1 ~ total_cost,
      TRUE ~ 0 )) %>% 
    mutate(arth_admission = case_when(
      arth == 1 ~ total_admissions,
      TRUE ~ 0 )) %>% 
    mutate(arth_beddays = case_when(
      arth == 1 ~ total_beddays,
      TRUE ~ 0 )) %>% 
    mutate(arth_unplanned_beddays = case_when(
      arth == 1 ~ unplanned_beddays,
      TRUE ~ 0 )) %>% 
    mutate(arth_ae2_attendance = case_when(
      arth == 1 ~ ae2_attendances,
      TRUE ~ 0 )) %>% 
    mutate(arth_outpatient_attendance = case_when(
      arth == 1 ~ outpatient_attendances,
      TRUE ~ 0 ))
  # Asthma
  df <- df %>% 
    mutate(asthma_cost = case_when(
      asthma == 1 ~ total_cost,
      TRUE ~ 0 )) %>% 
    mutate(asthma_admission = case_when(
      asthma == 1 ~ total_admissions,
      TRUE ~ 0 )) %>% 
    mutate(asthma_beddays = case_when(
      asthma == 1 ~ total_beddays,
      TRUE ~ 0 )) %>% 
    mutate(asthma_unplanned_beddays = case_when(
      asthma == 1 ~ unplanned_beddays,
      TRUE ~ 0 )) %>% 
    mutate(asthma_ae2_attendance = case_when(
      asthma == 1 ~ ae2_attendances,
      TRUE ~ 0 )) %>% 
    mutate(asthma_outpatient_attendance = case_when(
      asthma == 1 ~ outpatient_attendances,
      TRUE ~ 0 ))
  #Atrial Fibrillation
  df <- df %>% 
    mutate(atrialfib_cost = case_when(
      atrialfib == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(atrialfib_admission = case_when(
      atrialfib == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(atrialfib_beddays = case_when(
      atrialfib == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(atrialfib_unplanned_beddays = case_when(
      atrialfib == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(atrialfib_ae2_attendance = case_when(
      atrialfib == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(atrialfib_outpatient_attendance = case_when(
      atrialfib == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Cancer
  df <- df %>%  
    mutate(cancer_cost = case_when(
      cancer == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(cancer_admission = case_when(
      cancer == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(cancer_beddays = case_when(
      cancer == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(cancer_unplanned_beddays = case_when(
      cancer == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(cancer_ae2_attendance = case_when(
      cancer == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(cancer_outpatient_attendance = case_when(
      cancer == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # CVD
  df <- df %>%  
    mutate(cvd_cost = case_when(
      cvd == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(cvd_admission = case_when(
      cvd == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(cvd_beddays = case_when(
      cvd == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(cvd_unplanned_beddays = case_when(
      cvd == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(cvd_ae2_attendance = case_when(
      cvd == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(cvd_outpatient_attendance = case_when(
      cvd == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # liver
  df <- df %>%  
    mutate(liver_cost = case_when(
      liver == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(liver_admission = case_when(
      liver == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(liver_beddays = case_when(
      liver == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(liver_unplanned_beddays = case_when(
      liver == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(liver_ae2_attendance = case_when(
      liver == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(liver_outpatient_attendance = case_when(
      liver == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # COPD
  df <- df %>%  
    mutate(copd_cost = case_when(
      copd == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(copd_admission = case_when(
      copd == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(copd_beddays = case_when(
      copd == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(copd_unplanned_beddays = case_when(
      copd == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(copd_ae2_attendance = case_when(
      copd == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(copd_outpatient_attendance = case_when(
      copd == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Dementia
  df <- df %>%  
    mutate(dementia_cost = case_when(
      dementia == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(dementia_admission = case_when(
      dementia == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(dementia_beddays = case_when(
      dementia == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(dementia_unplanned_beddays = case_when(
      dementia == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(dementia_ae2_attendance = case_when(
      dementia == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(dementia_outpatient_attendance = case_when(
      dementia == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Diabetes
  df <- df %>%  
    mutate(diabetes_cost = case_when(
      diabetes == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(diabetes_admission = case_when(
      diabetes == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(diabetes_beddays = case_when(
      diabetes == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(diabetes_unplanned_beddays = case_when(
      diabetes == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(diabetes_ae2_attendance = case_when(
      diabetes == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(diabetes_outpatient_attendance = case_when(
      diabetes == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Epilepsy
  df <- df %>%  
    mutate(epilepsy_cost = case_when(
      epilepsy == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(epilepsy_admission = case_when(
      epilepsy == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(epilepsy_beddays = case_when(
      epilepsy == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(epilepsy_unplanned_beddays = case_when(
      epilepsy == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(epilepsy_ae2_attendance = case_when(
      epilepsy == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(epilepsy_outpatient_attendance = case_when(
      epilepsy == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Chronic Heart Disease
  df <- df %>%  
    mutate(chd_cost = case_when(
      chd == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(chd_admission = case_when(
      chd == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(chd_beddays = case_when(
      chd == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(chd_unplanned_beddays = case_when(
      chd == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(chd_ae2_attendance = case_when(
      chd == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(chd_outpatient_attendance = case_when(
      chd == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Heart Failure
  df <- df %>%  
    mutate(hefailure_cost = case_when(
      hefailure == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(hefailure_admission = case_when(
      hefailure == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(hefailure_beddays = case_when(
      hefailure == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(hefailure_unplanned_beddays = case_when(
      hefailure == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(hefailure_ae2_attendance = case_when(
      hefailure == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(hefailure_outpatient_attendance = case_when(
      hefailure == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Multiple Sclerosis
  df <- df %>%  
    mutate(ms_cost = case_when(
      ms == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(ms_admission = case_when(
      ms == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(ms_beddays = case_when(
      ms == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(ms_unplanned_beddays = case_when(
      ms == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(ms_ae2_attendance = case_when(
      ms == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(ms_outpatient_attendance = case_when(
      ms == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Parkinson
  df <- df %>%  
    mutate(parkinsons_cost = case_when(
      parkinsons == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(parkinsons_admission = case_when(
      parkinsons == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(parkinsons_beddays = case_when(
      parkinsons == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(parkinsons_unplanned_beddays = case_when(
      parkinsons == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(parkinsons_ae2_attendance = case_when(
      parkinsons == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(parkinsons_outpatient_attendance = case_when(
      parkinsons == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Renal Failure
  df <- df %>%  
    mutate(refailure_cost = case_when(
      refailure == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(refailure_admission = case_when(
      refailure == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(refailure_beddays = case_when(
      refailure == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(refailure_unplanned_beddays = case_when(
      refailure == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(refailure_ae2_attendance = case_when(
      refailure == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(refailure_outpatient_attendance = case_when(
      refailure == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
}

#**************************************************************************************
# Create GP lookup
#**************************************************************************************

# Retrieve the latest resource from the dataset
gp_clusters <- get_dataset("gp-practice-contact-details-and-list-sizes",
                           max_resources = 20
) %>%
  clean_names() %>%
  # Get the code lookups so we have the names
  # Using the latest version of phsopendata for col_select
  tidylog::left_join(get_resource("944765d7-d0d9-46a0-b377-abb3de51d08e",
                                  col_select = c("HSCP", "HSCPName", "HB", "HBName")
  ) %>%
    clean_names()) %>%
  # Filter and save
  select(
    gpprac = practice_code,
    practice_name = gp_practice_name,
    postcode,
    cluster = gp_cluster,
    partnership = hscp_name,
    health_board = hb_name
  ) %>%
  tidyr::drop_na(cluster) %>%
  mutate(practice_name = stringr::str_to_title(practice_name)) %>%
  distinct(gpprac, .keep_all = TRUE) %>%
  # Sort for SPSS matching
  arrange(gpprac)

#**************************************************************************************
# Create costs per cohort
#**************************************************************************************

cohort_calculations <- function(df){
  #Comm_Living
  df <- df %>% 
    mutate(comm_living_cost = case_when(
      comm_living == 1 ~ total_cost,
      TRUE ~ 0 )) %>% 
    mutate(comm_living_admission = case_when(
      comm_living == 1 ~ total_admissions,
      TRUE ~ 0 )) %>% 
    mutate(comm_living_beddays = case_when(
      comm_living == 1 ~ total_beddays,
      TRUE ~ 0 )) %>% 
    mutate(comm_living_unplanned_beddays = case_when(
      comm_living == 1 ~ unplanned_beddays,
      TRUE ~ 0 )) %>% 
    mutate(comm_living_ae2_attendance = case_when(
      comm_living == 1 ~ ae2_attendances,
      TRUE ~ 0 )) %>% 
    mutate(comm_living_outpatient_attendance = case_when(
      comm_living == 1 ~ outpatient_attendances,
      TRUE ~ 0 ))
  # Adult Major
  df <- df %>% 
    mutate(adult_major_cost = case_when(
      adult_major == 1 ~ total_cost,
      TRUE ~ 0 )) %>% 
    mutate(adult_major_admission = case_when(
      adult_major == 1 ~ total_admissions,
      TRUE ~ 0 )) %>% 
    mutate(adult_major_beddays = case_when(
      adult_major == 1 ~ total_beddays,
      TRUE ~ 0 )) %>% 
    mutate(adult_major_unplanned_beddays = case_when(
      adult_major == 1 ~ unplanned_beddays,
      TRUE ~ 0 )) %>% 
    mutate(adult_major_ae2_attendance = case_when(
      adult_major == 1 ~ ae2_attendances,
      TRUE ~ 0 )) %>% 
    mutate(adult_major_outpatient_attendance = case_when(
      adult_major == 1 ~ outpatient_attendances,
      TRUE ~ 0 ))
  # Child Major
  df <- df %>% 
    mutate(child_major_cost = case_when(
      child_major == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(child_major_admission = case_when(
      child_major == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(child_major_beddays = case_when(
      child_major == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(child_major_unplanned_beddays = case_when(
      child_major == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(child_major_ae2_attendance = case_when(
      child_major == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(child_major_outpatient_attendance = case_when(
      child_major == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Low CC
  df <- df %>%  
    mutate(low_cc_cost = case_when(
      low_cc == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(low_cc_admission = case_when(
      low_cc == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(low_cc_beddays = case_when(
      low_cc == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(low_cc_unplanned_beddays = case_when(
      low_cc == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(low_cc_ae2_attendance = case_when(
      low_cc == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(low_cc_outpatient_attendance = case_when(
      low_cc == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Medium CC
  df <- df %>%  
    mutate(medium_cc_cost = case_when(
      medium_cc == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(medium_cc_admission = case_when(
      medium_cc == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(medium_cc_beddays = case_when(
      medium_cc == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(medium_cc_unplanned_beddays = case_when(
      medium_cc == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(medium_cc_ae2_attendance = case_when(
      medium_cc == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(medium_cc_outpatient_attendance = case_when(
      medium_cc == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # High CC
  df <- df %>%  
    mutate(high_cc_cost = case_when(
      high_cc == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(high_cc_admission = case_when(
      high_cc == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(high_cc_beddays = case_when(
      high_cc == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(high_cc_unplanned_beddays = case_when(
      high_cc == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(high_cc_ae2_attendance = case_when(
      high_cc == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(high_cc_outpatient_attendance = case_when(
      high_cc == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Substance
  df <- df %>%  
    mutate(substance_cost = case_when(
      substance == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(substance_admission = case_when(
      substance == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(substance_beddays = case_when(
      substance == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(substance_unplanned_beddays = case_when(
      substance == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(substance_ae2_attendance = case_when(
      substance == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(substance_outpatient_attendance = case_when(
      substance == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Mental Health
  df <- df %>%  
    mutate(mh_cost = case_when(
      mh == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(mh_admission = case_when(
      mh == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(mh_beddays = case_when(
      mh == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(mh_unplanned_beddays = case_when(
      mh == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(mh_ae2_attendance = case_when(
      mh == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(mh_outpatient_attendance = case_when(
      mh == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Maternity
  df <- df %>%  
    mutate(maternity_cohort_cost = case_when(
      maternity == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(maternity_cohort_admission = case_when(
      maternity == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(maternity_cohort_beddays = case_when(
      maternity == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(maternity_cohort_unplanned_beddays = case_when(
      maternity == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(maternity_cohort_ae2_attendance = case_when(
      maternity == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(maternity_cohort_outpatient_attendance = case_when(
      maternity == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # Frailty
  df <- df %>%  
    mutate(frailty_cost = case_when(
      frailty == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(frailty_admission = case_when(
      frailty == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(frailty_beddays = case_when(
      frailty == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(frailty_unplanned_beddays = case_when(
      frailty == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(frailty_ae2_attendance = case_when(
      frailty == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(frailty_outpatient_attendance = case_when(
      frailty == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
  # End of Life
  df <- df %>% 
    rename(end_of_life = end_of_l_ife)
  
  df <- df %>%  
    mutate(end_of_life_cost = case_when(
      end_of_life == 1 ~ total_cost,
      TRUE ~ 0 ))  %>% 
    mutate(end_of_life_admission = case_when(
      end_of_life == 1 ~ total_admissions,
      TRUE ~ 0 ))  %>% 
    mutate(end_of_life_beddays = case_when(
      end_of_life == 1 ~ total_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(end_of_life_unplanned_beddays = case_when(
      end_of_life == 1 ~ unplanned_beddays,
      TRUE ~ 0 ))  %>% 
    mutate(end_of_life_ae2_attendance = case_when(
      end_of_life == 1 ~ ae2_attendances,
      TRUE ~ 0 ))  %>% 
    mutate(end_of_life_outpatient_attendance = case_when(
      end_of_life == 1 ~ outpatient_attendances,
      TRUE ~ 0 )) 
}

### End of Script ### 