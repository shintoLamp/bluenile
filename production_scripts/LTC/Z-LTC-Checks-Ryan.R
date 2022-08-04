############################################################
## Code name - LTC.R                                      ##
## Description - Creates the data source for the LTC      ##
## workbook                                               ##
## Written by: Bateman McBride                            ##
## First written: January 2022                            ##
## Updated:                                               ##
############################################################

###################################################################
# Section 1: Reading in the data and aggregating to CHI/Recid level
# Extract Source Episode Files for four financial years with required variables
ltc_master <- read_slf_episode(finyear,
  columns = c(
    "year", "anon_chi", "datazone2011", "ca2018", "hbrescode", "age", "gender", "cij_pattype", "recid", "tadm",
    "cost_total_net", "yearstay", "simd2020v2_hb2019_quintile"
  )
) %>%
  # We only want the following recids
  filter(recid %in% c("00B", "01B", "02B", "04B", "GLS", "AE2", "PIS")) %>%
  # Filter out empty lcas and chi numbers
  filter(hbrescode != "" & ca2018 != "" & anon_chi != "") %>%     # Modified
  # Recode age groups
  age_groups_cut(age) %>% 
  # Get rid of empty age groups
  filter(age_grp != "") %>%
  # Recode gender to M/F
  mutate(gender = case_when(
    gender == 1 ~ "M",
    gender == 2 ~ "F"
  )) %>%
  # Get rid of empty genders
  filter(gender == "M" | gender == "F") %>%
  # Get rid of ungrouped ages
  select(-age) %>%
  # Turn the year variable into financial year format
  mutate(year = as.character(year)) %>%
  mutate(year = str_c("20", str_sub(year, 1, 2), "/", str_sub(year, 3, 4))) %>%
  rename(simd = simd2020v2_hb2019_quintile) %>%
  # remove_value_labels() %>%
  replace_na(list(yearstay = 0)) %>%
  # Use a mix of cij_pattype, tadm and recid to determine planned and unplanned episodes
  mutate(patient_type = case_when(
    cij_pattype == "Non-Elective" ~ "Unplanned",
    cij_pattype == "Elective" ~ "Planned",
    cij_pattype == "Maternity" ~ "Maternity",
    (recid == "00B") & (!(cij_pattype == "Non-Elective")) ~ "Planned",
    recid == "AE2" ~ "Unplanned",
    recid == "PIS" ~ "Prescribing")) %>% 
  # For some situations patient_type will not be filled so use tadm here
  mutate(patient_type = case_when(
    is.na(patient_type) & str_sub(tadm, end = 1) == "3" ~ "Unplanned",
    is.na(patient_type) & str_sub(tadm, end = 1) == "4" ~ "Maternity",
    is.na(patient_type) & str_sub(tadm, end = 1) != "3" ~ "Planned",
    TRUE ~ as.character(patient_type)))

#****************************************************************************
#****************************** S T E P  -  2 *******************************
#****************************************************************************
# In this section, we need to aggregate to CHI level. However, this is very slow and so
# the following code is an attempt to make this process more efficient

# Firstly, find any CHI/recid pairs that appear more than once and create a vector of them
#duplicate_chi_recid_pairs <- ltc_master %>%
#  group_by(anon_chi, recid) %>%
#  summarise(duplicate = n(), .groups = "keep") %>%
#  filter(duplicate > 1)

# Now subset the ltc_master df with those duplicated CHI/recid pairs
#extracted_duplicates <- semi_join(ltc_master, duplicate_chi_recid_pairs, by = "anon_chi") %>% group_by(anon_chi, recid)
# Similarly, get a df that contains no duplicates
#extracted_uniques <- anti_join(ltc_master, duplicate_chi_recid_pairs, by = "anon_chi")

# The duplicates are already grouped on CHI/recid so here we add the other groupings and aggregate.
# This roughly halves the computing time
#aggregated_duplicates <- extracted_duplicates %>%
#  group_by(year, hbrescode, ca2018, datazone2011, gender, age_grp, patient_type, simd, .add = TRUE) %>%
#  summarise(across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE),
#    .groups = "keep"
#  ) %>%
#  ungroup()

# Put the aggregated duplicates and the non-duplicates back into the same frame
#ltc_chi <- bind_rows(aggregated_duplicates, extracted_uniques)

# Identify unique cases according to certain criteria 
# ltc_chi <- distinct(ltc_master, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid, .keep_all = TRUE)    # Added

# Now we can bring in the variables relating to LTCs from the SLF Individual File.
ltc_master <- left_join(ltc_master,
                        read_slf_individual("1819", columns = c("anon_chi", ltc_names)),
                        by = "anon_chi"
)

# Creates an output file to summarise counts and costs, need to do this 3 times, one for each output file, this is for ltcs_lca
ltc_chi <- ltc_master %>% group_by(year, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%
        summarise(cost_total_net=sum(cost_total_net),
                  yearstay=sum(yearstay),
                  cvd=max(cvd),
                  copd=max(copd),
                  dementia=max(dementia),
                  diabetes=max(diabetes),
                  chd=max(chd),
                  hefailure=max(hefailure),
                  refailure=max(refailure),
                  epilepsy=max(epilepsy),
                  asthma=max(asthma),
                  atrialfib=max(atrialfib),
                  cancer=max(cancer),
                  arth=max(arth),
                  parkinsons=max(parkinsons),
                  liver=max(liver),
                  ms=max(ms))

ltc_chi <- ltc_chi %>% mutate(
  LTC = ifelse((cvd == 1)|(copd == 1)|(dementia == 1)|(diabetes == 1)|
                 (chd == 1)|(hefailure == 1)|(refailure == 1)|(epilepsy == 1)|
                 (asthma == 1)|(atrialfib == 1)|(cancer == 1)|(arth == 1)|
                 (parkinsons == 1)|(liver == 1)|(ms == 1), 1, 0)
)

ltc_chi <- rename(ltc_chi, any_1_plus = LTC)

# Creates a list of tibbles, one for when each ltc is present, need to do this 3 times, one for each output file
ltcs_individual_list <- list(
  any_1_plus = filter(ltc_chi, any_1_plus == 1),
  cvd = filter(ltc_chi, cvd == 1),
  copd = filter(ltc_chi, copd == 1),
  dementia = filter(ltc_chi, dementia == 1),
  diabetes = filter(ltc_chi, diabetes == 1),
  chd = filter(ltc_chi, chd == 1),
  hefailure = filter(ltc_chi, hefailure == 1),
  refailure = filter(ltc_chi, refailure == 1),
  epilepsy = filter(ltc_chi, epilepsy == 1),
  asthma = filter(ltc_chi, asthma == 1),
  atrialfib = filter(ltc_chi, atrialfib == 1),
  cancer = filter(ltc_chi, cancer == 1),
  arth = filter(ltc_chi, arth == 1),
  parkinsons = filter(ltc_chi, parkinsons == 1),
  liver = filter(ltc_chi, liver == 1),
  ms = filter(ltc_chi, ms == 1)
)

#Combine LTCs into groups as defined by lookup files, new variable for each grouping
ltc_chi <- ltc_chi %>% mutate(
  cardiovascular = if_else((atrialfib == 1)|(chd == 1)|(cvd == 1)|(hefailure == 1), 1, 0))
#Neurodegenerative grouping
ltc_chi <- ltc_chi %>% mutate(
  neurodegenerative = if_else((dementia == 1)|(ms == 1)|(parkinsons == 1), 1, 0))
#Respiratory grouping
ltc_chi <- ltc_chi %>% mutate(
  respiratory = if_else((asthma == 1)|(copd == 1), 1, 0))
#Other organs grouping
ltc_chi <- ltc_chi %>% mutate(
  other_organs = if_else((liver == 1)|(refailure == 1), 1, 0))
#Other LTCs grouping
ltc_chi <- ltc_chi %>% mutate(
  other_ltcs = if_else((arth == 1)|(cancer == 1)|(diabetes == 1)|(epilepsy == 1), 1, 0))
#No LTC grouping
ltc_chi <- ltc_chi %>% mutate(
  no_ltc = if_else(any_1_plus == 0, 1, 0))

# Creates a list of tibbles, one for when each ltc group is present
ltcs_group_list <- list(
  cardiovascular = filter(ltc_chi, cardiovascular == 1),
  neurodegenerative = filter(ltc_chi, neurodegenerative == 1),
  respiratory = filter(ltc_chi, respiratory == 1),
  other_organs = filter(ltc_chi, other_organs == 1),
  other_ltcs = filter(ltc_chi, other_ltcs == 1),
  no_ltc = filter(ltc_chi, no_ltc == 1)
)

#****************************************************************************
#****************************** S T E P  -  3 *******************************
#****************************************************************************

###################################################################
# Section 2 - Grouping individual LTCs
# We want to aggregate the ltc_chi dataset to three levels - LCA, Locality, and Datazone
# This is done because we need to match populations at said levels

# LCA level
# Use purrr::map_dfr to apply the aggregation to all of the members of the list ltcs_individual_list,
# and bind them back into a single data frame. The variable "type" will contain the names of the
# list elements
ltcs_lca <- ltcs_individual_list %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%
      summarise(across(all_of(ltc_names), sum, na.rm = TRUE),
        across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE),
        count = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>%
  mutate(lcaname = match_area(ca2018),
  # Create Clackmannanshire & Stirling as its own LCA
  temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
                     "Clackmannanshire & Stirling",
                     NA_character_)) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)

ltcs_lca <- ltcs_lca %>% group_by(year, hbrescode, age_grp, gender, type, recid, patient_type) %>%
                mutate(hbres_count = sum(count)) %>%
                ungroup()

ltcs_lca <- ltcs_lca %>% group_by(year, age_grp, gender, type, recid, patient_type) %>%
            mutate(scot_count = sum(count)) %>%
            ungroup()

#Create aggregated output using LTC groups, binding the list into a singl data frame as above with
groups_lca <- ltcs_group_list %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%
      summarise(across(all_of(ltc_group_names), sum, na.rm = TRUE),      
                across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE),
                count = n(),
                .groups = "keep"
      ),
    .id = "type"
  ) %>%
  mutate(lcaname = match_area(ca2018),
         # Create Clackmannanshire & Stirling as its own LCA
         temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling", 
                            "Clackmannanshire & Stirling", 
                            NA_character_)) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)

groups_lca <- select(groups_lca, -Cardiovascular, -Neurodegenerative, -Respiratory, -Other_Organs, -Other_LTCs, -No_LTC)

groups_lca <- groups_lca %>% group_by(year, hbrescode, age_grp, gender, type, recid, patient_type) %>%
  mutate(hbres_count = sum(count)) %>%
  ungroup()

groups_lca <- groups_lca %>% group_by(year, age_grp, gender, type, recid, patient_type) %>%
  mutate(scot_count = sum(count)) %>%
  ungroup()

ltcs_lca_final <- bind_rows(ltcs_lca, groups_lca)

# Datazone level, need to re-use ltc_master file but group by using different variables, then follow through similar process as above
ltc_map <- ltc_master %>% group_by(year, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, datazone2011, simd) %>%
  summarise(cost_total_net=sum(cost_total_net),
            yearstay=sum(yearstay),
            cvd=max(cvd),
            copd=max(copd),
            dementia=max(dementia),
            diabetes=max(diabetes),
            chd=max(chd),
            hefailure=max(hefailure),
            refailure=max(refailure),
            epilepsy=max(epilepsy),
            asthma=max(asthma),
            atrialfib=max(atrialfib),
            cancer=max(cancer),
            arth=max(arth),
            parkinsons=max(parkinsons),
            liver=max(liver),
            ms=max(ms))

ltc_map <- ltc_map %>% mutate(
  LTC = ifelse((cvd == 1)|(copd == 1)|(dementia == 1)|(diabetes == 1)|
                 (chd == 1)|(hefailure == 1)|(refailure == 1)|(epilepsy == 1)|
                 (asthma == 1)|(atrialfib == 1)|(cancer == 1)|(arth == 1)|
                 (parkinsons == 1)|(liver == 1)|(ms == 1), 1, 0)
)

ltc_map <- rename(ltc_map, any_1_plus = LTC)

# Creates a list of tibbles, one for when each ltc is present
ltcs_individual_list_map <- list(
  any_1_plus = filter(ltc_map, any_1_plus == 1),
  cvd = filter(ltc_map, cvd == 1),
  copd = filter(ltc_map, copd == 1),
  dementia = filter(ltc_map, dementia == 1),
  diabetes = filter(ltc_map, diabetes == 1),
  chd = filter(ltc_map, chd == 1),
  hefailure = filter(ltc_map, hefailure == 1),
  refailure = filter(ltc_map, refailure == 1),
  epilepsy = filter(ltc_map, epilepsy == 1),
  asthma = filter(ltc_map, asthma == 1),
  atrialfib = filter(ltc_map, atrialfib == 1),
  cancer = filter(ltc_map, cancer == 1),
  arth = filter(ltc_map, arth == 1),
  parkinsons = filter(ltc_map, parkinsons == 1),
  liver = filter(ltc_map, liver == 1),
  ms = filter(ltc_map, ms == 1)
)

# Datazone level
ltcs_datazone <- ltcs_individual_list_map %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, datazone2011, simd, gender, age_grp, patient_type) %>%
      summarise(across(c("cost_total_net"), sum, na.rm = TRUE),
        count = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>%
  mutate(lcaname = match_area(ca2018),
         # Create Clackmannanshire & Stirling as its own LCA
         temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
                            "Clackmannanshire & Stirling",
                            NA_character_)) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)

# Locality level
# First use lookup to match Locality names by Datazone
ltc_locality <- left_join(ltc_master,
                         get_dz_lookup("20200825", c("datazone2011", "hscp_locality")),
                         by = "datazone2011"
  )

ltc_locality <- ltc_locality %>% group_by(year, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, hscp_locality) %>%
  summarise(cost_total_net=sum(cost_total_net),
            yearstay=sum(yearstay),
            cvd=max(cvd),
            copd=max(copd),
            dementia=max(dementia),
            diabetes=max(diabetes),
            chd=max(chd),
            hefailure=max(hefailure),
            refailure=max(refailure),
            epilepsy=max(epilepsy),
            asthma=max(asthma),
            atrialfib=max(atrialfib),
            cancer=max(cancer),
            arth=max(arth),
            parkinsons=max(parkinsons),
            liver=max(liver),
            ms=max(ms))

ltc_locality <- ltc_locality %>% mutate(
  LTC = ifelse((cvd == 1)|(copd == 1)|(dementia == 1)|(diabetes == 1)|
                 (chd == 1)|(hefailure == 1)|(refailure == 1)|(epilepsy == 1)|
                 (asthma == 1)|(atrialfib == 1)|(cancer == 1)|(arth == 1)|
                 (parkinsons == 1)|(liver == 1)|(ms == 1), 1, 0)
)

ltc_locality <- rename(ltc_locality, any_1_plus = LTC)

# Creates a list of tibbles, one for when each ltc is present
ltcs_individual_list_locality <- list(
  any_1_plus = filter(ltc_locality, any_1_plus == 1),
  cvd = filter(ltc_locality, cvd == 1),
  copd = filter(ltc_locality, copd == 1),
  dementia = filter(ltc_locality, dementia == 1),
  diabetes = filter(ltc_locality, diabetes == 1),
  chd = filter(ltc_locality, chd == 1),
  hefailure = filter(ltc_locality, hefailure == 1),
  refailure = filter(ltc_locality, refailure == 1),
  epilepsy = filter(ltc_locality, epilepsy == 1),
  asthma = filter(ltc_locality, asthma == 1),
  atrialfib = filter(ltc_locality, atrialfib == 1),
  cancer = filter(ltc_locality, cancer == 1),
  arth = filter(ltc_locality, arth == 1),
  parkinsons = filter(ltc_locality, parkinsons == 1),
  liver = filter(ltc_locality, liver == 1),
  ms = filter(ltc_locality, ms == 1)
)

# Locality level
# First use lookup to match Locality names by Datazone
#ltcs_locality <- ltcs_individual_list %>%
#  purrr::map(~ left_join(.x,
 #   get_dz_lookup("20200825", c("datazone2011", "hscp_locality")),
  #  by = "datazone2011"
  #))

ltcs_locality <- ltcs_individual_list_locality %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, hscp_locality) %>%
      summarise(across(c("cost_total_net"), sum, na.rm = TRUE),
        count = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>%
  mutate(lcaname = match_area(ca2018), 
         temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
                            "Clackmannanshire & Stirling",
                            NA_character_)) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)

###################################################################
# Put LCA, datazone, and locality into a single column for population matching
ltc_file <- bind_rows(ltcs_lca_final, ltcs_datazone, ltcs_locality, .id = "geog_level") %>% 
  mutate(pop_match = case_when(
    geog_level == "1" ~ "LCA",
    geog_level == "2" ~ "Datazone",
    geog_level == "3" ~ "Locality"
  ) 
) %>% 
  select(-geog_level) %>% 
  mutate(geography = 
  case_when(
    pop_match == "LCA" ~ lcaname,
    pop_match == "Datazone" ~ datazone2011,
    pop_match == "Locality" ~ hscp_locality
  )
)

write_sav(ltc_file, "LTC_File_check_Ryan.sav", compress = TRUE)

