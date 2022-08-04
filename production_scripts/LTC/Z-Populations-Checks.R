############################################################
## Code name - Populations.R                              ##
## Description - Uses population estimates to make        ##
## groupings for all workbooks                            ##
## Written by: Bateman McBride                            ##
## First written: August 2021                             ##
## Updated:                                               ##
############################################################

## Section 1: population at LCA and Health Board levels

populationyears <- c("2017", "2018", "2019", "2020")
financialyears <- c("2017/18", "2018/19", "2019/20", "2020/21")

# Read in most recent population estimates at LCA level
la_pops <- read_rds("/conf/linkage/output/lookups/Unicode/Populations/Estimates/CA2019_pop_est_1981_2020.rds") %>% 
  # We only need these variables
  select(year, ca2018, age, sex, pop) %>% 
  # Only get the years relevant to our analysis
  filter(year %in% populationyears) %>% 
  # Group the ages
  age_groups_cut(age) %>% 
  # Change sex into categorical variable
  mutate(sex = case_when(
    sex == 1 ~ "M",
    sex == 2 ~ "F"
  )) %>% 
  # Change the year into a string
  mutate(year = as.character(year)) %>% 
  # Remove the age variable as we have groups
  select(-age) %>% 
  # Use ca2011 to get the two-digit lca code, and then use that to determine health board
  ca_to_2digitla(ca2018) %>% twodigitla_to_hb(lca) %>% 
  # Change lca to string
  mutate(lca = as.character(lca)) %>% 
  # Append lca as string so it has a leading zero
  mutate(lca = if_else(
    nchar(lca) == 1, str_c("0", lca), lca
  ))

# Create an 'all ages' grouping, aggregate to that level and add to la_pops
allages <- add_all(la_pops, "age_grp")
la_pops <- bind_rows(la_pops, allages)
# Create an 'all gender' grouping, aggregate to that level and add to la_pops
allgenders <- add_all(la_pops, "sex")
la_pops <- bind_rows(la_pops, allgenders)
# Aggregate whole thing to lca level 
la_pops <- la_pops %>% group_by(year, ca2018, lca, sex, age_grp, hbres) %>% 
  summarise(across(where(is.numeric), sum),
            .groups = "drop")
# Aggregate to HB level
hbtotals <- la_pops %>% 
  group_by(year, sex, age_grp, hbres) %>% 
  summarise(across(where(is.numeric), sum),
            .groups = "drop") %>% 
  rename(hb_population = pop)
# Join the LCA-level populations to the HB level populations. 
la_pops <- left_join(la_pops, hbtotals, by = c("year", "sex", "age_grp", "hbres")) %>% 
  rename(population = pop)

# Tidy up environment
rm(allages, allgenders, hbtotals)

# Turn population year into financial year
la_pops %<>% population_fin_year(year) %>% 
  mutate(geography = match_area(ca2018)) %>% 
  select(-ca2018, -lca)

## Section 2: Populations at datazone level
dz_pops <- read_rds("/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2019.rds") %>%  
  select(-datazone2011name, -(intzone2011:ca2018), -(simd2020v2_rank:simd2016_crime_rank), -total_pop) %>% 
  filter(year %in% populationyears) %>% 
  mutate(year = as.character(year))

dz_pops <- dz_pops %>% 
  mutate(agegroup1 = rowSums(across(age0:age17))) %>% 
  mutate(agegroup2 = rowSums(across(age18:age44))) %>% 
  mutate(agegroup3 = rowSums(across(age45:age64))) %>% 
  mutate(agegroup4 = rowSums(across(age65:age74))) %>% 
  mutate(agegroup5 = rowSums(across(age75:age84))) %>% 
  mutate(agegroup6 = rowSums(across(age85:age90plus))) %>% 
  select(-(age0:age90plus))

dz_pops %<>% gather("age_grp", "population", agegroup1:agegroup6) %>% 
  mutate(age_grp = case_when(
    age_grp == "agegroup1" ~ "<18",
    age_grp == "agegroup2" ~ "18-44",
    age_grp == "agegroup3" ~ "45-64",
    age_grp == "agegroup4" ~ "65-74",
    age_grp == "agegroup5" ~ "75-84",
    age_grp == "agegroup6" ~ "85+"
  ))

# Create an 'all ages' grouping, aggregate to that level and add to dz_pops
allages <- add_all(dz_pops, "age_grp")
dz_pops <- bind_rows(dz_pops, allages)
# Create an 'all gender' grouping, aggregate to that level and add to dz_pops
allgenders <- add_all(dz_pops, "sex")
dz_pops <- bind_rows(dz_pops, allgenders)

rm(allages, allgenders)

# Convert to financial year
dz_pops <- population_fin_year(dz_pops, year) %>% 
  rename(geography = datazone2011) %>% 
  select(-ca2011)

## Section 3: Locality populations

dz_lookup <- get_dz_lookup("20200825", c("datazone2011", "hscp_locality"))
locality_pops <- left_join(dz_pops, dz_lookup, by = c("geography" = "datazone2011"))

locality_pops <- locality_pops %>% 
  group_by(hscp_locality, sex, age_grp, year) %>% 
  summarise(across(population, sum)) %>% 
  rename(geography = hscp_locality)

rm(dz_lookup)

# Put each set of pops
all_pops <- list(
  LCA = la_pops, 
  Datazone = dz_pops, 
  Locality = locality_pops)
all_pops <- bind_rows(all_pops, .id = "pop_match") %>% 
  rename(gender = sex)

write_sav(all_pops, "population_lookup.sav")
rm(dz_pops, la_pops, locality_pops)
