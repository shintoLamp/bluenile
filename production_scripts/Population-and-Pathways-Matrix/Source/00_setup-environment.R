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

#########################################################################

### 2 - Define financial year in short and long format 
# ***** THIS IS THE ONLY BIT THAT NEEDS TO BE UPDATED EVERY TIME THE SCRIPT IS RUN # ***** 
fy <- 2021
fy_long <- "2020/21"

#########################################################################

### 3 - Create functions 

#########################################################################
### To read the Source Linkage Files 
individual_slf <- function(){
  
  tidyfst::import_fst(glue("/conf/hscdiip/01-Source-linkage-files/",
                       "source-individual-file-",
                       "20{fy}.fst")) %>%
    select(-year,-dob,-postcode,-health_net_costincdnas,-health_net_costincincomplete,-hl1_in_fy,
           -deceased,-death_date,-congen,-bloodbfo,-endomet,-digestive,-arth_date,-asthma_date,
           -atrialfib_date,-cancer_date,-cvd_date,-liver_date,-copd_date,-dementia_date,-diabetes_date,
           -epilepsy_date,-chd_date,-hefailure_date,-ms_date,-parkinsons_date,-refailure_date,
           -congen_date,-bloodbfo_date,-endomet_date,-digestive_date,-hbrescode,-hscp2018,-ca2018,
           -datazone2011,-hbpraccode,-simd2020v2_rank,-simd2020v2_sc_decile,-simd2020v2_sc_quintile,
           -simd2020v2_hb2019_decile,-simd2020v2_hb2019_quintile,-simd2020v2_hscp2019_decile,-ur6_2016,
           -ur3_2016,-ur2_2016,-hb2019,-hscp2019,-ca2019,-hri_lca,-hri_lca_incdn,-hri_hb,-hri_scot,
           -hri_lcap_incdn,-hri_hbp,-hri_scotp,-sparra_start_fy,-sparra_end_fy,-hhg_start_fy) %>%
    filter(lca != "") %>% 
    filter(keep_population == 1) %>% 
    #rename some variables
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
      maternity_attendance = cij_mat)) %>% 
    
    clean_names()
  
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

#delayed_patients
  df <- df %>%
  mutate(delayed_patients = case_when(
    dd_noncode9_episodes > 0 ~ 1,
    dd_code9_episodes > 0 ~ 1,
    TRUE ~ 0)
  )

#dn_patients
  df <- df %>%
  mutate(dn_patients = case_when(
    dn_contacts >= 1 ~ 1,
    TRUE ~ 0)
  )

#ch_patients
  df <- df %>%
  mutate(ch_patients = case_when(
    ch_admissions >= 1 ~ 1,
    TRUE ~ 0)
  )

#gp_patients
  df <- df %>%
  mutate(gp_patients = case_when(
    gp_contacts >= 1 ~ 1,
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


### Select variables for the patient aggregate file 
patient_aggregate <- function(){
  main %>% 
    select(anon_chi, arth, asthma, atrialfib, cancer, cvd, liver, copd, dementia, diabetes, epilepsy, chd, 
           hefailure, ms, parkinsons, refailure, end_of_l_ife, frailty, high_cc, maternity, mh, substance, 
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
           ch_cost, dn_cost, dn_contacts, preventable_admissions, preventable_beddays) %>% 
    rename(end_of_life = end_of_l_ife)
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