############################################################
## Code name - HEA - Return of the Data.R                 ##
## Description - Part of the code for the Hospital        ##
## Expenditure and Activity workbook                      ##
## Written by: Bateman McBride                            ##
## First written: October 2021                            ##
## Updated:                                               ##
############################################################

# Section 1 - LCA-level dataset           #
###########################################

# Firstly, we want to aggregate the yearstay (bed days), cost and episodes across the group_by variables
lca_level <- hea_master %>% 
  # We don't need this specialty group as the specialties included in the group are elsewhere
  filter(specialty_grp != "All MHLD") %>% 
  lazy_dt() %>% 
  group_by(across(hea_constants[["key_vars_lca"]])) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            .groups = "keep") %>% 
  ungroup() %>% 
  as_tibble()

# Join the lca_level data with the hosp_services lookup to get the hospital name and type
lca_level <- left_join(lca_level, get_hospital_services()) %>% 
  
  # Standard list of location names that never match on for some reason
  missing_locs() %>% 
  
  # Use the location code to determine hospital type (NHS, Private, etc.)
  hospital_type() %>% 
  
  # Get the Board the hospital is located in
  where_is_hospital(locationcode = location, hbcode = hbtreatcode) %>% 
  
  # Get the Board that the patient was treated in, adjust name to end in 'Region'
  mutate(treated_hb_region = match_area(hbtreatcode)) %>%
  mutate(treated_hb_region = if_else(!(treated_hb_region %in% hea_constants[["health_boards"]]), 
                                     "Other Non-Scottish Residents",
                                     str_replace(treated_hb_region, " and ", " & ")
  )) %>%
  mutate(treated_hb_region = if_else(treated_hb_region %in% hea_constants[["health_boards"]],
                                    str_c(treated_hb_region, " Region"), treated_hb_region)) %>% 
  
  # Create flags for when a specialty is delegated, when it belongs to a group, or when it is part of all specialties
  # These constants are defined in GeneralEnvironment.R
  mutate(flag_delegated = if_else(
    specname %in% hea_constants[["delegated_specs"]] & specialty_grp != "All MHLD", TRUE, FALSE),
    flag_all = if_else(
      specname %in% hea_constants[["all_spec_names"]], TRUE, FALSE),
    flag_groups = if_else(
      specialty_grp != specname, TRUE, FALSE))
    
    
# We want to create an 'all' group in both specialty_grp and specname, so create this all_specs df
all_specs <- lca_level %>% mutate(specialty_grp = "All", specname = "All",
                                  flag_delegated = FALSE) %>% 
  lazy_dt() %>% 
  group_by(across(hea_constants[["key_vars_lca"]])) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_delegated:flag_groups, any, na.rm = TRUE),
            .groups = "keep") %>% 
  ungroup() %>% 
  as_tibble()

lca_level <- bind_rows(lca_level, all_specs)
rm(all_specs)

# Create a group of 'All Delegated' specialties
delegated <- lca_level %>% filter(flag_delegated == TRUE) %>% 
  mutate(specialty_grp = "All Delegated",
         specname = "All Delegated",
         flag_all = FALSE,
         flag_groups = FALSE) %>% 
  lazy_dt() %>% 
  group_by(across(hea_constants[["key_vars_lca"]])) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_delegated:flag_groups, any, na.rm = TRUE),
            .groups = "keep") %>% 
  ungroup() %>% 
  as_tibble()

lca_level <- bind_rows(lca_level, delegated)
rm(delegated)

# Create an 'all ages' group
all_ages <- lca_level %>% 
  mutate(age_grp = "All Ages") %>% 
  lazy_dt() %>% 
  group_by(across(hea_constants[["key_vars_lca"]])) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_delegated:flag_groups, any, na.rm = TRUE),
            .groups = "keep") %>% 
  ungroup() %>% 
  as_tibble()

lca_level <- bind_rows(lca_level, all_ages)

rm(all_ages)

# Adding NRAC populations
lca_level <- lca_level %>% mutate(caretype = case_when(
  specialty_grp == "Child & Adolescent Psychiatry - Grp" | specialty_grp == "General Psychiatry - Grp" |
    specialty_grp == "Learning Disability" | specialty_grp == "Psychiatry of Old Age" ~ "mhld",
  specialty_grp == "All" | specialty_grp == "All Delegated" ~ "hchs",
  TRUE ~ "acute"
))

lca_level <- left_join(lca_level, nrac_lca[[finyears]], 
                       by = c("lcaname", "age_grp" = "agegroup", "caretype" = "caregrp")) %>% 
  security_codes(.)

write_sav(lca_level, "Hosp R Test.sav")
# rm(lca_level)

###########################################

# Section 2 - GP-level dataset            #
###########################################
prac_lca <- practice_lookup %>% rename(lca_practice = lcaname) %>% mutate(prac = as.integer(prac))

gp_level <- hea_master %>% 
  # Search gpprac for any closed/marged practices and recode these into 'prac'
  closed_practices(pracvar = gpprac) %>% 
  # Match on the prac_lca lookup for the local authorities the practices lie in
  left_join(., prac_lca, by = c("prac")) %>% 
  # For the C&S rows, change their lca_practice to C&S
  mutate(lca_practice = if_else(lcaname == "Clackmannanshire & Stirling", "Clackmannanshire & Stirling", lca_practice)) %>% 
  # This flag tells us whether or not the lca of treatment was the lca the GP is located in
  mutate(flag_origin = if_else(lcaname == lca_practice, FALSE, TRUE),
         # Some Lanarkshire GP practices are recorded under GG&C Board, so we want to exclude these at GP level analysis
         flag_lank = if_else((lcaname == "South Lanarkshire" | lcaname == "North Lanarkshire") & 
                               str_sub(gpprac, 1, 1) == "4", TRUE, FALSE),
         flag_excluded = if_else((lcaname == "South Lanarkshire" | lcaname == "North Lanarkshire") & 
                                   hb_region_format != "Lanarkshire Region", TRUE, FALSE),
         # Flag for the delegated specialties
         flag_delegated = if_else(
           specname %in% hea_constants[["delegated_specs"]] & specialty_grp != "All MHLD", TRUE, FALSE),
         # Flag for group specialties
         flag_groups = if_else(
           specialty_grp != specname, TRUE, FALSE)) %>% 
  
  # Aggregate to practice-level
  group_by(across(hea_constants[["key_vars_gp"]])) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_origin:flag_groups, any, na.rm = TRUE),
            .groups = "keep")

# Create an 'all' specialties grouping
all_specs <- gp_level %>% mutate(specialty_grp = "All", specname = "All",
                                 flag_all = TRUE,
                                 flag_groups = FALSE,
                                 flag_delegated = FALSE) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_origin:flag_groups, any, na.rm = TRUE),
            .groups = "keep")
gp_level <- bind_rows(gp_level, all_specs)
rm(all_specs)
  
# Create a group of 'All Delegated' specialties
delegated <- gp_level %>% filter(flag_delegated == TRUE) %>% 
  mutate(specialty_grp = "All Delegated",
         specname = "All Delegated",
         flag_all = FALSE,
         flag_groups = FALSE) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_origin:flag_groups, any, na.rm = TRUE),
            .groups = "keep")
gp_level <- bind_rows(gp_level, delegated)
rm(delegated)

# Create an 'all ages' group
all_ages <- gp_level %>% 
  mutate(age_grp = "All Ages") %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_origin:flag_groups, any, na.rm = TRUE),
            .groups = "keep")
gp_level <- bind_rows(gp_level, all_ages)
rm(all_ages)

gp_level <- gp_level %>% mutate(caretype = case_when(
  specialty_grp == "Child & Adolescent Psychiatry - Grp" | specialty_grp == "General Psychiatry - Grp" |
    specialty_grp == "Learning Disability" | specialty_grp == "Psychiatry of Old Age" ~ "mhld",
  specialty_grp == "All" | specialty_grp == "All Delegated" ~ "hchs",
  TRUE ~ "acute"
)) %>% 
  ungroup() %>% 
  mutate(prac = as.character(prac))

gp_level <- left_join(gp_level, nrac_prac[[finyears]], 
                      by = c("prac", "age_grp" = "agegroup", "caretype" = "caregrp", 
                             "practice_name", "lca_practice" = "lcaname")) %>% 
  security_codes(.)

write_sav(gp_level, "GP-Test.sav")

###########################################

# Section 3 - Board-level dataset         #
###########################################

board_level <- hea_master %>% 
  group_by(across(hea_constants[["key_vars_board"]])) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            .groups = "keep") %>% 
  mutate(flag_delegated = if_else(
    specname %in% hea_constants[["delegated_specs"]] & specialty_grp != "All MHLD", TRUE, FALSE),
    flag_all = if_else(
      specname %in% hea_constants[["all_spec_names"]], TRUE, FALSE),
    flag_groups = if_else(
      specialty_grp != specname, TRUE, FALSE))

all_specs <- board_level %>% mutate(specialty_grp = "All", specname = "All",
                                  flag_delegated = FALSE) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_delegated:flag_groups, any, na.rm = TRUE),
            .groups = "keep")
board_level <- bind_rows(board_level, all_specs)
rm(all_specs)

delegated <- board_level %>% filter(flag_delegated == TRUE) %>% 
  mutate(specialty_grp = "All Delegated",
         specname = "All Delegated",
         flag_all = FALSE,
         flag_groups = FALSE) %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_delegated:flag_groups, any, na.rm = TRUE),
            .groups = "keep")
board_level <- bind_rows(board_level, delegated)
rm(delegated)

# Create an 'all ages' group
all_ages <- board_level %>% 
  mutate(age_grp = "All Ages") %>% 
  summarise(across(c("yearstay", "cost_total_net", "episodes"), sum, na.rm = TRUE),
            across(flag_delegated:flag_groups, any, na.rm = TRUE),
            .groups = "keep")
board_level <- bind_rows(board_level, all_ages) %>% 
  ungroup()
rm(all_ages)

# Adding NRAC populations
board_level <- board_level %>% mutate(caretype = case_when(
  specialty_grp == "Child & Adolescent Psychiatry - Grp" | specialty_grp == "General Psychiatry - Grp" |
    specialty_grp == "Learning Disability" | specialty_grp == "Psychiatry of Old Age" ~ "mhld",
  specialty_grp == "All" | specialty_grp == "All Delegated" ~ "hchs",
  TRUE ~ "acute"
))

board_level <- left_join(board_level, nrac_hb[[finyears]], 
                       by = c("hbresname" = "hb", "age_grp" = "agegroup", "caretype" = "caregrp"))

write_sav(board_level, "Board R Test.sav")
