##########################################################
# Name of file: "01_create-date.R"
# Original author: Gaby Carrillo Balam.
# Original date: June 2022
# Type of script: Data wrangling and analysis
#
# Written/run on - R Studio Server
# Version of R - 3.6.1 (2019-07-05) -- "Action of the Toes"
#
# Description of content: * The script consists of two main parts:
#                           - Part 1 - Reads in the individual source linkage file.
#                           - Part 2 - Groups and summarises costs for the cohorts.
#                           - Part 3 to 5 - Create the different cohorts.
#                           - Part 6 - Joins and saves the final year for the FY.
#
# Running time: ~ 20 minutes
##########################################################

#**************************************************************************************
#    * Part 1 - Create the patient aggregate data by reading the source files
#**************************************************************************************

main <- individual_slf() %>% 
# Create new variables based on others
  mutate(total_beddays = acute_inpatient_beddays + maternity_beddays + mh_inpatient_beddays + gls_inpatient_beddays,
         unplanned_beddays = acute_non_el_inpatient_beddays + mh_non_el_inpatient_beddays + gls_non_el_inpatient_beddays,
         hospital_elective_cost = acute_daycase_cost + acute_el_inpatient_cost + mh_el_inpatient_cost + gls_el_inpatient_cost,
         hospital_emergency_cost = acute_non_el_inpatient_cost + mh_non_el_inpatient_cost + gls_non_el_inpatient_cost,
         maternity_cost = mat_inpatient_cost + mat_daycase_cost,
         hospital_elective_beddays = acute_el_inpatient_beddays + mh_el_inpatient_beddays + gls_el_inpatient_beddays,
         hospital_emergency_beddays = acute_non_el_inpatient_beddays + mh_non_el_inpatient_beddays + gls_non_el_inpatient_beddays) %>% 
# Categorise patients.
  categorise_patients(main)

# Count how many LTCs a person has, note we are excluding congen, bloodbfo, endomet, digestive.
main <- main %>% 
  mutate(ltc_total = arth + asthma + atrialfib + cancer + cvd + liver + copd + dementia +  diabetes + epilepsy + chd + 
           hefailure + ms + parkinsons + refailure)

main <- main %>% 
  mutate(ltc_total = case_when(
    ltc_total >= 5 ~ 5,
    TRUE ~ ltc_total)
  )

main <- ltc_flags(main)

# Allocate people to a resource group based on their HRI score (within the LCA) - we exclude the DN costs.
main <- main %>% 
  mutate(resource_group = case_when(
    hri_lcap <= 50 ~ "High (Top 50%)",
    hri_lcap > 50 & hri_lcap <= 65 ~ "Moderately High (50-65%)",
    hri_lcap > 65 & hri_lcap <= 80 ~ "Moderate (65-80%)",
    hri_lcap > 80 & hri_lcap <= 95 ~ "Moderately Low (80-95%)",
    hri_lcap > 95 ~ "Low (95-100%)",
    TRUE ~ "N/A")
  )

# Divide into age-groups.
main <- main %>% 
  mutate(age_band = case_when(
    age <= 17 ~ "0 to 17",
    age >= 18 & age <= 64 ~ "18 to 64",
    age >= 65 & age <= 74 ~ "65 to 74",
    age >= 75 & age <= 84 ~ "75 to 84",
    age >= 85 ~ "85+",
    TRUE ~ "N/A")
  )

# Create variable 'total admissions'
main <- main %>% 
  mutate(total_admissions = hospital_elective_attendance + hospital_emergency_attendance + maternity_attendance)

# Match on CHI and then by demographic cohort
chi_lookup <- tidyfst::import_fst("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.fst")

main <- left_join(main, chi_lookup, by = "anon_chi") %>% 
  arrange(chi) %>% 
  clean_names()

demo_lookup <- haven::read_spss(glue("/conf/hscdiip/SLF_Extracts/Cohorts/",
                                     "Demographic_Cohorts_",
                                     "{fy}.zsav"))%>% 
  clean_names()

main <- left_join(main, demo_lookup, by = c("chi", "demographic_cohort")) %>% 
  arrange(anon_chi) %>% 
  mutate(demographic_cohort = case_when(
    nsu == 1 & demographic_cohort == "Healthy and Low User" ~ "Non-Service User",
    TRUE ~ as.character(demographic_cohort) 
  ))

rm(chi_lookup, demo_lookup)

#**************************************************************************************
#    Part 3 - GP Practice details
#**************************************************************************************

gp_lookup <- haven::read_spss("/conf/hscdiip/SLF_Extracts/Lookups/practice_details_Mar_2022.rds")%>%   #check code to create lookup
  clean_names()

main <- left_join(main, gp_lookup, by = c("gpprac")) %>% 
  arrange(gpprac) %>% 
  rename(clustername = cluster) 

main %<>% 
  mutate(practice_name = case_when(
    gpprac == 99942 ~ "Private practices",
    gpprac == 99957 ~ "Unregistered",
    gpprac == 99961 | gpprac == 99999 ~ "Unknown",   #check how is created in SPSS   
    gpprac == 99976 ~ "British Armed Forces not registered in UK",
    gpprac == 99981 ~ "Foreign Visitors not registered in Scotland",
    gpprac == 99995 ~ "Patients registered in RUK",
    is.na(practice_name) ~ "Closed Practice",
    TRUE ~ as.character(practice_name)))

main$gpprac <- paste(main$practice_name," (",main$gpprac,")",sep="")
main$gpprac <- glue("{main$practice_name} ({main$gpprac})")

main %<>% 
  mutate(partnership = case_when(
    is.na(partnership) ~ "Unknown",
    TRUE ~ as.character(partnership)
  ))

# Create and recode values
main <- main %>% 
  mutate(male = case_when(
    gender == 1 ~ 1,
    TRUE ~ (0)))

main <- main %>% 
  mutate(female = case_when(
    gender == 2 ~ 1,
    TRUE ~ (0)))

rm(gp_lookup)

#**************************************************************************************
#    Part 2 - Group and summarise costs
#**************************************************************************************

# Calculate costs by LTC
main <- ltc_calculations(main)

# Calculate costs by cohort
main <- cohort_calculations(main)   

main %<>%
  select(-acute_cost, -acute_daycase_cost, -acute_daycase_episodes, -acute_el_inpatient_beddays,
         -acute_el_inpatient_cost, -acute_el_inpatient_episodes, -acute_episodes, -acute_inpatient_beddays,
         -acute_inpatient_cost, -acute_inpatient_episodes, -acute_non_el_inpatient_beddays,
         -acute_non_el_inpatient_cost, -acute_non_el_inpatient_episodes, -age, -anon_chi, -at_alarms,
         -at_telecare, -ch_beddays, -ch_cis_episodes, -ch_cost, -chi, -cij_delay, -cmh_contacts,
         -dd_code9_beddays, -dd_code9_episodes, -dd_noncode9_beddays, -dd_noncode9_episodes,
         -dn_contacts, -dn_cost, -dn_episodes, -gls_cost, -gls_el_inpatient_beddays, -gls_el_inpatient_cost,
         -gls_el_inpatient_episodes, -gls_episodes, -gls_inpatient_beddays, -gls_inpatient_cost,
         -gls_inpatient_episodes, -gls_non_el_inpatient_beddays, -gls_non_el_inpatient_cost, 
         -gls_non_el_inpatient_episodes, -hc_episodes, -hc_non_personal_episodes, -hc_non_personal_hours,
         -hc_non_personal_hours_cost, -hc_personal_episodes, -hc_personal_hours, -hc_personal_hours_cost,
         -hc_reablement_episodes, -hc_reablement_hours, -hc_reablement_hours_cost, -hc_total_cost, 
         -hc_total_hours, -health_board, -hhg_end_fy, -hri_lcap, -keep_population, -lca, -locality,
         -mat_cost, -mat_daycase_cost, -mat_daycase_episodes, -mat_episodes, -mat_inpatient_cost,
         -mat_inpatient_episodes, -mh_el_inpatient_beddays, -mh_el_inpatient_cost, -mh_el_inpatient_episodes,
         -mh_episodes, -mh_inpatient_beddays, -mh_inpatient_cost, -mh_inpatient_episodes,
         -mh_non_el_inpatient_beddays, -mh_non_el_inpatient_cost, -mh_non_el_inpatient_episodes, -nsu,
         -ooh_advice, -ooh_cases, -ooh_consultation_time, -ooh_cost, -ooh_dn, -ooh_homev, -ooh_nhs24,
         -ooh_other, -ooh_pcc, -op_cost_dnas, -op_newcons_dnas, -pis_dispensed_items, -postcode,
         -practice_name, -preventable_admissions, -preventable_beddays, -sc_day_care, -sc_living_alone,
         -sc_meals, -sc_social_worker, -sc_support_from_unpaid_carer, -sc_type_of_housing, -sds_option_1,
         -sds_option_2, -sds_option_3, -sds_option_4)


# Aggregate data
main <- main %>% 
  group_by(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, 
           resource_group, age_band, urban_rural, ltc_total, gender) %>% 
  summarise(no_patients = n(), across(total_cost:end_of_life_outpatient_attendance, sum))%>% 
  ungroup()

# Create flag for data 
main$data <- "Main"

# Create and recode values
main <- main %>% 
  mutate(gender_name = case_when(
    gender == 1 ~ "Male",
    gender == 2 ~ "Female"
  ))

main <- main %>% 
  mutate(ltc_total = case_when(
    ltc_total == 5 ~ "5+",
    TRUE ~ as.character(ltc_total)
  ))

main <- main %>% 
  mutate(simd_quintile = case_when(
    simd_quintile == 1 ~ "1 - Most Deprived",
    simd_quintile == 5 ~ "5 - Least Deprived",
    TRUE ~ as.character(simd_quintile)
  ))

main <- main %>% 
  mutate(urban_rural = case_when(
    urban_rural == 1 ~ "1 - Large Urban Areas",
    urban_rural == 2 ~ "2 - Other Urban Areas",
    urban_rural == 3 ~ "3 - Accessible Small Towns",
    urban_rural == 4 ~ "4 - Remote Small Towns",
    urban_rural == 5 ~ "5 - Very Remote Small Towns",
    urban_rural == 6 ~ "6 - Accessible Rural",
    urban_rural == 7 ~ "7 - Remote Rural",
    urban_rural == 8 ~ "8 - Very Remote Rural",
    TRUE ~ "N/A"
  ))

#**************************************************************************************
#    Part 3 - Create data for "Services"
#**************************************************************************************

# A & E
ae2 <- main %>% 
  filter(ae2_cost > 0 | ae2_patients > 0 | ae2_attendances > 0)

ae2$data <- "Service"

ae2 <- ae2 %>% 
  select(-total_cost, -no_patients) %>% 
  rename(c(total_cost = ae2_cost, 
           no_patients = ae2_patients,
           total_attendances = ae2_attendances)) %>% 
  mutate(total_beddays = NA) %>% 
  mutate(service_area = "A&E") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, total_attendances, data, 
         service_area)

# ELECTIVE
elective <- main %>% 
  filter(hospital_elective_cost > 0 | hospital_elective_patients > 0 | hospital_elective_attendance > 0 | hospital_elective_beddays > 0)

elective$data <- "Service"

elective <- elective %>% 
  select(-total_cost, -no_patients, -total_beddays) %>% 
  rename(c(total_cost = hospital_elective_cost, 
           no_patients = hospital_elective_patients,
           total_attendances = hospital_elective_attendance,
           total_beddays = hospital_elective_beddays)) %>% 
  mutate(service_area = "Elective") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, total_attendances, data, 
         service_area)

# EMERGENCY
emergency <- main %>% 
  filter(hospital_emergency_cost > 0 | hospital_emergency_patients > 0 | hospital_emergency_attendance > 0 | hospital_emergency_beddays > 0)

emergency$data <- "Service"

emergency <- emergency %>% 
  select(-total_cost, -no_patients, -total_beddays) %>% 
  rename(c(total_cost = hospital_emergency_cost, 
           no_patients = hospital_emergency_patients,
           total_attendances = hospital_emergency_attendance,
           total_beddays = hospital_emergency_beddays)) %>% 
  mutate(service_area = "Emergency") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, total_attendances, data, 
         service_area)

# MATERNITY
maternity <- main %>% 
  filter(maternity_cost > 0 | maternity_patients > 0 | maternity_attendance > 0 | maternity_beddays > 0)

maternity$data <- "Service"

maternity <- maternity %>% 
  select(-total_cost, -no_patients, -total_beddays) %>% 
  rename(c(total_cost = maternity_cost, 
           no_patients = maternity_patients,
           total_attendances = maternity_attendance,
           total_beddays = maternity_beddays)) %>% 
  mutate(service_area = "Maternity") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, total_attendances, data, 
         service_area)

# PRESCRIBING
prescribing <- main %>% 
  filter(prescribing_cost > 0 | prescribing_patients > 0 )

prescribing$data <- "Service"

prescribing <- prescribing %>% 
  select(-total_cost, -no_patients) %>% 
  rename(c(total_cost = prescribing_cost, 
           no_patients = prescribing_patients)) %>% 
  mutate(total_beddays = NA) %>% 
  mutate(total_attendances = NA) %>% 
  mutate(service_area = "Prescribing") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, total_attendances, data, 
         service_area)

# OUTPATIENT
outpatient <- main %>% 
  filter(outpatient_cost > 0 | outpatients > 0 | outpatient_attendances > 0 )

outpatient$data <- "Service"

outpatient <- outpatient %>% 
  select(-total_cost, -no_patients, -total_beddays) %>% 
  rename(c(total_cost = outpatient_cost, 
           no_patients = outpatients,
           total_attendances = outpatient_attendances)) %>% 
  mutate(total_beddays = NA) %>% 
  mutate(service_area = "Outpatient") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, total_attendances, data, 
         service_area)

#### Join files

services <- rbind.data.frame(ae2, elective, emergency, maternity, prescribing, outpatient)

rm(ae2, elective, emergency, maternity, prescribing, outpatient)

#**************************************************************************************
#    Part 4 - Create data for "LTCs"
#**************************************************************************************

## Arthritis
arthritis <- main %>% 
  filter(arth > 0)

arthritis$data <- "LTC"

arthritis <- arthritis %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = arth_cost, 
           total_beddays = arth_beddays,
           unplanned_beddays = arth_unplanned_beddays,
           total_admissions = arth_admission,
           ae2_attendances = arth_ae2_attendance,
           outpatient_attendances = arth_outpatient_attendance,
           no_patients = arth)) %>% 
  mutate(ltc_name = "Arthritis") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Asthma
asthma <- main %>% 
  filter(asthma > 0)

asthma$data <- "LTC"

asthma <- asthma %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = asthma_cost, 
           total_beddays = asthma_beddays,
           unplanned_beddays = asthma_unplanned_beddays,
           total_admissions = asthma_admission,
           ae2_attendances = asthma_ae2_attendance,
           outpatient_attendances = asthma_outpatient_attendance,
           no_patients = asthma)) %>% 
  mutate(ltc_name = "Asthma") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Atrial Fibrillation
atrialfib <- main %>% 
  filter(atrialfib > 0)

atrialfib$data <- "LTC"

atrialfib <- atrialfib %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = atrialfib_cost, 
           total_beddays = atrialfib_beddays,
           unplanned_beddays = atrialfib_unplanned_beddays,
           total_admissions = atrialfib_admission,
           ae2_attendances = atrialfib_ae2_attendance,
           outpatient_attendances = atrialfib_outpatient_attendance,
           no_patients = atrialfib)) %>% 
  mutate(ltc_name = "Atrial Fibrillation") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Cancer
cancer <- main %>% 
  filter(cancer > 0)

cancer$data <- "LTC"

cancer <- cancer %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = cancer_cost, 
           total_beddays = cancer_beddays,
           unplanned_beddays = cancer_unplanned_beddays,
           total_admissions = cancer_admission,
           ae2_attendances = cancer_ae2_attendance,
           outpatient_attendances = cancer_outpatient_attendance,
           no_patients = cancer)) %>% 
  mutate(ltc_name = "Cancer") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## CVD
cvd <- main %>% 
  filter(cvd > 0)

cvd$data <- "LTC"

cvd <- cvd %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = cvd_cost, 
           total_beddays = cvd_beddays,
           unplanned_beddays = cvd_unplanned_beddays,
           total_admissions = cvd_admission,
           ae2_attendances = cvd_ae2_attendance,
           outpatient_attendances = cvd_outpatient_attendance,
           no_patients = cvd)) %>% 
  mutate(ltc_name = "CVD") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Liver
liver <- main %>% 
  filter(liver > 0)

liver$data <- "LTC"

liver <- liver %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = liver_cost, 
           total_beddays = liver_beddays,
           unplanned_beddays = liver_unplanned_beddays,
           total_admissions = liver_admission,
           ae2_attendances = liver_ae2_attendance,
           outpatient_attendances = liver_outpatient_attendance,
           no_patients = liver)) %>% 
  mutate(ltc_name = "Liver") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## COPD
copd <- main %>% 
  filter(copd > 0)

copd$data <- "LTC"

copd <- copd %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = copd_cost, 
           total_beddays = copd_beddays,
           unplanned_beddays = copd_unplanned_beddays,
           total_admissions = copd_admission,
           ae2_attendances = copd_ae2_attendance,
           outpatient_attendances = copd_outpatient_attendance,
           no_patients = copd)) %>% 
  mutate(ltc_name = "COPD") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Dementia
dementia <- main %>% 
  filter(dementia > 0)

dementia$data <- "LTC"

dementia <- dementia %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = dementia_cost, 
           total_beddays = dementia_beddays,
           unplanned_beddays = dementia_unplanned_beddays,
           total_admissions = dementia_admission,
           ae2_attendances = dementia_ae2_attendance,
           outpatient_attendances = dementia_outpatient_attendance,
           no_patients = dementia)) %>% 
  mutate(ltc_name = "Dementia") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Diabetes
diabetes <- main %>% 
  filter(diabetes > 0)

diabetes$data <- "LTC"

diabetes <- diabetes %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = diabetes_cost, 
           total_beddays = diabetes_beddays,
           unplanned_beddays = diabetes_unplanned_beddays,
           total_admissions = diabetes_admission,
           ae2_attendances = diabetes_ae2_attendance,
           outpatient_attendances = diabetes_outpatient_attendance,
           no_patients = diabetes)) %>% 
  mutate(ltc_name = "Diabetes") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Epilepsy
epilepsy <- main %>% 
  filter(epilepsy > 0)

epilepsy$data <- "LTC"

epilepsy <- epilepsy %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = epilepsy_cost, 
           total_beddays = epilepsy_beddays,
           unplanned_beddays = epilepsy_unplanned_beddays,
           total_admissions = epilepsy_admission,
           ae2_attendances = epilepsy_ae2_attendance,
           outpatient_attendances = epilepsy_outpatient_attendance,
           no_patients = epilepsy)) %>% 
  mutate(ltc_name = "Epilepsy") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## CHD
chd <- main %>% 
  filter(chd > 0)

chd$data <- "LTC"

chd <- chd %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = chd_cost, 
           total_beddays = chd_beddays,
           unplanned_beddays = chd_unplanned_beddays,
           total_admissions = chd_admission,
           ae2_attendances = chd_ae2_attendance,
           outpatient_attendances = chd_outpatient_attendance,
           no_patients = chd)) %>% 
  mutate(ltc_name = "CHD") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Heart Failure
hefailure <- main %>% 
  filter(hefailure > 0)

hefailure$data <- "LTC"

hefailure <- hefailure %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = hefailure_cost, 
           total_beddays = hefailure_beddays,
           unplanned_beddays = hefailure_unplanned_beddays,
           total_admissions = hefailure_admission,
           ae2_attendances = hefailure_ae2_attendance,
           outpatient_attendances = hefailure_outpatient_attendance,
           no_patients = hefailure)) %>% 
  mutate(ltc_name = "Heart Failure") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Multiple Sclerosis
ms <- main %>% 
  filter(ms > 0)

ms$data <- "LTC"

ms <- ms %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = ms_cost, 
           total_beddays = ms_beddays,
           unplanned_beddays = ms_unplanned_beddays,
           total_admissions = ms_admission,
           ae2_attendances = ms_ae2_attendance,
           outpatient_attendances = ms_outpatient_attendance,
           no_patients = ms)) %>% 
  mutate(ltc_name = "MS") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Parkinsons
parkinsons <- main %>% 
  filter(parkinsons > 0)

parkinsons$data <- "LTC"

parkinsons <- parkinsons %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = parkinsons_cost, 
           total_beddays = parkinsons_beddays,
           unplanned_beddays = parkinsons_unplanned_beddays,
           total_admissions = parkinsons_admission,
           ae2_attendances = parkinsons_ae2_attendance,
           outpatient_attendances = parkinsons_outpatient_attendance,
           no_patients = parkinsons)) %>% 
  mutate(ltc_name = "Parkinsons") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

## Renal Failure
refailure <- main %>% 
  filter(refailure > 0)

refailure$data <- "LTC"

refailure <- refailure %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = refailure_cost, 
           total_beddays = refailure_beddays,
           unplanned_beddays = refailure_unplanned_beddays,
           total_admissions = refailure_admission,
           ae2_attendances = refailure_ae2_attendance,
           outpatient_attendances = refailure_outpatient_attendance,
           no_patients = refailure)) %>% 
  mutate(ltc_name = "Renal Failure") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, ltc_name)

ltcs <- rbind.data.frame(arthritis, asthma, atrialfib, cancer, cvd, liver, copd, dementia, diabetes, hefailure, epilepsy, chd, ms, parkinsons, refailure)

rm(arthritis, asthma, atrialfib, cancer, cvd, liver, copd, dementia, diabetes, hefailure, epilepsy, chd, ms, parkinsons, refailure)

#**************************************************************************************
#    Part 5 - Create demographic cohorts
#**************************************************************************************

## Community Living
comm_living <- main %>% 
  filter(comm_living > 0)

comm_living$data <- "Demograph"

comm_living <- comm_living %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = comm_living_cost, 
           total_beddays = comm_living_beddays,
           unplanned_beddays = comm_living_unplanned_beddays,
           total_admissions = comm_living_admission,
           ae2_attendances = comm_living_ae2_attendance,
           outpatient_attendances = comm_living_outpatient_attendance,
           no_patients = comm_living)) %>% 
  mutate(demograph_name = "Community Assisted Living") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Adult Major
adult_major <- main %>% 
  filter(adult_major > 0)

adult_major$data <- "Demograph"

adult_major <- adult_major %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = adult_major_cost, 
           total_beddays = adult_major_beddays,
           unplanned_beddays = adult_major_unplanned_beddays,
           total_admissions = adult_major_admission,
           ae2_attendances = adult_major_ae2_attendance,
           outpatient_attendances = adult_major_outpatient_attendance,
           no_patients = adult_major)) %>% 
  mutate(demograph_name = "Adult Major Conditions") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Child Major
child_major <- main %>% 
  filter(child_major > 0)

child_major$data <- "Demograph"

child_major <- child_major %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = child_major_cost, 
           total_beddays = child_major_beddays,
           unplanned_beddays = child_major_unplanned_beddays,
           total_admissions = child_major_admission,
           ae2_attendances = child_major_ae2_attendance,
           outpatient_attendances = child_major_outpatient_attendance,
           no_patients = child_major)) %>% 
  mutate(demograph_name = "Child Major Conditions") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Low CC
low_cc <- main %>% 
  filter(low_cc > 0)

low_cc$data <- "Demograph"

low_cc <- low_cc %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = low_cc_cost, 
           total_beddays = low_cc_beddays,
           unplanned_beddays = low_cc_unplanned_beddays,
           total_admissions = low_cc_admission,
           ae2_attendances = low_cc_ae2_attendance,
           outpatient_attendances = low_cc_outpatient_attendance,
           no_patients = low_cc)) %>% 
  mutate(demograph_name = "Low Complex Conditions") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Medium CC
medium_cc <- main %>% 
  filter(medium_cc > 0)

medium_cc$data <- "Demograph"

medium_cc <- medium_cc %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = medium_cc_cost, 
           total_beddays = medium_cc_beddays,
           unplanned_beddays = medium_cc_unplanned_beddays,
           total_admissions = medium_cc_admission,
           ae2_attendances = medium_cc_ae2_attendance,
           outpatient_attendances = medium_cc_outpatient_attendance,
           no_patients = medium_cc)) %>% 
  mutate(demograph_name = "Medium Complex Conditions") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## High CC
high_cc <- main %>% 
  filter(high_cc > 0)

high_cc$data <- "Demograph"

high_cc <- high_cc %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = high_cc_cost, 
           total_beddays = high_cc_beddays,
           unplanned_beddays = high_cc_unplanned_beddays,
           total_admissions = high_cc_admission,
           ae2_attendances = high_cc_ae2_attendance,
           outpatient_attendances = high_cc_outpatient_attendance,
           no_patients = high_cc)) %>% 
  mutate(demograph_name = "High Complex Conditions") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Substance Misuse
substance <- main %>% 
  filter(substance > 0)

substance$data <- "Demograph"

substance <- substance %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = substance_cost, 
           total_beddays = substance_beddays,
           unplanned_beddays = substance_unplanned_beddays,
           total_admissions = substance_admission,
           ae2_attendances = substance_ae2_attendance,
           outpatient_attendances = substance_outpatient_attendance,
           no_patients = substance)) %>% 
  mutate(demograph_name = "Substance Misuse") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Mental Health
mh <- main %>% 
  filter(mh > 0)

mh$data <- "Demograph"

mh <- mh %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = mh_cost, 
           total_beddays = mh_beddays,
           unplanned_beddays = mh_unplanned_beddays,
           total_admissions = mh_admission,
           ae2_attendances = mh_ae2_attendance,
           outpatient_attendances = mh_outpatient_attendance,
           no_patients = mh)) %>% 
  mutate(demograph_name = "Mental Health") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Maternity
maternity <- main %>% 
  filter(maternity > 0)

maternity$data <- "Demograph"

maternity <- maternity %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = maternity_cost, 
           total_beddays = maternity_beddays,
           unplanned_beddays = maternity_cohort_unplanned_beddays,
           total_admissions = maternity_cohort_admission,
           ae2_attendances = maternity_cohort_ae2_attendance,
           outpatient_attendances = maternity_cohort_outpatient_attendance,
           no_patients = maternity)) %>% 
  mutate(demograph_name = "Maternity") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## Frailty
frailty <- main %>% 
  filter(frailty > 0)

frailty$data <- "Demograph"

frailty <- frailty %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = frailty_cost, 
           total_beddays = frailty_beddays,
           unplanned_beddays = frailty_unplanned_beddays,
           total_admissions = frailty_admission,
           ae2_attendances = frailty_ae2_attendance,
           outpatient_attendances = frailty_outpatient_attendance,
           no_patients = frailty)) %>% 
  mutate(demograph_name = "Frailty") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

## End of Life
end_of_life <- main %>% 
  filter(end_of_life > 0)

end_of_life$data <- "Demograph"

end_of_life <- end_of_life %>%
  select(-total_cost, -total_beddays, -unplanned_beddays, -total_admissions, -ae2_attendances, -outpatient_attendances, -no_patients) %>% 
  rename(c(total_cost = end_of_life_cost, 
           total_beddays = end_of_life_beddays,
           unplanned_beddays = end_of_life_unplanned_beddays,
           total_admissions = end_of_life_admission,
           ae2_attendances = end_of_life_ae2_attendance,
           outpatient_attendances = end_of_life_outpatient_attendance,
           no_patients = end_of_life)) %>% 
  mutate(demograph_name = "End of Life") %>% 
  select(partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, no_patients, total_cost, total_beddays, unplanned_beddays, 
         total_admissions, ae2_attendances, outpatient_attendances, data, demograph_name)

demographic <- rbind.data.frame(comm_living, adult_major, child_major, low_cc, medium_cc, high_cc, substance, mh, maternity, frailty, end_of_life)

rm(comm_living, adult_major, child_major, low_cc, medium_cc, high_cc, substance, mh, maternity, frailty, end_of_life)

#**************************************************************************************
#    Part 6 - Join cohorts and create the final for the financial year
#**************************************************************************************

part1 <- full_join(main, services, by = c("partnership", "clustername", "gpprac", "service_use_cohort", "demographic_cohort", "simd_quintile", "resource_group", 
                                          "age_band", "urban_rural", "ltc_total", "gender", "no_patients", "total_cost", "total_beddays", "data"))

part2 <- full_join(part1, ltcs, by = c("partnership", "clustername", "gpprac", "service_use_cohort", "demographic_cohort", "simd_quintile", "resource_group", 
                                       "age_band", "urban_rural", "ltc_total", "gender", "no_patients", "total_cost", "outpatient_attendances", "ae2_attendances", 
                                       "total_beddays", "unplanned_beddays", "total_admissions", "data"))

pci_tde <- full_join(part2, demographic,
                     by = c("partnership", "clustername", "gpprac", "service_use_cohort", "demographic_cohort", "simd_quintile", "resource_group", "age_band", 
                            "urban_rural", "ltc_total", "gender", "no_patients", "total_cost", "outpatient_attendances", "ae2_attendances", "total_beddays", 
                            "unplanned_beddays", "total_admissions", "data"))

pci_tde <- pci_tde %>% 
  mutate(year = {fy_long})

pci_tde %<>% 
  select(year, partnership, clustername, gpprac, service_use_cohort, demographic_cohort, simd_quintile, resource_group, 
         age_band, urban_rural, ltc_total, gender, data, service_area, )  ### Check against line 892-895


LTC_Name Demograph_Name
NoPatients Total_Cost Total_Beddays Total_Attendances Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances 
Comm_Living Adult_Major Child_Major Low_CC Medium_CC High_CC Substance MH Maternity Frailty End_of_Life ZeroLTC OneLTC TwoLTC ThreeLTC FourLTC FiveLTC
arth asthma atrialfib cancer copd cvd dementia diabetes epilepsy chd hefailure liver ms parkinsons refailure

rm(demographic, ltcs, services, main, part1, part2)

saveRDS(pci_tde, file = glue("/conf/sourcedev/TableauUpdates/Matrix/Source/",
                                "Output/", "source_tde_","{fy}",".rds"))

# Remove the file from the environment (if needed)
rm(pci_tde)

### End of Script ### 
