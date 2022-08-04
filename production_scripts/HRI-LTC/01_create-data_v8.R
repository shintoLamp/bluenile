######################################################################
# Name of Script - 01_create-data.R                                  #
# Publication - HRI Long Term Conditions Workbook                    #
# Original Author - Federico Centoni                                 #
# Original date - August 2021                                        #
#                                                                    #
# Written/Run on - R Studio Server                                   #
# Version of R - 3.6.1                                               #
#                                                                    #
# Description of content - Create data file to be connected          #
#                          to Tableau dashboard                      #
######################################################################


### - Extracting Data -

source("code/00_setup-environment.R") 
purrr::walk(dir(here::here("functions"), full.names = TRUE), source)

## Extract Source Individual Files for four financial years with required variables 

hri_master <- read_slf_individual(finyear, 
              columns = c("year", "gender", "age", "ca2018", "health_net_cost", 
                          "acute_episodes", "acute_daycase_episodes", 
                          "acute_inpatient_episodes", "acute_el_inpatient_episodes", 
                          "acute_non_el_inpatient_episodes", "acute_cost", 
                          "acute_daycase_cost", "acute_inpatient_cost", 
                          "acute_el_inpatient_cost", "acute_non_el_inpatient_cost", 
                          "acute_inpatient_beddays", "acute_el_inpatient_beddays",
                          "acute_non_el_inpatient_beddays", "mat_episodes", 
                          "mat_daycase_episodes", "mat_inpatient_episodes",
                          "mat_cost", "mat_daycase_cost", "mat_inpatient_cost", 
                          "mat_inpatient_beddays", "mh_episodes","mh_inpatient_episodes", 
                          "mh_el_inpatient_episodes", "mh_non_el_inpatient_episodes", 
                          "mh_cost", "mh_inpatient_cost", "mh_el_inpatient_cost", 
                          "mh_non_el_inpatient_cost", "mh_inpatient_beddays", 
                          "mh_el_inpatient_beddays", "mh_non_el_inpatient_beddays", 
                          "gls_episodes", "gls_inpatient_episodes","gls_el_inpatient_episodes", 
                          "gls_non_el_inpatient_episodes", "gls_cost", "gls_inpatient_cost",
                          "gls_el_inpatient_cost", "gls_non_el_inpatient_cost", 
                          "gls_inpatient_beddays", "gls_el_inpatient_beddays", 
                          "gls_non_el_inpatient_beddays", "op_newcons_attendances",
                          "op_newcons_dnas", "op_cost_attend", "op_cost_dnas", 
                          "ae_attendances", "ae_cost", "pis_dispensed_items", 
                          "pis_cost", "hbrescode", "lca", "nsu", 
                          "datazone2011", "hri_lcap", "hri_lca",
                          "cvd", "copd", "dementia", "diabetes",
                          "chd", "hefailure", "refailure", "epilepsy", 
                          "asthma", "atrialfib", "cancer", "arth", "parkinsons",  
                          "liver", "ms")) %>% 
                          #Exclude unwanted records
                          filter(gender !="0" & hri_lca !="9" & nsu !="1")
  

### Section for adding LTC categories

hri_master %<>%

  # Add count of LTCs  
  mutate(ltc_count = reduce(select(., cvd:ms), `+`)) %>%
  
  # Add 'Any LTC' and 'No LTC' column markers
  mutate(`any_ltc`= if_else(ltc_count != 0, 1, 0),
         `no_ltc` = if_else(ltc_count == 0, 1, 0)) %>%

  # Add LTC groups 
  mutate(neurodegenerative = if_else((dementia == 1 | ms == 1 | parkinsons == 1), 1, 0))%>%
  mutate(cardio = if_else((atrialfib == 1 | chd == 1 | cvd == 1 | hefailure == 1), 1, 0))%>%
  mutate(respiratory = if_else((asthma == 1 | copd == 1), 1, 0))%>%
  mutate(otherorgan = if_else((liver == 1 | refailure == 1), 1 ,0))  
 

### Section for some data wrangling 

hri_master %<>% 
  
  # Apply standard age groups
  mutate(age_groups = standard_age_groups(age)) %>%
  # Recode Gender into string format
  mutate(gender = if_else(gender == "1", "Male", if_else(gender == "2", "Female", "Unknown"))) %>%
  # Recode year into financial year format
  mutate(year = str_c("20", str_sub(year, start = 1, end = 2), "/", str_sub(year, start = 3, end = 4))) %>% 
  
  select(-age) %>%
  
  # Use phsmethods::match_area() to get LCA names
  mutate(lcaname = match_area(ca2018)) %>%
  # Fill unknown LCA names with "Non LCA"
  mutate(lcaname = if_else(is.na(lcaname), "Non LCA", lcaname)) %>%
  
  # Add HRI flags 
  mutate(lcaflag50 = if_else(hri_lcap <= 50, 1, 0),
         lcaflag65 = if_else(hri_lcap <= 65, 1, 0),
         lcaflag80 = if_else(hri_lcap <= 80, 1, 0),
         lcaflag95 = if_else(hri_lcap <= 95, 1, 0))


############################################################################
##                                                                        ##
##    Part 1 - Activity Group:                                            ##
##             Create totals for each Service type and Threshold level    ##
##                                                                        ##
############################################################################


#####################
### Acute: HRIs - 50% 
#####################

acute_costs_hri_50 <- hri_master %>%
  
  #Select only HRI 50% with at least 1 episode
  filter(lcaflag50 == 1) %>%
  filter(acute_episodes >= 1) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc)%>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(acute_cost),
            total_beddays = sum(acute_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_50",
         service_type = "Acute")


#####################
### Acute: HRIs - 65% 
#####################

acute_costs_hri_65 <- hri_master %>%
  
  #Select only HRI 65% with at least 1 episode
  filter(lcaflag65 == 1) %>%
  filter(acute_episodes >= 1) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(acute_cost),
            total_beddays = sum(acute_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_65",
         service_type = "Acute")

  

#####################
### Acute: HRIs - 80% 
#####################

acute_costs_hri_80 <- hri_master %>%
  
  #Select only HRI 80% with at least 1 episode
  filter(lcaflag80 == 1) %>%
  filter(acute_episodes >= 1) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>%  
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(acute_cost),
            total_beddays = sum(acute_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_80",
         service_type = "Acute")


#####################
### Acute: HRIs - 95% 
#####################

acute_costs_hri_95 <- hri_master %>%
  
  #Select only HRI 95% with at least 1 episode
  filter(lcaflag95 == 1) %>%
  filter(acute_episodes >= 1) %>%
  
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(acute_cost),
            total_beddays = sum(acute_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_95",
         service_type = "Acute")


#########################################
### Acute: HRIs - 100% (All Patients) ### 
#########################################

acute_costs_hri_all <- hri_master %>%
  
  #Select all Acute patients with at least 1 episode
  filter(acute_episodes >= 1) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(acute_cost),
            total_beddays = sum(acute_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_all",
         service_type = "Acute") 


########################################
# Acute: combine all Acute-costs files #
########################################

acute_costs_hri_lca_final <- bind_rows(acute_costs_hri_50, acute_costs_hri_65, acute_costs_hri_80, 
                                   acute_costs_hri_95, acute_costs_hri_all) 


  
  
#################################
### Mental Health: HRIs - 50% ###
#################################

mh_costs_hri_50 <- hri_master %>% 
  
  #Select only HRI 50% with at least 1 episode
  filter(lcaflag50 == 1) %>%
  filter(mh_episodes >= 1) %>%  
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(mh_cost),
            total_beddays = sum(mh_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_50",
         service_type = "Mental Health")


  
#################################
### Mental Health: HRIs - 65% ###
#################################

mh_costs_hri_65 <- hri_master %>%
  
  #Select only HRI 65% with at least 1 episode
  filter(lcaflag65 == 1) %>%
  filter(mh_episodes >= 1) %>%    
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(mh_cost),
            total_beddays = sum(mh_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_65",
         service_type = "Mental Health")

  

#################################
### Mental Health: HRIs - 80% ###
#################################

mh_costs_hri_80 <- hri_master %>%
  
  #Select only HRI 80% with at least 1 episode
  filter(lcaflag80 == 1) %>%
  filter(mh_episodes >= 1) %>%    
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>%  
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(mh_cost),
            total_beddays = sum(mh_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_80",
         service_type = "Mental Health")


##########################
### Mental: HRIs - 95% ###
##########################

mh_costs_hri_95 <- hri_master %>%
  
  #Select only HRI 95% with at least 1 episode
  filter(lcaflag95 == 1) %>%
  filter(mh_episodes >= 1) %>%  
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(mh_cost),
            total_beddays = sum(mh_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_95",
         service_type = "Mental Health")


#################################################
### Mental Health: HRIs - 100% (All Patients) ### 
#################################################

mh_costs_hri_all <- hri_master %>%
  
  #Select all Acute patients with at least 1 episode
  filter(mh_episodes >= 1) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(mh_cost),
            total_beddays = sum(mh_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_all",
         service_type = "Mental Health") 


#############################################
# Mental Health: combine all MH-costs files #
#############################################

mh_costs_hri_lca_final <- bind_rows(mh_costs_hri_50, mh_costs_hri_65, mh_costs_hri_80, 
                                    mh_costs_hri_95, mh_costs_hri_all) 



  
#######################
### GLS: HRIs - 50% ###
#######################

gls_costs_hri_50 <- hri_master %>% 
  
  #Select only HRI 50% with at least 1 episode
  filter(lcaflag50 == 1) %>%
  filter(gls_episodes >= 1) %>%  
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(gls_cost),
            total_beddays = sum(gls_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_50",
         service_type = "GLS")


  
#######################
### GLS: HRIs - 65% ###
#######################

gls_costs_hri_65 <- hri_master %>%
  
  #Select only HRI 65% with at least 1 episode
  filter(lcaflag65 == 1) %>%
  filter(gls_episodes >= 1) %>% 
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(gls_cost),
            total_beddays = sum(gls_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_65",
         service_type = "GLS")

  

#################################
### GLS: HRIs - 80% ###
#################################

gls_costs_hri_80 <- hri_master %>%
  
  #Select only HRI 80% with at least 1 episode
  filter(lcaflag80 == 1) %>%
  filter(gls_episodes >= 1) %>%   
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>%  
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(gls_cost),
            total_beddays = sum(gls_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_80",
         service_type = "GLS")


#######################
### GLS: HRIs - 95% ###
########################

gls_costs_hri_95 <- hri_master %>%
  
  #Select only HRI 95% with at least 1 episode
  filter(lcaflag95 == 1) %>%
  filter(gls_episodes >= 1) %>% 

  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(gls_cost),
            total_beddays = sum(gls_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_95",
         service_type = "GLS")


#######################################
### GLS: HRIs - 100% (All Patients) ### 
#######################################

gls_costs_hri_all <- hri_master %>% 
  
  #Select all GLS patients with at least 1 episode
  filter(gls_episodes >= 1) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(gls_cost),
            total_beddays = sum(gls_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_all",
         service_type = "GLS") 


###################################
# GLS: combine all MH-costs files #
###################################


gls_costs_hri_lca_final <- bind_rows(gls_costs_hri_50, gls_costs_hri_65, gls_costs_hri_80, 
                                     gls_costs_hri_95, gls_costs_hri_all) 



  
##################################
### Other Patients: HRIs - 50% ###
##################################

other_costs_hri_50 <- hri_master %>%
  
  #Select other HRI-50 
  filter(lcaflag50 == 1) %>% 
  filter(mat_episodes >= 1 | op_newcons_attendances >= 1 | ae_attendances >= 1 | pis_dispensed_items >= 1) %>% 
    
  #Add other patients costation by LCAname, Gender, Age Groups and all LTC/LTC groups
  mutate(other_cost = mat_cost + op_cost_attend + ae_cost + pis_cost) %>%
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(other_cost),
            total_beddays = sum(mat_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_50",
         service_type = "Other")


  
#########################
### Other: HRIs - 65% ###
#########################

other_costs_hri_65 <- hri_master %>%
  
  #Select other HRI-65 
  filter(lcaflag65 == 1) %>% 
  filter(mat_episodes >= 1 | op_newcons_attendances >= 1 | ae_attendances >= 1 | pis_dispensed_items >= 1) %>% 
    
  #Add other patients cost  
  mutate(other_cost = mat_cost + op_cost_attend + ae_cost + pis_cost) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(other_cost),
            total_beddays = sum(mat_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_65",
         service_type = "Other")

  

#########################
### Other: HRIs - 80% ###
#########################

other_costs_hri_80 <- hri_master %>%
  
  #Select other HRI-80 
  filter(lcaflag80 == 1) %>% 
  filter(mat_episodes >= 1 | op_newcons_attendances >= 1 | ae_attendances >= 1 | pis_dispensed_items >= 1) %>% 
    
  #Add other patients cost  
  mutate(other_cost = mat_cost + op_cost_attend + ae_cost + pis_cost) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>%  
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(other_cost),
            total_beddays = sum(mat_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_80",
         service_type = "Other")


#####################
### Other: HRIs - 95% 
#####################

other_costs_hri_95 <- hri_master %>%
    
  #Select other HRI-95 
  filter(lcaflag95 == 1) %>% 
  filter(mat_episodes >= 1 | op_newcons_attendances >= 1 | ae_attendances >= 1 | pis_dispensed_items >= 1) %>% 
    
  #Add other patients cost  
  mutate(other_cost = mat_cost + op_cost_attend + ae_cost + pis_cost) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(other_cost),
            total_beddays = sum(mat_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_95",
         service_type = "Other")


#########################################
### Other: HRIs - 100% (All Patients) ### 
#########################################

other_costs_hri_all <- hri_master %>%
  
  #Select All Other patients  
  filter(mat_episodes >= 1 | op_newcons_attendances >= 1 | ae_attendances >= 1 | pis_dispensed_items >=1 ) %>% 
    
  #Add other patients cost  
  mutate(other_cost = mat_cost + op_cost_attend + ae_cost + pis_cost) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(other_cost),
            total_beddays = sum(mat_inpatient_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_all",
         service_type = "Other") 


########################################
# Other: combine all Other-costs files #
########################################

other_costs_hri_lca_final <- bind_rows(other_costs_hri_50, other_costs_hri_65, other_costs_hri_80, 
                                       other_costs_hri_95, other_costs_hri_all) 

  
  
########################
# Calculate HRI Totals #
########################  

############
## HRI-50 ##
############
      
all_costs_hri_50 <- hri_master %>%
  
  #Select HRI 50% with at least 1 episode
  filter(lcaflag50 == 1) %>% 
    
  #add all service beddays 
  mutate(total_beddays = acute_inpatient_beddays + mh_inpatient_beddays + 
                         mat_inpatient_beddays + gls_inpatient_beddays) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(health_net_cost),
            total_beddays = sum(total_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_50",
         service_type = "ALL")  
  

############
## HRI-65 ##
############
      
all_costs_hri_65 <- hri_master %>%
  
  #Select HRI 65% with at least 1 episode
  filter(lcaflag65 == 1) %>% 
    
  #add all service beddays 
  mutate(total_beddays = acute_inpatient_beddays + mh_inpatient_beddays + 
                         mat_inpatient_beddays + gls_inpatient_beddays) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(health_net_cost),
            total_beddays = sum(total_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_65",
         service_type = "ALL") 
  

############
## HRI-80 ##
############
      
all_costs_hri_80 <- hri_master %>%
  
  #Select HRI 80% with at least 1 episode
  filter(lcaflag80 == 1) %>% 
    
  #add all service beddays 
  mutate(total_beddays = acute_inpatient_beddays + mh_inpatient_beddays + 
                         mat_inpatient_beddays + gls_inpatient_beddays) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(health_net_cost),
            total_beddays = sum(total_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_80",
         service_type = "ALL") 
  
  
############
## HRI-95 ##
############
      
all_costs_hri_95 <- hri_master %>%
  
  #Select HRI 95% with at least 1 episode
  filter(lcaflag95 == 1) %>% 
    
  #add all service beddays 
  mutate(total_beddays = acute_inpatient_beddays + mh_inpatient_beddays + 
                         mat_inpatient_beddays + gls_inpatient_beddays) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(health_net_cost),
            total_beddays = sum(total_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_95",
         service_type = "ALL") 
  
##################
## All PATIENTS ##
##################
      
all_costs_hri_all <- hri_master %>% 
    
  #add all service beddays 
  mutate(total_beddays = acute_inpatient_beddays + mh_inpatient_beddays + 
                         mat_inpatient_beddays + gls_inpatient_beddays) %>%
  
  #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
  group_by(year, lcaname, gender, age_groups, cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy,
           asthma, atrialfib, cancer, arth, parkinsons, liver, ms, no_ltc, respiratory,
           neurodegenerative, cardio, otherorgan, any_ltc) %>% 
  
  #Create totals by LTC and output aggregated costs, beddays and N. of individuals
  summarise(cvd_count = sum(cvd),
            copd_count = sum(copd),
            dementia_count = sum(dementia),
            diabetes_count = sum(diabetes),
            chd_count = sum(chd),
            hefailure_count = sum(hefailure),
            refailure_count = sum(refailure),
            epilepsy_count = sum(epilepsy),
            asthma_count = sum(asthma),
            atrialfib_count = sum(atrialfib),
            cancer_count = sum(cancer),
            arth_count = sum(arth),
            parkinsons_count = sum(parkinsons),
            liver_count = sum(liver),
            ms_count = sum(ms),
            no_ltc_count = sum(no_ltc),
            neurodegenerative_count = sum(neurodegenerative),
            cardio_count = sum(cardio),
            respiratory_count = sum(respiratory),
            otherorgan_count = sum(otherorgan),
            any_ltc_count = sum(any_ltc),
            fin_year = last(year),
            number_patients = n(),
            total_cost = sum(health_net_cost),
            total_beddays = sum(total_beddays)) %>%
  
  ungroup() %>%
  
  #Add User Type and Service Type flags
  mutate(user_type = "lca-hri_all",
         service_type = "ALL") 
  
  
  ##################################
  # Bring all Total files together #
  ##################################
  
  all_costs_hri_lca_final <- bind_rows(all_costs_hri_50, all_costs_hri_65, all_costs_hri_80,
                                       all_costs_hri_95, all_costs_hri_all)
  
  
  
  
  ###########################################
  ### Finalizing HRI_LTC Dataset - Part 1 ###
  ###########################################
  
  
  # Bring All files together and create required geographies
  hri_ltc_lca_costs <- bind_rows(acute_costs_hri_lca_final, mh_costs_hri_lca_final,
                                 gls_costs_hri_lca_final, other_costs_hri_lca_final,
                                 all_costs_hri_lca_final) %>%
    
    #Add LA codes 
    mutate(LA_CODE = lca_code(lcaname)) %>%
    #Add HB names
    mutate(HBname = hb_name(lcaname)) %>%
    #Add HB codes
    mutate(HB_CODE = hb_code(HBname)) 
  
  
  #Create Clackmannanshire & Stirling data by selecting the two LCAs seperately
   hri_cs <- hri_ltc_lca_costs %>%
    
   filter(lcaname %in% c("Clackmannanshire", "Stirling")) %>%
  
   mutate(lcaname = "Clackmannanshire & Stirling")
  
  #Combine C&S data with the rest of the dataset
   hri_ltc_lca_costs <- bind_rows(hri_ltc_lca_costs, hri_cs)                                                                                                                                                                             
  

  #Rename variables and save HRI_LTC - part 1 file 
   hri_ltc_lca_costs %<>%
    
    rename(Year=fin_year,
           LCAname=lcaname,
           Gender=gender,
           AgeBand=age_groups,
           UserType=user_type,
           ServiceType=service_type,
           NumberPatients=number_patients,
           cvdC=cvd_count,
           copdC=copd_count,
           dementiaC=dementia_count,
           chdC=chd_count,
           hefailureC=hefailure_count,
           refailureC=refailure_count,
           epilepsyC=epilepsy_count,
           asthmaC=asthma_count,
           atrialfibC=atrialfib_count,
           cancerC=cancer_count,
           diabetesC = diabetes_count,
           arthC=arth_count,
           parkinsonsC=parkinsons_count,
           liverC=liver_count,
           msC=ms_count,
           No_LTC = no_ltc,
           Any_LTC = any_ltc,
           Neurodegenerative = neurodegenerative_count,
           Respiratory = respiratory_count,
           Cardio = cardio_count,
           OtherOrgan = otherorgan_count,
           Any_LTCC = any_ltc_count,
           No_LTCC = no_ltc_count,
           Total_Cost = total_cost,
           Total_Beddays = total_beddays
           ) %>% 
    
    select(-year) %>%
    
    #Rename Western Isles 
    mutate(LCAname = if_else(
      LCAname %in% c("Na h-Eileanan Siar"),
      "Western Isles",
      LCAname
    )) %>%
    
    select(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, NumberPatients,
           Total_Cost, Total_Beddays, cvd, copd, dementia, diabetes, chd, hefailure, refailure,
           epilepsy, asthma, atrialfib, cancer, arth, parkinsons, liver, ms, No_LTC, Any_LTC,
           cvdC, copdC, dementiaC, diabetesC, chdC, hefailureC, refailureC, epilepsyC, asthmaC,
           atrialfibC, cancerC, arthC, parkinsonsC, liverC, msC, No_LTCC, Any_LTCC, Neurodegenerative,
           Cardio, Respiratory, OtherOrgan)
  
    write_sav(hri_ltc_lca_costs, 
          here("data", "basefiles", glue("hri_ltc_lca_costs.sav")), compress = TRUE)
  
  #Read in saved data 
  hri_ltc_lca_costs <- read_sav('/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/data/basefiles/hri_ltc_lca_costs.sav')
    
    

  ####################################################################################
  ##                                                                                ##
  ##  Part 2 - Additional Groups:                                                   ##  
  ##           Add analysis for each individual LTC and create 'Other User' Totals  ##
  ##                                                                                ##
  ####################################################################################
    
    
    #######
    # CVD #
    #######
    
    agg_cvd <- hri_ltc_lca_costs %>% 
      
      #Select only CVD data
      filter(cvd == 1) %>% 
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "cvd") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
  
    
    ########
    # COPD #
    ########
    
    agg_copd <- hri_ltc_lca_costs %>% 
      
      #Select only COPD data
      filter(copd == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = cvd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "copd") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    
    ############
    # Dementia #
    ############
    
    agg_dementia <- hri_ltc_lca_costs %>% 
      
      #Select only Dementia data
      filter(dementia == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + cvd + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "dementia") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ############
    # Diabetes #
    ############
    
    agg_diabetes <- hri_ltc_lca_costs %>% 
      
      #Select only Diabetes data
      filter(diabetes == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + cvd + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "diabetes") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    #######
    # CHD #
    #######
    
    agg_chd <- hri_ltc_lca_costs %>% 
      
      #Select only CHD data
      filter(chd == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + cvd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "chd") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    #################
    # Heart Failure #
    #################
    
    agg_hefailure <- hri_ltc_lca_costs %>% 
      
      #Select only Hearth Failure data
      filter(hefailure == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + cvd + refailure + epilepsy + 
               asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "hefailure") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    #################
    # Renal Failure #
    #################
    
    agg_refailure <- hri_ltc_lca_costs %>% 
      
      #Select only Renal Failure data
      filter(refailure == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + cvd + epilepsy + 
               asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "refailure") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ############
    # Epilepsy #
    ############
    
    agg_epilepsy <- hri_ltc_lca_costs %>% 
      
      #Select only Epilepsy data
      filter(epilepsy == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + cvd + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "epilepsy") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ##########
    # Asthma #
    ##########
    
    agg_asthma <- hri_ltc_lca_costs %>% 
      
      #Select only Asthma data
      filter(asthma == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              cvd + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "asthma") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    #######################
    # Atrial Fibrillation #
    #######################
    
    agg_atrialfib <- hri_ltc_lca_costs %>% 
      
      #Select only Atrial Fibrillation data
      filter(atrialfib == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + cvd + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "atrialfib") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ######################
    # Multiple Sclerosis #
    ######################
    
    agg_ms <- hri_ltc_lca_costs %>% 
      
      #Select only MS data
      filter(ms == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + cvd + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "ms") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ##########
    # Cancer #
    ##########
    
    agg_cancer <- hri_ltc_lca_costs %>% 
      
      #Select only Cancer data
      filter(cancer == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cvd + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "cancer") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    #############
    # Arthritis #
    #############
    
    agg_arth <- hri_ltc_lca_costs %>% 
      
      #Select only Arthritis data
      filter(arth == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + cvd + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "arth") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ##############
    # Parkinsons #
    ##############
    
    agg_parkinsons <- hri_ltc_lca_costs %>% 
      
      #Select only Parkinsons data
      filter(parkinsons == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + cvd + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "parkinsons") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    #################
    # Liver disease #
    #################
    
    agg_liver <- hri_ltc_lca_costs %>% 
      
      #Select only Liver disease data
      filter(liver == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + cvd) %>% 
      
      #Add LTC name
      mutate(LTC = "liver") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ##########
    # No LTC #
    ##########
    
    agg_no_ltc <- hri_ltc_lca_costs %>% 
      
      #Select only No LTC data
      filter(No_LTC == 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                              asthma + atrialfib + ms + cancer + arth + parkinsons + liver) %>% 
      
      #Add LTC name
      mutate(LTC = "No LTC") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
    
    ###########
    # Any LTC #
    ###########
    
    agg_any_ltc <- hri_ltc_lca_costs %>% 
      
      #Select only Any LTC data
      filter(No_LTC != 1) %>%
      
      #Add additional LTC flag  
      mutate(Additional_LTC = ((cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + 
                               asthma + atrialfib + ms + cancer + arth + parkinsons + liver) - 1)) %>% 
      
      #Add LTC name
      mutate(LTC = "Any LTC") %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #Create LTC counts and output aggregated costs, beddays
      summarise(cvd = sum(cvdC),
                copd = sum(copdC),
                dementia = sum(dementiaC),
                diabetes = sum(diabetesC),
                chd = sum(chdC),
                hefailure = sum(hefailureC),
                refailure = sum(refailureC),
                epilepsy = sum(epilepsyC),
                asthma = sum(asthmaC),
                atrialfib = sum(atrialfibC),
                cancer = sum(cancerC),
                arth = sum(arthC),
                parkinsons = sum(parkinsonsC),
                liver = sum(liverC),
                ms = sum(msC),
                No_LTC = sum(No_LTCC),
                Any_LTC = sum(Any_LTCC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
    
    ungroup()
    
     
    #Save file
    write_sav(agg_any_ltc, 
              here("checks", glue("hri_any_ltc_R.sav")), compress = TRUE)
  
    
    ##############################
    # Add all LTC files together #
    ##############################
    
    hri_ltc_totals <- bind_rows(agg_cvd, agg_copd, agg_dementia, agg_diabetes, agg_chd, agg_hefailure, 
                                agg_refailure, agg_epilepsy, agg_asthma, agg_atrialfib, agg_ms, 
                                agg_cancer, agg_arth, agg_parkinsons, agg_liver, agg_no_ltc, agg_any_ltc)
    
    
    
    
    hri_ltc_totals %<>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      
      #recreate LTC counts and output aggregated costs, beddays due to Additional_LTC reclassification
      summarise(cvd = sum(cvd),
                copd = sum(copd),
                dementia = sum(dementia),
                diabetes = sum(diabetes),
                chd = sum(chd),
                hefailure = sum(hefailure),
                refailure = sum(refailure),
                epilepsy = sum(epilepsy),
                asthma = sum(asthma),
                atrialfib = sum(atrialfib),
                cancer = sum(cancer),
                arth = sum(arth),
                parkinsons = sum(parkinsons),
                liver = sum(liver),
                ms = sum(ms),
                No_LTC = sum(No_LTC),
                Any_LTC = sum(Any_LTC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
      
      ungroup() %>% 
      
      
      #Recategorize additional LTC groups (0,1,..,5+)
      mutate(additional_ltc = add_ltc_groups(Additional_LTC)) %>%
      
      #Remove old Additional_LTC variable
      select(-Additional_LTC) %>%
      
      rename(Additional_LTC = additional_ltc) 
  
    
    #Additional group_by command in order to group Additional_LTC groups and totals together
    hri_ltc_totals <- hri_ltc_totals %>% group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC) %>%
      summarise(cvd = sum(cvd),
                copd = sum(copd),
                dementia = sum(dementia),
                diabetes = sum(diabetes),
                chd = sum(chd),
                hefailure = sum(hefailure),
                refailure = sum(refailure),
                epilepsy = sum(epilepsy),
                asthma = sum(asthma),
                atrialfib = sum(atrialfib),
                cancer = sum(cancer),
                arth = sum(arth),
                parkinsons = sum(parkinsons),
                liver = sum(liver),
                ms = sum(ms),
                No_LTC = sum(No_LTC),
                Any_LTC = sum(Any_LTC),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Beddays = sum(Total_Beddays)) %>%
      ungroup()
    
    
    #To get correct Patients Numbers for each LTC make NumberPatients equal to the LTC counts
    hri_ltc_totals %<>% 
      
      mutate(NumberPatients = if_else(LTC == "cvd", cvd, 
                              if_else(LTC == "copd", copd,
                              if_else(LTC == "dementia", dementia,
                              if_else(LTC == "diabetes", diabetes,
                              if_else(LTC == "chd", chd,
                              if_else(LTC == "hefailure", hefailure,
                              if_else(LTC == "refailure", refailure,
                              if_else(LTC == "epilepsy", epilepsy,
                              if_else(LTC == "asthma", asthma, 
                              if_else(LTC == "atrialfib", atrialfib, 
                              if_else(LTC == "cancer", cancer, 
                              if_else(LTC == "arth", arth, 
                              if_else(LTC == "parkinsons", parkinsons, 
                              if_else(LTC == "liver", liver,
                              if_else(LTC == "ms", ms, 
                              if_else(LTC == "Any LTC", Any_LTC,
                              if_else(LTC == "No LTC", No_LTC, 0)))))))))))))))))) %>%
      
      #Add HRI flags
      mutate(hri50_flag = if_else(UserType == "lca-hri_50", 1, 0),
             hri65_flag = if_else(UserType == "lca-hri_65", 1, 0),
             hri80_flag = if_else(UserType == "lca-hri_80", 1, 0),
             hri95_flag = if_else(UserType == "lca-hri_95", 1, 0))
    
   #Save file
   write_sav(hri_ltc_totals, 
              here("checks", glue("hri_ltc_totals_R.sav")), compress = TRUE)
   
    
   ########################################################################
   ### Create 'Other User' totals for proper comparison with HRI users  ###
   ########################################################################
    
   
   ## Create Totals for All patients ##
   
   hri_ltc_all_totals <- hri_ltc_totals %>%
      
      #Select only All Patients data
      filter(UserType == "lca-hri_all") %>%
      
      #Rename variables 
      rename(NumberPatients_ALL = NumberPatients,
             Total_Cost_ALL = Total_Cost,
             Total_Beddays_ALL = Total_Beddays,
             cvd_ALL = cvd,
             copd_ALL = copd, 
             dementia_ALL = dementia,
             diabetes_ALL = diabetes,
             chd_ALL = chd,
             hefailure_ALL = hefailure,
             refailure_ALL = refailure,
             epilepsy_ALL = epilepsy,
             asthma_ALL = asthma,
             atrialfib_ALL = atrialfib,
             cancer_ALL = cancer,
             arth_ALL = arth,
             parkinsons_ALL = parkinsons,
             liver_ALL = liver,
             ms_ALL = ms,
             Neurodegenerative_ALL = Neurodegenerative, 
             Cardio_ALL = Cardio,
             Respiratory_ALL = Respiratory, 
             OtherOrgan_ALL = OtherOrgan,
             No_LTC_ALL = No_LTC,
             Any_LTC_ALL = Any_LTC) %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, ServiceType, LTC, Additional_LTC) %>%
      
      #recreate LTC counts and output aggregated costs, beddays due to Additional_LTC reclassification
      summarise(cvd_ALL = sum(cvd_ALL),
                copd_ALL = sum(copd_ALL),
                dementia_ALL = sum(dementia_ALL),
                diabetes_ALL = sum(diabetes_ALL),
                chd_ALL = sum(chd_ALL),
                hefailure_ALL = sum(hefailure_ALL),
                refailure_ALL = sum(refailure_ALL),
                epilepsy_ALL = sum(epilepsy_ALL),
                asthma_ALL = sum(asthma_ALL),
                atrialfib_ALL = sum(atrialfib_ALL),
                cancer_ALL = sum(cancer_ALL),
                arth_ALL = sum(arth_ALL),
                parkinsons_ALL = sum(parkinsons_ALL),
                liver_ALL = sum(liver_ALL),
                ms_ALL = sum(ms_ALL),
                No_LTC_ALL = sum(No_LTC_ALL),
                Any_LTC_ALL = sum(Any_LTC_ALL),
                Neurodegenerative_ALL = sum(Neurodegenerative_ALL),
                Cardio_ALL = sum(Cardio_ALL),
                Respiratory_ALL = sum(Respiratory_ALL),
                OtherOrgan_ALL = sum(OtherOrgan_ALL),
                NumberPatients_ALL = sum(NumberPatients_ALL),
                Total_Cost_ALL = sum(Total_Cost_ALL),
                Total_Beddays_ALL = sum(Total_Beddays_ALL)) %>%
      
      ungroup() %>%
      
      #Sort data by the different breakdowns
      arrange(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, ServiceType, LTC, Additional_LTC) 
  
   
      #Save file
      write_sav(hri_ltc_all_totals, 
            here("checks", glue("hri_ltc_all_totals_R.sav")), compress = TRUE)
    
    ####################################
    ## Create Totals for Other Users  ##
    ####################################
    
    hri_ltc_users <- hri_ltc_totals %>%
      
      #Select All HRIs only from HRI data
      filter(UserType != "lca-hri_all")  %>% 
      #Sort data by the different breakdowns
      arrange(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, ServiceType, LTC, Additional_LTC)  
    
    
    #Join All HRIs with all patients totals and create Other Users totals
    hri_ltc_other_users <- left_join(hri_ltc_users, hri_ltc_all_totals, 
                                     by = c("Year", "LCAname", "LA_CODE", "HB_CODE",
                                            "Gender", "AgeBand", "ServiceType", "LTC", "Additional_LTC")) %>% 
      
      #Sort data by LCAname) 
      arrange(LCAname) %>%
      
      #Rename HRI user variables 
      rename(NumberPatients_OLD = NumberPatients,
             Total_Cost_OLD = Total_Cost,
             Total_Beddays_OLD = Total_Beddays,
             cvd_OLD = cvd,
             copd_OLD = copd,
             dementia_OLD = dementia,
             diabetes_OLD = diabetes,
             chd_OLD = chd,
             hefailure_OLD = hefailure,
             refailure_OLD = refailure,
             epilepsy_OLD = epilepsy,
             asthma_OLD = asthma,
             atrialfib_OLD = atrialfib,
             cancer_OLD = cancer,
             arth_OLD = arth,
             parkinsons_OLD = parkinsons,
             liver_OLD = liver,
             ms_OLD = ms,
             Neurodegenerative_OLD = Neurodegenerative,
             Cardio_OLD = Cardio,
             Respiratory_OLD = Respiratory,
             OtherOrgan_OLD = OtherOrgan,
             No_LTC_OLD = No_LTC,
             Any_LTC_OLD = Any_LTC) 
    
    
  #Create Other Users Patients Numbers    
  hri_ltc_other_users %<>% 
    
      mutate(NumberPatients = NumberPatients_ALL - NumberPatients_OLD,
             Total_Cost = Total_Cost_ALL - Total_Cost_OLD,
             Total_Beddays = Total_Beddays_ALL - Total_Beddays_OLD,
             cvd = cvd_ALL - cvd_OLD,
             copd = copd_ALL - copd_OLD,
             dementia = dementia_ALL - dementia_OLD,
             diabetes = diabetes_ALL - diabetes_OLD,
             chd = chd_ALL - chd_OLD,
             hefailure = hefailure_ALL - hefailure_OLD,
             refailure = refailure_ALL - refailure_OLD,
             asthma = asthma_ALL - asthma_OLD,
             atrialfib = atrialfib_ALL - atrialfib_OLD,
             ms = ms_ALL - ms_OLD,
             cancer = cancer_ALL - cancer_OLD,
             arth = arth_ALL - arth_OLD,
             parkinsons = parkinsons_ALL - parkinsons_OLD,
             liver = liver_ALL - liver_OLD,
             Neurodegenerative = Neurodegenerative_ALL - Neurodegenerative_OLD,
             Cardio = Cardio_ALL - Cardio_OLD,
             Respiratory = Respiratory_ALL - Respiratory_OLD,
             OtherOrgan = OtherOrgan_ALL - OtherOrgan_OLD,
             No_LTC = No_LTC_ALL - No_LTC_OLD,
             Any_LTC = Any_LTC_ALL - Any_LTC_OLD) %>%
      
      #Add User Type category
      mutate(UserType = "Other Service Users")
    
  
  
   #Check HRI Other Service figures
   check_hri_other_users <- hri_ltc_other_users %>%
     
     select(Year, LCAname, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC, NumberPatients, 
            Total_Cost, Total_Beddays, cvd:Any_LTC)
   
   write_sav(check_hri_other_users, 
             here("data", "basefiles", glue("hri_other_service_users_updated_R.sav")), compress = TRUE)
   
    
   
   
    # Bring files together #
    ltc_temp_bind <- bind_rows(hri_ltc_totals, hri_ltc_other_users) %>%
      
      #Sort data by the different breakdowns
      arrange(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, ServiceType, LTC, Additional_LTC) 
    
    
    ltc_temp <- 
      
      #Join LTC temp data with hri_ltc_all_totals
      full_join(ltc_temp_bind, hri_ltc_all_totals)  %>% 
      
      #Sort by LCA name
      arrange(LCAname) 
    
    
    #Format LTCs by LTC group
    ltc_groups_temp <- ltc_temp %>%
      
      #Add LTC group names 
      mutate(LTC_grp = ltc_grp_name(LTC)) %>%
      
      #remove old LTC variable
      select(-LTC) %>%
      
      #rename LTC_grp
      rename(LTC = LTC_grp)
    
    
    #Select only information by LTC groups & create totals by LTC groups
    ltc_groups_temp %<>% filter(LTC == ("Neurodegenerative - Grp") | (LTC == "Cardio - Grp") | 
                                LTC == ("Respiratory - Grp") | (LTC == "Other Organ - Grp"))   %>%
      
      #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
      group_by(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC, 
               hri50_flag, hri65_flag, hri80_flag, hri95_flag) %>%
      
      summarise(cvd = sum(cvd),
                copd = sum(copd),
                dementia = sum(dementia),
                diabetes = sum(diabetes),
                chd = sum(chd),
                hefailure = sum(hefailure),
                refailure = sum(refailure),
                epilepsy = sum(epilepsy),
                asthma = sum(asthma),
                atrialfib = sum(atrialfib),
                cancer = sum(cancer),
                arth = sum(arth),
                parkinsons = sum(parkinsons),
                liver = sum(liver),
                ms = sum(ms),
                No_LTC = sum(No_LTC),
                Any_LTC = sum(Any_LTC),
                NumberPatients = sum(NumberPatients),
                NumberPatients_ALL = sum(NumberPatients_ALL),
                Neurodegenerative = sum(Neurodegenerative),
                Cardio = sum(Cardio),
                Respiratory = sum(Respiratory),
                OtherOrgan = sum(OtherOrgan),
                Total_Cost = sum(Total_Cost),
                Total_Cost_ALL = sum(Total_Cost_ALL),
                Total_Beddays = sum(Total_Beddays),
                Total_Beddays_ALL = sum(Total_Beddays_ALL)) %>%
      
      ungroup()
      
      
  #################################################################################     
  ### Create final file bringing files together and add information for tooltip ###
  #################################################################################
    
  hri_ltc_final_temp <- bind_rows(ltc_groups_temp, ltc_temp) %>% 
    
  #Remove HRI ALL
  filter(UserType != "lca-hri_all") %>%
    
  #Format User Type names
  mutate(UserType_New = user_type_format(UserType)) %>%
    
  #Remove old User Type variable 
  select(-UserType) %>% 
  
  #Rename variable  
  rename(UserType = UserType_New) %>%
  
  #Remove unwanted variables
  select(-cvd_ALL, -copd_ALL, -dementia_ALL, -diabetes_ALL, -chd_ALL, -hefailure_ALL, -refailure_ALL, 
         -epilepsy_ALL, -asthma_ALL, -atrialfib_ALL, -ms_ALL, -cancer_ALL, -arth_ALL, -parkinsons_ALL,
         -liver_ALL, -Neurodegenerative_ALL, -Cardio_ALL, -Respiratory_ALL, -OtherOrgan_ALL, 
         -No_LTC_ALL, Any_LTC_ALL, -cvd_OLD, -copd_OLD, -dementia_OLD, -diabetes_OLD, -chd_OLD, 
         -hefailure_OLD, -refailure_OLD, -epilepsy_OLD, -asthma_OLD, -atrialfib_OLD, -ms_OLD, 
         -cancer_OLD, -arth_OLD, -parkinsons_OLD,
         -liver_OLD, -Neurodegenerative_OLD, -Cardio_OLD, -Respiratory_OLD, -OtherOrgan_OLD, 
         -No_LTC_OLD, -Any_LTC_OLD, -Total_Cost_OLD, -NumberPatients_OLD, Total_Beddays_OLD) %>%
    
  #Sort Variables
  select(Year, LCAname, LA_CODE, HB_CODE, Gender, AgeBand, UserType, ServiceType, LTC, Additional_LTC, hri50_flag,
         hri65_flag, hri80_flag, hri95_flag, cvd, copd, dementia, diabetes, chd, hefailure, refailure, 
         epilepsy, asthma, atrialfib, ms, cancer, arth, parkinsons, liver, No_LTC, Any_LTC, NumberPatients,
         NumberPatients_ALL, Total_Cost, Total_Cost_ALL, Total_Beddays, Total_Beddays_ALL, Neurodegenerative, 
         Cardio, Respiratory, OtherOrgan) %>%
    
  #Replace NAs with 0
  mutate_if(is.numeric, ~replace_na(., 0))
    
  
  ### Add aggregated information to be used for dashboard tooltips ###
  hri_ltc_final_tooltip <- hri_ltc_final_temp %>%
    
    #Break information by LCAname, Gender, Age Groups and all LTC/LTC groups
    group_by(Year, LCAname, Gender, AgeBand, UserType, ServiceType, LTC, 
             hri50_flag, hri65_flag, hri80_flag, hri95_flag) %>%
    
    summarise(NumberPatients_HRIGrp = sum(NumberPatients),
              Total_Cost_HRIGrp = sum(Total_Cost),
              Total_Beddays_HRIGrp = sum(Total_Beddays)) %>%
    
    ungroup()
  
 ### Join all final information ###
 hri_ltc_final <- full_join(hri_ltc_final_temp, hri_ltc_final_tooltip) %>% 
   
   #Add dummy row
   add_row(LCAname = "Please select Partnership", LA_CODE = "S12000046") 
  
    
  #######################
  ##  Save Final File  ##
  #######################
  
  write_sav(hri_ltc_final, 
            here("data", "basefiles", glue("hri_ltc_final.sav")), compress = TRUE)
  
  
    
    