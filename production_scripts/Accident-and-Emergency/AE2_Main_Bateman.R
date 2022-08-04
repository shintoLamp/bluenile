### 1 - Setup environment and load functions ----
source(here::here("code", "00_setup-environment.R"))

#Filter out variables to be used from SLF
required_vars <- c("year", "recid", "anon_chi", "age", "hbrescode", "hbtreatcode", "location",
                   "refsource", "ae_arrivalmode", "ae_disdest", "cost_total_net", "lca", "datazone2011",
                   "simd2020v2_hb2019_quintile", "arth", "asthma", "atrialfib", "cancer", "cvd", "liver",
                   "copd", "dementia", "diabetes", "epilepsy", "chd", "hefailure", "ms", "parkinsons",
                   "refailure", "congen", "bloodbfo", "endomet", "digestive")

ae_file <- read_slf_episode("1819", columns = required_vars, recids = "AE2") %>% 
  # Change year to "20XXYY" format
  filter(lca != "" & refsource != "") %>% 
  mutate(year = str_c("20", str_sub(year)),
         # Change ltc names to be logical for faster processing
         across(all_of(ltc_names), as.logical),
         # New variable ltc, TRUE when any LTC is TRUE
         ltc = reduce(select(., ltc_names), `|`),
         # New variable num_ltc, sum of any LTCs that are TRUE
         num_ltc = reduce(select(., ltc_names), `+`),
         # New variable ltc_num, splits num_ltc into three groups
         ltc_num = cut(num_ltc, breaks = c(-1, 0, 1, max(num_ltc)), labels = c("0", "1", "2+")),
         # LTC groupings, each one is TRUE when one of its component parts is TRUE
         cardiovascular = reduce(select(., c("atrialfib", "chd", "cvd", "hefailure")), `|`),
         neurodegenerative = reduce(select(., c("dementia", "ms", "parkinsons")), `|`),
         respiratory = reduce(select(., c("asthma", "copd")), `|`),
         other_organs = reduce(select(., c("liver", "refailure")), `|`),
         other_ltcs = reduce(select(., c("arth", "cancer", "diabetes", "epilepsy")), `|`),
         no_ltc = !ltc,
         # Recode ae_disdest into destination
         destination = case_when(
           ae_disdest == "00" ~ "Death",
           ae_disdest %in% c("01", "01A", "01B") ~ "Private Residence",
           ae_disdest %in% c("02", "02A", "02B") ~ "Residential Institution",
           ae_disdest %in% c("03", "03A", "03B", "03C", "03D", "03Z", "06", "98", "99") ~ "Other",
           ae_disdest %in% c("04", "04A", "04B", "04C", "04D", "04Z") ~ "Admission",
           ae_disdest %in% c("05", "05A", "05B", "05C", "05D", "05E", "05F", "05G", "05H", "05Z") ~ "Transfer",
           TRUE ~ "Unknown"
         ),
         ref_source = case_when(
           refsource %in% c("01", "01A", "01B") ~ "Self referral",
           refsource %in% c("02", "02B", "02D", "02E", "02F", "02G", "02H", "05", "05A", "05B", "05C", "05D") ~ "Other",
           refsource %in% c("02A", "02J") ~ "GP referral",
           refsource == "02C" ~ "Ambulance",
           refsource %in% c("03", "03A", "03B", "03C", "03D") ~ "Local Authority",
           refsource == "04" ~  "Private professional/agency/organisation",
           TRUE ~ "Not Known")) %>% 
  # Quick recode for ambulance arrivals
  mutate(ref_source = if_else(ae_arrivalmode %in% c("01", "02", "03") & refsource %in% c("01", "01A", "01B"),
                              "Ambulance", ref_source)) %>% 
  # Recode age into groups
  standard_age_groups(age) %>% 
  rename(simd = simd2020v2_hb2019_quintile) %>% 
  # Select out required variables
  select(year, anon_chi, hbrescode, hbtreatcode, lca, datazone2011, simd, age_group, ltc_num, cost_total_net, 
         cardiovascular, neurodegenerative, respiratory, other_organs, other_ltcs, no_ltc, 
         location, destination, ref_source) %>% 
  # Group by year and chi number to determine number of episodes (attendances) per individual
  lazy_dt() %>% 
  group_by(year, anon_chi) %>%
  # Make ae_num, based on how many episodes an individual had
  mutate(ae_num = case_when(
                    n() == 1 ~ "1",
                    n() >= 2 & n() <= 4 ~ "2-4",
                    n() >= 5 ~ "5+")) %>% 
         # Make individual_flag, which is 1 when it's the first instance of a chi in year, and 0 otherwise 
         # individual_flag = c(1, rep(0, n()-1))) %>% 
  ungroup() %>% 
  as_tibble() %>% 
  left_join(., get_dz_lookup("20200825", c("datazone2011", "ca2011", "ca2019name", "hb2019name")),
                   by = "datazone2011")

#Rename LTC group variable to match which group has been selected out
#Aggregate by required variables and sum episodes and total net cost
ltc_groups <- list(
  Cardiovascular = ae_file %>% filter(cardiovascular == TRUE),
  Neurodegenerative = ae_file %>% filter(neurodegenerative == TRUE),
  Respiratory = ae_file %>% filter(respiratory == TRUE),
  Other_Organs = ae_file %>% filter(other_organs == TRUE),
  Other_LTCs = ae_file %>% filter(other_ltcs == TRUE),
  No_LTC = ae_file %>% filter(., no_ltc == TRUE),
  All = ae_file
)

ae_part1 <- ltc_groups %>%
  purrr::map_dfr(~ lazy_dt(.x) %>%
    group_by(
      year, anon_chi, hbtreatcode, lca, ae_num, destination, age_group,
      location, ref_source, hb2019name, ca2019name, ca2011
    ) %>%
    summarise(
      attendances = n(),
      cost = sum(cost_total_net, na.rm = T)
    ) %>%
    ungroup() %>%
    as_tibble(),
  .id = "ltcgroup"
  )

# Groupings for all
# We need 'all' values for destination, location, ref_source, hbtreatcode, age_group, ae_num, and gender
# This is done by pivoting longer for each of the above variables and then aggregating at the end
all_groups <- ae_part1 %>% 
  # Destination
  mutate(dest_temp = "All") %>% 
  pivot_longer(cols = c("destination", "dest_temp"), values_to = "destination", values_drop_na = T) %>% 
  select(-name) %>% 
  # Location
  mutate(loc_temp = "All") %>% 
  pivot_longer(cols = c("location", "loc_temp"), values_to = "location", values_drop_na = T) %>% 
  select(-name) %>% 
  # Referral Source
  mutate(ref_temp = "All") %>% 
  pivot_longer(cols = c("ref_source", "ref_temp"), values_to = "ref_source", values_drop_na = T) %>% 
  select(-name) %>% 
  # Health board of treatment
  mutate(hbtreat_temp = "All") %>% 
  pivot_longer(cols = c("hbtreatcode", "hbtreat_temp"), values_to = "hbtreatcode", values_drop_na = T) %>% 
  select(-name) %>% 
  # Age group
  mutate(age_temp = "All") %>% 
  pivot_longer(cols = c("age_group", "age_temp"), values_to = "age_group", values_drop_na = T) %>% 
  select(-name) %>% 
  # Number of attendances
  mutate(ae_num_temp = "All") %>% 
  pivot_longer(cols = c("ae_num", "ae_num_temp"), values_to = "ae_num", values_drop_na = T) %>% 
  select(-name) %>% 
  # Aggregate the final set
  lazy_dt() %>% 
  group_by(year, anon_chi, hbtreatcode, lca, ae_num, destination, age_group,
           ltcgroup, location, ref_source, hb2019name, ca2019name, ca2011) %>%
  summarise(across(c("attendances", "cost"), sum, na.rm = T)) %>%
  ungroup() %>% 
  as_tibble()

# Create flag for individuals and aggregate, removing chi variable
ae_part2 <- all_groups %>% 
  mutate(individuals = 1) %>% 
  lazy_dt() %>% 
  group_by(year, hbtreatcode, ae_num, destination, age_group,
           ltcgroup, location, ref_source, hb2019name, ca2019name, ca2011) %>%
  summarise(attendances = sum(attendances),
            individuals = sum(individuals),
            cost = sum(cost)) %>%
  ungroup() %>% 
  as_tibble() %>% 
  mutate(sex = 3,
         datazone = "All") %>% 
  # Match on population lookup by lca, sex and age group
  left_join(., pop, by = c("year", "ca2011", "sex", c("age_group" = "agegroup"))) %>% 
  #Remove variables no longer required 
  select(-sex, -hbres_population) %>% 
  
  # Create new aggregate file which will now calculate Scotland level attendances, individuals and cost
  lazy_dt() %>% 
  group_by(year, hbtreatcode, age_group, ae_num, ltcgroup, destination, 
           ref_source, location, datazone) %>%
  mutate(scot_attendances = sum(attendances),
         scot_individuals = sum(individuals),
         scot_cost = sum(cost)) %>%
  ungroup() %>% 
  as_tibble() %>% 
  
  #Rename variables for location lookup file and match on
  rename(discharge_dest = destination) %>% 
  left_join(., get_hosp_lookup(c("Location", "Locname", "Postcode")) %>% clean_names(), by = "location") %>% 
  # Apply location recoding adjustments provided
  mutate(locname = case_when(
    location == "All" ~ "All",
    location == "G991Z" ~ "Stobhill ACH",
    TRUE ~ locname),
    postcode = if_else(location == "G991Z", "G21 3UW", postcode)) %>% 
  
  # Pivot longer to get C&S activity
  mutate(temp_lca = if_else(ca2019name %in% c("Clackmannanshire", "Stirling"),
                            "Clackmannanshire & Stirling",
                            NA_character_)) %>% 
  pivot_longer(cols = c("ca2019name", "temp_lca"), values_to = "ca2019name", values_drop_na = T) %>% 
  select(-name) %>% 

  # Create HB treatment names base on code provided from location lookup
  lcaname_to_hb(ca2019name) %>% 
  hbcode_to_hb(hbtreatcode) %>% 
  select(-hbtreatcode)

# Create new sub file which calculate outside Health Board totals
outside_hb_totals <- ae_part2 %>% 
  filter(Hb_Treatment != Hbres & Hb_Treatment != "All" &  location != "All") %>% 
  mutate(location = "Other",
         postcode = "Other",
         locname = "Hospital outside Health Board",
         Hb_Treatment = Hbres) %>% 
  relocate(c("datazone", "lca"), .before = "attendances")  %>% 
  relocate(c("population", "scot_population"), .after = "scot_cost") %>% 
  lazy_dt() %>% 
  group_by(Hbres, Hb_Treatment, ca2011, ae_num, discharge_dest, age_group, ltcgroup,
           location, ref_source, postcode, locname, year, ca2019name, datazone) %>% 
  summarise(across(attendances:scot_cost, sum, na.rm = T),
            across(population:scot_population, max, na.rm = T)) %>% 
  ungroup() %>% 
  as_tibble() %>% 
  rename(lca_name = ca2019name,
         la_code = ca2011)

#Combine outside HB totals with AEpart2 to create final output file
final <- bind_rows(ae_part2, outside_hb_totals) %>% 
  mutate(data = "Data")

## Save out dataset
write_sav(final, here("data", glue("BM-AEprogram.sav")), compress = TRUE)
