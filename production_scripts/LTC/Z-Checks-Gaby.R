##########################################################
# Name of file: "LTC Outputs Comparison.R"
# Original author: Genny Gabriela Carrillo Balam.
# Original date: 20/04/2022
# Type of script: Check
# Written/run on R Studio Server
# Version of R that the script was most recently run on: 3.6.1 (2019-07-05) -- "Action of the Toes"
# Description of content: * Compares SPSS and R final output - the one that will be use to produce
#                           the dashboard in Tableau.
#                         
# Approximate run time: <1 minute.
# All output is saved to folder: 
# "/conf/sourcedev/TableauUpdates/LTC/"
# File paths updated:

##########################################################
#Load Packages
library(haven)
library(dplyr)
library(tibble)
library(janitor)
library(openxlsx)

##########################################################
#Open files
R_LTC <- read_sav("/conf/sourcedev/TableauUpdates/LTC/LTCFileR_test.sav")
R_LTC <- ltc_file
SPSS_LTC  <- read_sav("/conf/sourcedev/TableauUpdates/LTC/Outputs/Test/LTCfile.sav")

##########################################################
smalltestR <- R_LTC %>% 
  filter(hbrescode == "S08000025" & age_grp == 1)
summary(as.factor(smalltestR$patient_type))
summary(as.factor(smalltestR$recid))
summary(as.factor(smalltestR$type))

smalltestSPSS <- SPSS_LTC %>% 
  filter(hbrescode == "S08000025" & agegroup == "0-17" & gender != "All")

smalltestSPSS <- smalltestSPSS %>% 
  filter(Patient_Type != "All")

summary(as.factor(smalltestSPSS$recid))
summary(as.factor(smalltestSPSS$Patient_Type))
summary(as.factor(smalltestSPSS$type))

smalltestSPSS <- smalltestSPSS %>% 
  filter(Patient_Type == "All")

#****************************************************************************
# CHECKS - NOT PART OF THE CODE ONLY TO CHECK AGAINST SPSS
#****************************************************************************
ayrshire_r <- ltc_master %>% 
  filter(hbrescode == "S08000015")

borders_r <- ltc_master %>% 
  filter(hbrescode == "S08000016")

dumfries_r <- ltc_master %>% 
  filter(hbrescode == "S08000017")

forthvalley_r <- ltc_master %>% 
  filter(hbrescode == "S08000019")

grampian_r <- ltc_master %>% 
  filter(hbrescode == "S08000020")

glasgow_r <- ltc_master %>% 
  filter(hbrescode == "S08000021")

highland_r <- ltc_master %>% 
  filter(hbrescode == "S08000022")

lanarkshire_r <- ltc_master %>% 
  filter(hbrescode == "S08000023")

lothian_r <- ltc_master %>% 
  filter(hbrescode == "S08000024")

orkney_r <- ltc_master %>% 
  filter(hbrescode == "S08000025")

shetland_r <- ltc_master %>% 
  filter(hbrescode == "S08000026")

western_r <- ltc_master %>% 
  filter(hbrescode == "S08000028")

hb29_r <- ltc_master %>% 
  filter(hbrescode == "S08000029")

hb30_r <- ltc_master %>% 
  filter(hbrescode == "S08000030")


ayrshire_r <- distinct(ayrshire_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE)    # Added
borders_r <- distinct(borders_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
dumfries_r <- distinct(dumfries_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
forthvalley_r <- distinct(forthvalley_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
grampian_r <- distinct(grampian_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
glasgow_r <- distinct(glasgow_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
highland_r <- distinct(highland_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
lanarkshire_r <- distinct(lanarkshire_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
lothian_r <- distinct(lothian_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
orkney_r <- distinct(orkney_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
shetland_r <- distinct(shetland_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
western_r <- distinct(western_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
hb29_r <- distinct(hb29_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 
hb30_r <- distinct(hb30_r, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE) 


#*********** SPSS ***********
ltc_spss <- read_sav(file="/conf/sourcedev/TableauUpdates/LTC/Outputs/Test/LTC_step1.sav")
ltc_spss <- read_sav(file="/conf/sourcedev/TableauUpdates/LTC/Outputs/Test/LTC_step2.sav")

##########################################################
#Compare number of rows
nrow(ltc_chi)
nrow(ltc_spss)

#Compare cases per financial year
summary(as.factor(ltc_chi$gender))
summary(as.factor(ltc_spss$gender))

summary(as.factor(ltc_chi$age_grp))
summary(as.factor(ltc_spss$agegroup))

summary(as.factor(ltc_spss$hbrescode))
summary(as.factor(ltc_chi$hbrescode))

summary(as.factor(ltc_spss$cvd))
summary(as.factor(ltc_chi$cvd))

summary(as.factor(ltc_spss$copd))
summary(as.factor(ltc_chi$copd))

summary(as.factor(ltc_spss$dementia))
summary(as.factor(ltc_chi$dementia))

summary(as.factor(ltc_spss$diabetes))
summary(as.factor(ltc_chi$diabetes))

summary(as.factor(ltc_spss$chd))
summary(as.factor(ltc_chi$chd))

summary(as.factor(ltc_spss$hefailure))
summary(as.factor(ltc_chi$hefailure))

summary(as.factor(ltc_spss$refailure))
summary(as.factor(ltc_chi$refailure))

summary(as.factor(ltc_spss$epilepsy))
summary(as.factor(ltc_chi$epilepsy))

summary(as.factor(ltc_spss$asthma))
summary(as.factor(ltc_chi$asthma))

summary(as.factor(ltc_spss$atrialfib))
summary(as.factor(ltc_chi$atrialfib))

summary(as.factor(ltc_spss$cancer))
summary(as.factor(ltc_chi$cancer))

summary(as.factor(ltc_spss$arth))
summary(as.factor(ltc_chi$arth))

summary(as.factor(ltc_spss$parkinsons))
summary(as.factor(ltc_chi$parkinsons))

summary(as.factor(ltc_spss$liver))
summary(as.factor(ltc_chi$liver))

summary(as.factor(ltc_spss$ms))
summary(as.factor(ltc_chi$ms))



ayrshire_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000015")
borders_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000016")
dumfries_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000017")
forthvalley_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000019")
grampian_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000020")
glasgow_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000021")
highland_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000022")
lanarkshire_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000023")
lothian_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000024")
orkney_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000025")
shetland_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000026")
western_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000028")
hb29_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000029")
hb30_spss <- ltc_spss %>% 
  filter(hbrescode == "S08000030")
#****************************


#****************************************************************************
# STEP 3
SPSS_step3  <- read_sav("/conf/sourcedev/TableauUpdates/LTC/Outputs/Test/LTC_step3.sav")
SPSS_step3 <- SPSS_step3 %>% 
  filter(Patient_Type != "All")

SPSS_step3 <- SPSS_step3 %>% 
  filter(LTC == "1")

R_step3 <- ltcs_groups
summary(as.factor(R_step3$patient_type))
summary(as.factor(ltcs_lca$patient_type))
summary(as.factor(R_step3$patient_type))
summary(as.factor(SPSS_step3$Patient_Type))

summary(as.factor(R_step3$age_grp))
summary(as.factor(SPSS_step3$agegroup))


#****************************************************************************
# CHECK AGAINST LTC DASHBOARD
db_SPSS  <- read_sav("/conf/sourcedev/TableauUpdates/LTC/Outputs/201819/LTCprogram201819.sav")
db_r <- ltcs_groups

summary(as.factor(db_r$patient_type))
summary(as.factor(db_SPSS$patient_type))
summary(as.factor(db_r$patient_type))
summary(as.factor(db_SPSS$Patient_Type))

summary(as.factor(db_r$age_grp))
summary(as.factor(db_SPSS$agegroup))

summary(as.factor(db_r$no_ltc))
summary(as.factor(db_SPSS$agegroup))




ltcs_lca_2 <- ltcs_individual_list %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%
      summarise(across(all_of(ltc_names), sum, na.rm = TRUE),
                across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE),
                count = n(),
                .groups = "keep"
      ),
    .id = "type"
  ) 
  
  
  
  
  
  
  
  purrr::map_dfr( 
      group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>% 
      summarise(across(all_of(ltc_names), ~
                cost_total=sum(cost_total_net),
                yearstay_total=sum(yearstay))),
    .id = "type")

arrange (.x, year, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%            
            
ltcs_lca_2 <- ltcs_lca_2 %>%
  mutate(lcaname = match_area(ca2018),
         # Create Clackmannanshire & Stirling as its own LCA
         temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
                            "Clackmannanshire & Stirling",
                            NA_character_)) 

ltcs_lca_2 <- ltcs_lca_2 %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)




summary(as.factor(ltcs_lca$gender))

