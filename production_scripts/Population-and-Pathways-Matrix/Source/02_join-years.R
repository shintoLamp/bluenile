######################################################################
# Name of Script - 00_setup-environment.R
# Publication - Populations & Pathways Matrix
# Original Author - Gaby Carrillo based on the SPSS syntax
# Original Date - June 2022
# 
#              Note: Only the FYs need to be updated (Step 1).
#
# Written/run on - R Studio Server
# Version of R - 3.6.1 (2019-07-05) -- "Action of the Toes"
#
# Description of content - Setup environment to run 01_create-data.R
#
# Running time: <1 minute
######################################################################

### 1 - Define financial years to be included in short format
year_1 <- "1718"
year_2 <- "1819"
year_3 <- "1920"
year_4 <- "2021"

######################################################################

### 2 - Open files
year_1 <- readRDS(glue("/conf/sourcedev/TableauUpdates/Matrix/Source/Output/",
                        "source_tde_", "{year_1}.rds"))
year_2 <- readRDS(glue("/conf/sourcedev/TableauUpdates/Matrix/Source/Output/",
                       "source_tde_", "{year_2}.rds"))
year_3 <- readRDS(glue("/conf/sourcedev/TableauUpdates/Matrix/Source/Output/",
                       "source_tde_", "{year_3}.rds"))
year_4 <- readRDS(glue("/conf/sourcedev/TableauUpdates/Matrix/Source/Output/",
                       "source_tde_", "{year_4}.rds"))

final <- rbind.data.frame(year_1, year_2, year_3, year_4)

######################################################################

### 3 - Add LA_Code variable which is used to apply security filters and recode names.
final %<>% 
  mutate(partnership = case_when(
    partnership == 'Argyll & Bute' ~ 'Argyll and Bute',
    partnership == 'Dumfries & Galloway' ~ 'Dumfries and Galloway',
    partnership == 'Perth & Kinross' ~ 'Perth and Kinross',
    TRUE ~ as.character(partnership)))

final %<>% 
  mutate(LA_Code = case_when(
    partnership == 'Aberdeen City' ~ 'S12000033',
    partnership == 'Aberdeenshire' ~ 'S12000034',
    partnership == 'Angus' ~ 'S12000041',
    partnership == 'Argyll and Bute' ~ 'S12000035',
    partnership == 'Clackmannanshire' ~ 'S12000005',
    partnership == 'Dumfries and Galloway' ~ 'S12000006',
    partnership == 'Dundee City' ~ 'S12000042',
    partnership == 'East Ayrshire' ~ 'S12000008',
    partnership == 'East Dunbartonshire' ~ 'S12000045',
    partnership == 'East Lothian' ~ 'S12000010',
    partnership == 'East Renfrewshire' ~ 'S12000011',
    partnership == 'City of Edinburgh' ~ 'S12000036',
    partnership == 'Falkirk' ~ 'S12000014',
    partnership == 'Fife' ~ 'S12000015',
    partnership == 'Glasgow City' ~ 'S12000046',
    partnership == 'Highland' ~ 'S12000017',
    partnership == 'Inverclyde' ~ 'S12000018',
    partnership == 'Midlothian' ~ 'S12000019',
    partnership == 'Moray' ~ 'S12000020',
    partnership == 'North Ayrshire' ~ 'S12000021',
    partnership == 'North Lanarkshire' ~ 'S12000044',
    partnership == 'Orkney Islands' ~ 'S12000023',
    partnership == 'Perth and Kinross' ~ 'S12000024',
    partnership == 'Renfrewshire' ~ 'S12000038',
    partnership == 'Scottish Borders' ~ 'S12000026',
    partnership == 'Shetland Islands' ~ 'S12000027',
    partnership == 'South Ayrshire' ~ 'S12000028',
    partnership == 'South Lanarkshire' ~ 'S12000029',
    partnership == 'Stirling' ~ 'S12000030',
    partnership == 'West Dunbartonshire' ~ 'S12000039',
    partnership == 'West Lothian' ~ 'S12000040',
    partnership == 'Na h-Eileanan Siar' ~ 'S12000013'))

clack_and_stirling <- final %>% 
  filter(partnership == 'Clackmannanshire' | partnership == 'Stirling')         

clack_and_stirling %<>% 
  mutate(LA_Code = case_when(
    partnership == 'Clackmannanshire' ~ 'S12000005',
    partnership == 'Stirling' ~ 'S12000005',
    TRUE ~ as.character(LA_Code)))

clack_and_stirling %<>% 
  mutate(partnership = case_when(
    partnership == 'Clackmannanshire' ~ 'Clackmannanshire and Stirling',
    partnership == 'Stirling' ~ 'Clackmannanshire and Stirling',
    TRUE ~ as.character(partnership)))

clack_and_stirling %<>% 
  group_by(year, partnership, LA_Code, locality, service_use_cohort, demographic_cohort, simd_quintile,
           resource_group, age_band, urban_rural, ltc_total, gender, hhg_risk_group, data, service_area, 
           ltc_name, demograph_name) %>% 
  summarise(no_patients = sum(no_patients),
            total_cost = sum(total_cost),
            total_beddays = sum(total_beddays),
            total_attendances = sum(total_attendances),
            total_admissions = sum(total_admissions),
            unplanned_beddays = sum(unplanned_beddays),
            ae2_attendances = sum(ae2_attendances),
            outpatient_attendances = sum(outpatient_attendances),
            comm_living = sum(comm_living),
            adult_major = sum(adult_major),
            child_major = sum(child_major),
            low_cc = sum(low_cc),
            medium_cc = sum(medium_cc),
            high_cc = sum(high_cc),
            substance = sum(substance),
            mh = sum(mh),
            maternity = sum(maternity),
            frailty = sum(frailty),
            end_of_life = sum(end_of_life),
            zero_ltc = sum(zero_ltc),
            one_ltc = sum(one_ltc),
            two_ltc = sum(two_ltc),
            three_ltc = sum(three_ltc),
            four_ltc = sum(four_ltc),
            five_ltc = sum(five_ltc),
            arth = sum(arth),
            asthma = sum(asthma),
            atrialfib = sum(atrialfib),
            cancer = sum(cancer),
            copd = sum(copd),
            cvd = sum(cvd),
            dementia = sum(dementia),
            diabetes = sum(diabetes),
            epilepsy = sum(epilepsy),
            chd = sum(chd),
            hefailure = sum(hefailure),
            liver = sum(liver),
            ms = sum(ms),
            parkinsons = sum(parkinsons),
            refailure = sum(refailure),
            delayed_episodes = sum(delayed_episodes),
            delayed_beddays = sum(delayed_beddays),
            delayed_patients = sum(delayed_patients),
            preventable_admissions = sum(preventable_admissions),
            preventable_beddays = sum(preventable_beddays)) %>% 
  ungroup()


######################################################################

### 4 - Create and save final file
final <- rbind.data.frame(final, clack_and_stirling)


# Remove other elements from the environment
rm(clack_and_stirling, year_1, year_2, year_3, year_4)


# Save file
saveRDS(final, file = "/conf/sourcedev/TableauUpdates/Matrix/Source/Output/Final/SOURCE_TDE.rds")

### End of Script ### 
