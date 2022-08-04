############################################################
## Code name - NRAC.R                                     ##
## Description - Part of the code for the Hospital        ##
## Expenditure and Activity workbook                      ##
## Written by: Bateman McBride                            ##
## First written: October 2021                            ##
## Updated:                                               ##
############################################################

###############################
# Section 1 - Practice Lookup #
###############################

# We need to have a reference of practice code to name and lca
# Read in the National Reference File for GP Practices
practice_lookup <- read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/GP_CHP.sav") %>%
  clean_names() %>%
  # We only need these three variables
  select(chp_name, address1, gp_practice_code) %>%
  # Format the lca names to standard
  mutate(
    chp_name = str_replace(chp_name, " Community Health Partnership", ""),
    chp_name = str_replace(chp_name, " Community Health & Care Partnership", ""),
    chp_name = str_replace(chp_name, " Health and Social Care Partnership", ""),
    chp_name = str_replace(chp_name, " Community Health & Social Care Partnership", "")
  ) %>%
  mutate(chp_name = case_when(
    chp_name == "Dunfermline & West Fife" | chp_name == "Glenrothes & North East Fife" | chp_name == "Kirkcaldy & Levenmouth" ~ "Fife",
    str_detect(chp_name, "Glasgow") ~ "Glasgow City",
    str_detect(chp_name, "Edinburgh") ~ "City of Edinburgh",
    str_detect(chp_name, "Highland") ~ "Highland",
    TRUE ~ chp_name
  )) %>%
  # Rename the variables to what we will expect later
  rename(prac = gp_practice_code, lcaname = chp_name, practice_name = address1)
# Here we filter out any repeated practices
practice_lookup <- practice_lookup %>%
  unique(practice_lookup$prac, incomparables = FALSE) %>%
  # Coerce prac to string as this is what we use in the workbook
  mutate(prac = as.character(prac))

###############################
# Section 2 - NRAC lookup     #
###############################

# Read in four years' worth of the NRAC population model
# If the model has not been produced for a year, we use a repeat of the most recent year
nrac_master <- list(
  "1718" = read_sav("/conf/hscdiip/08-Models/NRAC CHP model/model construction/201718 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav"),
  "1819" = read_sav("/conf/hscdiip/08-Models/NRAC CHP model/model construction/201819 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav"),
  "1920" = read_sav("/conf/hscdiip/08-Models/NRAC CHP model/model construction/201819 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav"),
  "2021" = read_sav("/conf/hscdiip/08-Models/NRAC CHP model/model construction/201819 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav")
)

# Wrangling of each NRAC model
nrac_prac <- nrac_master %>% purrr::map(~ rename(.x, prac = gpprac) %>%
  # Join on our practice_lookup to get the LCA and practice name
  left_join(., practice_lookup, by = "prac") %>%
  # Recode age groups
  mutate(agegroup = case_when(
    age == "0-1" | age == "2-4" | age == "5-9" | age == "10-14" | age == "15-17" ~ "0-17",
    age == "18-19" | age == "20-24" | age == "25-29" | age == "30-34" | age == "35-39" |
      age == "40-44" ~ "18-44",
    age == "45-49" | age == "50-54" | age == "55-59" | age == "60-64" ~ "45-64",
    age == "65-69" | age == "70-74" ~ "65-74",
    age == "75-79" | age == "80-84" ~ "75-84",
    age == "85-89" | age == "90+" ~ "85+"
  )) %>%
  # We filter out the age 'All' as it doesn't split by gender or care type and we need it to
  # Additionally, we only need the totals for these three care groups
  filter(age != "All" &
    (caregrp == "Acute" | caregrp == "HCHS" | caregrp == "Mental Health & Learning Difficulties")) %>%
  # Create our own 'All Ages' category
  mutate(temp_age = "All Ages") %>%
  pivot_longer(c(agegroup, temp_age), values_to = "agegroup") %>%
  select(-name) %>%
  mutate(caregrp = case_when(caregrp == "Acute" ~ "acute",
                             caregrp == "HCHS" ~ "hchs",
                             caregrp == "Mental Health & Learning Difficulties" ~ "mhld")) %>%
# Aggregate each NRAC lookup to practice level at the lowest, this will serve as our lookup
# for GP-level analysis
  group_by(lcaname, agegroup, prac, caregrp, practice_name) %>%
  summarise(popn = sum(pop)))

# Create a lookup for lca-level analysis
nrac_lca <- nrac_prac %>% purrr::map(
  # Make C&S into an lca
  ~ mutate(.x, temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
    "Clackmannanshire & Stirling",
    NA_character_
  )) %>%
    pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
    select(-name) %>%
    # Aggregate to LCA level
    group_by(lcaname, agegroup, caregrp) %>%
    summarise(popn = sum(popn))
)

# Create a lookup for Health Board level analysis
nrac_hb <- nrac_prac %>% purrr::map(
  # Use LCA names to get Health Board in 'NHS X' format
  ~ lcaname_to_hb(.x, lcaname) %>%
    group_by(hb, agegroup, caregrp) %>%
    summarise(popn = sum(popn))
)

rm(nrac_master)


