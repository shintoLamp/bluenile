############################################################
## Code name - LTC.R                                      ##
## Description - Creates the data source for the LTC      ##
## workbook                                               ##
## Written by: Bateman McBride, Gaby Balam, Ryan Harris   ##
## First written: January 2022                            ##
## Updated: May 2022                                      ##
############################################################

# Section 1 - Reading in the data and aggregating to CHI/Recid level ----
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
  filter(hbrescode != "" & ca2018 != "" & anon_chi != "") %>%
  # Modified
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
    recid == "PIS" ~ "Prescribing"
  )) %>%
  # For some situations patient_type will not be filled so use tadm here
  mutate(patient_type = case_when(
    is.na(patient_type) & str_sub(tadm, end = 1) == "3" ~ "Unplanned",
    is.na(patient_type) & str_sub(tadm, end = 1) == "4" ~ "Maternity",
    is.na(patient_type) & str_sub(tadm, end = 1) != "3" ~ "Planned",
    TRUE ~ as.character(patient_type)
  ))

# Bring in the LTC variables from the SLF Individual File
ltc_master <- left_join(ltc_master,
  read_slf_individual("1819", columns = c("anon_chi", ltc_names)),
  by = "anon_chi"
)

# Section 2 - Split the main dataframe into lists based on LTC presence and aggregate level ----

# Creates an output file to summarise counts and costs, need to do this 3 times, one for each output file, this is for ltcs_lca
ltc_chi <- ltc_master %>%
  group_by(year, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%
  summarise(
    cost_total_net = sum(cost_total_net),
    yearstay = sum(yearstay),
    across(ltc_names, max),
    .groups = "keep"
  ) %>%
  ungroup() %>%
  mutate(any_1_plus = reduce(select(., cvd:ms), `|`), across(ltc_names, as.logical))

# Datazone level, need to re-use ltc_master file but group by using different variables, then follow through similar
# process as above
ltc_map <- ltc_master %>%
  group_by(year, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, datazone2011, simd) %>%
  summarise(
    cost_total_net = sum(cost_total_net),
    yearstay = sum(yearstay),
    across(cvd:ms, max)
  ) %>%
  ungroup() %>%
  mutate(any_1_plus = reduce(select(., cvd:ms), `|`), across(ltc_names, as.logical))

# Locality level
# First use lookup to match Locality names by Datazone
ltc_locality <- left_join(ltc_master,
  get_dz_lookup("20200825", c("datazone2011", "hscp_locality")),
  by = "datazone2011"
) %>%
  group_by(year, anon_chi, hbrescode, ca2018, gender, age_grp, patient_type, hscp_locality) %>%
  summarise(
    cost_total_net = sum(cost_total_net),
    yearstay = sum(yearstay),
    across(cvd:ms, max)
  ) %>%
  ungroup() %>%
  mutate(any_1_plus = reduce(select(., cvd:ms), `|`), across(ltc_names, as.logical))


# Creates a list of tibbles, one for when each ltc is present
ltcs_individual_list <- list(
  any_1_plus = filter(ltc_chi, any_1_plus == TRUE),
  cvd = filter(ltc_chi, cvd == TRUE),
  copd = filter(ltc_chi, copd == TRUE),
  dementia = filter(ltc_chi, dementia == TRUE),
  diabetes = filter(ltc_chi, diabetes == TRUE),
  chd = filter(ltc_chi, chd == TRUE),
  hefailure = filter(ltc_chi, hefailure == TRUE),
  refailure = filter(ltc_chi, refailure == TRUE),
  epilepsy = filter(ltc_chi, epilepsy == TRUE),
  asthma = filter(ltc_chi, asthma == TRUE),
  atrialfib = filter(ltc_chi, atrialfib == TRUE),
  cancer = filter(ltc_chi, cancer == TRUE),
  arth = filter(ltc_chi, arth == TRUE),
  parkinsons = filter(ltc_chi, parkinsons == TRUE),
  liver = filter(ltc_chi, liver == TRUE),
  ms = filter(ltc_chi, ms == TRUE)
)

# Creates a list of tibbles, one for when each ltc group is present
ltcs_groups <- ltc_chi %>% cbind(setNames(lapply(ltc_group_names, function(x) x <- FALSE), ltc_group_names))
ltcs_groups_list <- list(
  cardiovascular = ltcs_groups %>% mutate(cardiovascular = reduce(select(., c("atrialfib", "chd", "cvd", "hefailure")), `|`)) %>%
    filter(., cardiovascular == TRUE),
  neurodegenerative = ltcs_groups %>% mutate(neurodegenerative = reduce(select(., c("dementia", "ms", "parkinsons")), `|`)) %>%
    filter(., neurodegenerative == TRUE),
  respiratory = ltcs_groups %>% mutate(respiratory = reduce(select(., c("asthma", "copd")), `|`)) %>%
    filter(., respiratory == TRUE),
  other_organs = ltcs_groups %>% mutate(other_organs = reduce(select(., c("liver", "refailure")), `|`)) %>%
    filter(., other_organs == TRUE),
  other_ltcs = ltcs_groups %>% mutate(other_ltcs = reduce(select(., c("arth", "cancer", "diabetes", "epilepsy")), `|`)) %>%
    filter(., other_ltcs == TRUE),
  no_ltc = ltcs_groups %>% mutate(no_ltc = not(any_1_plus)) %>%
    filter(., no_ltc == TRUE)
)

# List for datazone-level
ltcs_individual_list_map <- list(
  any_1_plus = filter(ltc_map, any_1_plus == TRUE),
  cvd = filter(ltc_map, cvd == TRUE),
  copd = filter(ltc_map, copd == TRUE),
  dementia = filter(ltc_map, dementia == TRUE),
  diabetes = filter(ltc_map, diabetes == TRUE),
  chd = filter(ltc_map, chd == TRUE),
  hefailure = filter(ltc_map, hefailure == TRUE),
  refailure = filter(ltc_map, refailure == TRUE),
  epilepsy = filter(ltc_map, epilepsy == TRUE),
  asthma = filter(ltc_map, asthma == TRUE),
  atrialfib = filter(ltc_map, atrialfib == TRUE),
  cancer = filter(ltc_map, cancer == TRUE),
  arth = filter(ltc_map, arth == TRUE),
  parkinsons = filter(ltc_map, parkinsons == TRUE),
  liver = filter(ltc_map, liver == TRUE),
  ms = filter(ltc_map, ms == TRUE)
)

# List for Locality level
ltcs_individual_list_locality <- list(
  any_1_plus = filter(ltc_locality, any_1_plus == TRUE),
  cvd = filter(ltc_locality, cvd == TRUE),
  copd = filter(ltc_locality, copd == TRUE),
  dementia = filter(ltc_locality, dementia == TRUE),
  diabetes = filter(ltc_locality, diabetes == TRUE),
  chd = filter(ltc_locality, chd == TRUE),
  hefailure = filter(ltc_locality, hefailure == TRUE),
  refailure = filter(ltc_locality, refailure == TRUE),
  epilepsy = filter(ltc_locality, epilepsy == TRUE),
  asthma = filter(ltc_locality, asthma == TRUE),
  atrialfib = filter(ltc_locality, atrialfib == TRUE),
  cancer = filter(ltc_locality, cancer == TRUE),
  arth = filter(ltc_locality, arth == TRUE),
  parkinsons = filter(ltc_locality, parkinsons == TRUE),
  liver = filter(ltc_locality, liver == TRUE),
  ms = filter(ltc_locality, ms == TRUE)
)

# Section 3 - Aggregating to the three required levels ----
# We want to aggregate the ltc_chi dataset to three levels - LCA, Locality, and Datazone
# This is done because we need to match populations at said levels

# LCA level

# Add "ltc" to the ltc_names vector to facilitate the aggregates below
ltc_names <- append(ltc_names, "any_1_plus", 0)

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
  mutate(
    lcaname = match_area(ca2018),
    # Create Clackmannanshire & Stirling as its own LCA
    temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
      "Clackmannanshire & Stirling",
      NA_character_
    )
  ) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name) %>%
  # Create counts for whole health board and Scotland
  group_by(year, hbrescode, age_grp, gender, type, recid, patient_type) %>%
  mutate(hbres_count = sum(count)) %>%
  ungroup() %>%
  group_by(year, age_grp, gender, type, recid, patient_type) %>%
  mutate(scot_count = sum(count)) %>%
  ungroup()

# Create aggregated output using LTC groups, binding the list into a single data frame as above
groups_lca <- ltcs_groups_list %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, recid) %>%
      summarise(across(all_of(ltc_group_names), sum, na.rm = TRUE),
        across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE),
        count = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>%
  mutate(
    lcaname = match_area(ca2018),
    # Create Clackmannanshire & Stirling as its own LCA
    temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
      "Clackmannanshire & Stirling",
      NA_character_
    )
  ) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name) %>%
  group_by(year, hbrescode, age_grp, gender, type, recid, patient_type) %>%
  mutate(hbres_count = sum(count)) %>%
  ungroup() %>%
  group_by(year, age_grp, gender, type, recid, patient_type) %>%
  mutate(scot_count = sum(count)) %>%
  ungroup()

# Create final LCA level output
ltcs_lca_final <- bind_rows(ltcs_lca, groups_lca)

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
  mutate(
    lcaname = match_area(ca2018),
    # Create Clackmannanshire & Stirling as its own LCA
    temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
      "Clackmannanshire & Stirling",
      NA_character_
    )
  ) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)

# Locality level
ltcs_locality <- ltcs_individual_list_locality %>%
  purrr::map_dfr(
    ~ group_by(.x, year, hbrescode, ca2018, gender, age_grp, patient_type, hscp_locality) %>%
      summarise(across(c("cost_total_net"), sum, na.rm = TRUE),
        count = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>%
  mutate(
    lcaname = match_area(ca2018),
    temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
      "Clackmannanshire & Stirling",
      NA_character_
    )
  ) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)


# Section 4 - Population matching ----
# Put LCA, datazone, and locality into a single column for population matching
ltc_file <- bind_rows(ltcs_lca_final, ltcs_datazone, ltcs_locality, .id = "geog_level") %>%
  mutate(pop_match = case_when(
    geog_level == "1" ~ "LCA",
    geog_level == "2" ~ "Datazone",
    geog_level == "3" ~ "Locality"
  )) %>%
  select(-geog_level) %>%
  mutate(
    geography =
      case_when(
        pop_match == "LCA" ~ lcaname,
        pop_match == "Datazone" ~ datazone2011,
        pop_match == "Locality" ~ hscp_locality
      )
  )

write_sav(ltc_file, "LTC_File_check_Bateman.sav", compress = TRUE)



