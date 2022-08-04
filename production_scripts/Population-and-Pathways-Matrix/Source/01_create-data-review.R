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
  # You could potentially move this later, just to avoid having more columns
  partnership_label() %>% 
  # Create new variables based on others
  mutate(
    total_beddays = acute_inpatient_beddays + maternity_beddays + mh_inpatient_beddays + gls_inpatient_beddays,
    unplanned_beddays = acute_non_el_inpatient_beddays + mh_non_el_inpatient_beddays + gls_non_el_inpatient_beddays,
    hospital_elective_cost = acute_daycase_cost + acute_el_inpatient_cost + mh_el_inpatient_cost + gls_el_inpatient_cost,
    hospital_emergency_cost = acute_non_el_inpatient_cost + mh_non_el_inpatient_cost + gls_non_el_inpatient_cost,
    maternity_cost = mat_inpatient_cost + mat_daycase_cost,
    hospital_elective_beddays = acute_el_inpatient_beddays + mh_el_inpatient_beddays + gls_el_inpatient_beddays,
    hospital_emergency_beddays = acute_non_el_inpatient_beddays + mh_non_el_inpatient_beddays + gls_non_el_inpatient_beddays,
    delayed_episodes = dd_noncode9_episodes + dd_code9_episodes,
    delayed_beddays = dd_noncode9_beddays + dd_code9_beddays,
    gp_contacts = ooh_homev + ooh_advice + ooh_dn + ooh_nhs24 + ooh_other + ooh_pcc
  ) %>%
  # Because of how delays are matched there are sometimes errors in bedday counts.
  mutate(total_beddays = case_when(
    delayed_beddays > total_beddays ~ delayed_beddays,
    TRUE ~ as.numeric(total_beddays)
  )) %>%
  # Categorise patients.
  categorise_patients() %>%
  # Count how many LTCs a person has, note we are excluding congen, bloodbfo, endomet, digestive.
  mutate(
    ltc_total = (arth + asthma + atrialfib + cancer + cvd + liver + copd + dementia + diabetes + epilepsy + chd + hefailure + ms + parkinsons + refailure),
    ltc_total = if_else(ltc_total > 5, 5, ltc_total)
  ) %>%
  ltc_flags() %>%
  # Allocate people to a resource group based on their HRI score (within the LCA) - we exclude the DN costs.
  mutate(
    resource_group = case_when(
      hri_lcap <= 50 ~ "High (Top 50%)",
      hri_lcap > 50 & hri_lcap <= 65 ~ "Moderately High (50-65%)",
      hri_lcap > 65 & hri_lcap <= 80 ~ "Moderate (65-80%)",
      hri_lcap > 80 & hri_lcap <= 95 ~ "Moderately Low (80-95%)",
      hri_lcap > 95 ~ "Low (95-100%)",
      TRUE ~ "N/A"
    ),
    # Allocate people to a risk group based on their HHG score for the subsequent year.
    hhg_risk_group = case_when(
      hhg_end_fy <= 39 ~ "0 to 39",
      hhg_end_fy >= 40 & hhg_end_fy < 60 ~ "40 to 59",
      hhg_end_fy >= 60 & hhg_end_fy < 80 ~ "60 to 79",
      hhg_end_fy >= 80 ~ "80+",
      TRUE ~ "N/A"
    ),
    # Divide into age-groups.
    age_band = case_when(
      age <= 17 ~ "0 to 17",
      age >= 18 & age <= 64 ~ "18 to 64",
      age >= 65 & age <= 74 ~ "65 to 74",
      age >= 75 & age <= 84 ~ "75 to 84",
      age >= 85 ~ "85+",
      TRUE ~ "N/A"
    ),
    # Create variable 'total admissions'
    total_admissions = hospital_elective_attendance + hospital_emergency_attendance + maternity_attendance
  ) %>%
  # Match on chi from chi_lookup
  left_join(., chi_lookup, by = "anon_chi") %>%
  arrange(chi) %>%
  # Match on demographic lookup
  left_join(., demo_lookup, by = c("chi", "demographic_cohort")) %>%
  arrange(anon_chi) %>%
  mutate(
    demographic_cohort = case_when(
      demographic_cohort == "Assisted Living in the Community" ~ "Healthy and Low User",
      TRUE ~ as.character(demographic_cohort)
    ),
    demographic_cohort = case_when(
      nsu == 1 & demographic_cohort == "Healthy and Low User" ~ "Non-Service User",
      TRUE ~ as.character(demographic_cohort)
    )
  ) %>% 
  patient_aggregate()

#**************************************************************************************
#    Part 2 - Group and summarise costs
#**************************************************************************************

# Calculate measures by LTC
ltc_calc <- ltc_calculations(main)

# Calculate measures by cohort
cohort_calc <- cohort_calculations(main)

# Join LTC and Cohort data together
main <- left_join(ltc_calc, cohort_calc)

# Aggregate data
main <- main %>%
  # Relocate some variables for easier selection below
  relocate(
    partnership, locality, service_use_cohort, demographic_cohort, simd_quintile, resource_group, age_band,
    urban_rural, ltc_total, gender, hhg_risk_group
  ) %>%
  lazy_dt() %>%
  group_by(
    partnership, locality, service_use_cohort, demographic_cohort, simd_quintile, resource_group, age_band,
    urban_rural, ltc_total, gender, hhg_risk_group
  ) %>%
  summarise(
    no_patients = n(),
    across(arth:end_of_life_total_admissions, sum, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  as_tibble() %>%
  mutate(
    data = "Main",
    gender_name = if_else(gender == 1, "Male", "Female"),
    ltc_total = if_else(ltc_total == 5, "5+", as.character(ltc_total)),
    simd_quintile = case_when(
      simd_quintile == 1 ~ "1 - Most Deprived",
      simd_quintile == 5 ~ "5 - Least Deprived",
      TRUE ~ as.character(simd_quintile)
    ),
    urban_rural = case_when(
      urban_rural == 1 ~ "1 - Large Urban Areas",
      urban_rural == 2 ~ "2 - Other Urban Areas",
      urban_rural == 3 ~ "3 - Accessible Small Towns",
      urban_rural == 4 ~ "4 - Remote Small Towns",
      urban_rural == 5 ~ "5 - Very Remote Small Towns",
      urban_rural == 6 ~ "6 - Accessible Rural",
      urban_rural == 7 ~ "7 - Remote Rural",
      urban_rural == 8 ~ "8 - Very Remote Rural",
      TRUE ~ "N/A"
    )
  )

rm(ltc_calc, cohort_calc)

#**************************************************************************************
#    Part 3 - Create data for "Services"
#**************************************************************************************

services <- bind_rows(
  get_service_data(main, "ae2", "A&E"),
  get_service_data(main, "hospital_elective", "Elective"),
  get_service_data(main, "hospital_emergency", "Emergency"),
  get_service_data(main, "maternity", "Maternity"),
  get_service_data(main, "prescribing", "Prescribing"),
  get_service_data(main, "outpatient", "Outpatient"),
  get_service_data(main, "ch", "Care Home"),
  get_service_data(main, "dn", "District Nursing"),
  get_service_data(main, "gp", "GP Out of Hours")
)

#**************************************************************************************
#    Part 4 - Create data for "LTCs"
#**************************************************************************************

ltcs <- bind_rows(
  get_ltc_demograph_data(main, "arth", "LTC", "Arthritis"),
  get_ltc_demograph_data(main, "asthma", "LTC", "Asthma"),
  get_ltc_demograph_data(main, "atrialfib", "LTC", "Atrial Fibrillation"),
  get_ltc_demograph_data(main, "cancer", "LTC", "Cancer"),
  get_ltc_demograph_data(main, "cvd", "LTC", "CVD"),
  get_ltc_demograph_data(main, "liver", "LTC", "Liver"),
  get_ltc_demograph_data(main, "copd", "LTC", "COPD"),
  get_ltc_demograph_data(main, "dementia", "LTC", "Dementia"),
  get_ltc_demograph_data(main, "diabetes", "LTC", "Diabetes"),
  get_ltc_demograph_data(main, "epilepsy", "LTC", "Epilepsy"),
  get_ltc_demograph_data(main, "chd", "LTC", "CHD"),
  get_ltc_demograph_data(main, "hefailure", "LTC", "Heart Failure"),
  get_ltc_demograph_data(main, "ms", "LTC", "MS"),
  get_ltc_demograph_data(main, "parkinsons", "LTC", "Parkinsons"),
  get_ltc_demograph_data(main, "refailure", "LTC", "Renal Failure")
)

#**************************************************************************************
#    Part 5 - Create demographic cohorts
#**************************************************************************************

demographic <- bind_rows(
  get_ltc_demograph_data(main, "comm_living", "Demograph", "Community Assisted Living"),
  get_ltc_demograph_data(main, "adult_major", "Demograph", "Adult Major Conditions"),
  get_ltc_demograph_data(main, "child_major", "Demograph", "Child Major Conditions"),
  get_ltc_demograph_data(main, "low_cc", "Demograph", "Low Complex Conditions"),
  get_ltc_demograph_data(main, "medium_cc", "Demograph", "Medium Complex Conditions"),
  get_ltc_demograph_data(main, "high_cc", "Demograph", "High Complex Conditions"),
  get_ltc_demograph_data(main, "substance", "Demograph", "Substance Misuse"),
  get_ltc_demograph_data(main, "mh", "Demograph", "Mental Health"),
  get_ltc_demograph_data(main, "maternity", "Demograph", "Maternity"),
  get_ltc_demograph_data(main, "frailty", "Demograph", "Frailty"),
  get_ltc_demograph_data(main, "end_of_life", "Demograph", "End of Life")
)

#**************************************************************************************
#    Part 6 - Join cohorts and create the final for the financial year
#**************************************************************************************

source_tde <-
  full_join(main, services,
    by = c(
      "partnership", "locality", "service_use_cohort", "demographic_cohort", "simd_quintile", "resource_group", "age_band",
      "urban_rural", "ltc_total", "gender", "hhg_risk_group", "no_patients", "total_cost", "total_beddays", "data"
    )
  ) %>%
  full_join(., ltcs, by = c(
    "partnership", "total_cost", "ae2_attendances", "outpatient_attendances", "total_beddays", "unplanned_beddays",
    "ltc_total", "resource_group", "hhg_risk_group", "age_band", "total_admissions", "locality", "service_use_cohort",
    "demographic_cohort", "simd_quintile", "urban_rural", "gender", "no_patients", "data"
  )) %>%
  full_join(., demographic,
    by = c(
      "partnership", "locality", "service_use_cohort", "demographic_cohort", "simd_quintile", "resource_group", "age_band",
      "urban_rural", "ltc_total", "gender", "hhg_risk_group", "no_patients", "total_cost", "total_beddays", "unplanned_beddays",
      "total_admissions", "ae2_attendances", "outpatient_attendances", "data"
    )
  ) %>%
  mutate(year = {
    fy_long
  }) %>%
  select(
    partnership, locality, service_use_cohort, demographic_cohort, simd_quintile, resource_group,
    age_band, urban_rural, ltc_total, gender, hhg_risk_group, no_patients, total_cost, total_beddays,
    unplanned_beddays, total_admissions, ae2_attendances, outpatient_attendances, preventable_admissions,
    preventable_beddays, comm_living, adult_major, child_major, low_cc, medium_cc, high_cc, substance, mh,
    maternity, frailty, end_of_life, zero_ltc, one_ltc, two_ltc, three_ltc, four_ltc, five_ltc, arth, asthma,
    atrialfib, cancer, copd, cvd, dementia, diabetes, epilepsy, chd, hefailure, liver, ms, parkinsons,
    refailure, data, total_attendances, service_area, ltc_name, demograph_name, year, delayed_episodes,
    delayed_beddays, delayed_patients
  )

rm(demographic, ltcs, services)

saveRDS(source_tde, file = glue(
  "/conf/sourcedev/TableauUpdates/Matrix/Source/",
  "Output/", "source_tde_review", "{fy}", ".rds"
))

# Remove the file from the environment (if needed)
# rm(source_tde)

### End of Script ###
