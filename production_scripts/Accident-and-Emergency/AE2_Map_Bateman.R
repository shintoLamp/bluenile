### 1 - Setup environment and load functions ----
source(here::here("code", "00_setup-environment.R"))

#Clear environment before running script
#Filter out variables to be used from SLF
required_vars <- c("year", "recid", "anon_chi", "gender", "age", "hbrescode", "hbtreatcode", "location",
                   "refsource", "ae_arrivalmode", "ae_disdest", "cost_total_net", "lca", "datazone2011",
                   "simd2020v2_hb2019_quintile", "arth", "asthma", "atrialfib", "cancer", "cvd", "liver",
                   "copd", "dementia", "diabetes", "epilepsy", "chd", "hefailure", "ms", "parkinsons",
                   "refailure", "congen", "bloodbfo", "endomet", "digestive")

ae_file <- read_slf_episode(finyear, columns = required_vars, recids = "AE2") %>% 
  filter(!is_missing(lca) & !is_missing(refsource)) %>% 
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
         # Recode destinations
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
  mutate(ref_source = if_else(ae_arrivalmode %in% c("01", "02", "03") & refsource %in% c("01", "01A", "01B"),
                              "Ambulance", ref_source),
         episodes = 1) %>% 
  # Create age group variable, frequency count to ensure matching with SPSS output
  standard_age_groups(age) %>% 
  rename(simd = simd2020v2_hb2019_quintile) %>% 
  select(year, `chi` = anon_chi, hbrescode, hbtreatcode, lca, 
         `datazone` = datazone2011, simd, age_group, ltc_num, cost_total_net, 
         episodes, cardiovascular, neurodegenerative, respiratory, other_organs, other_ltcs, no_ltc, 
         location, destination, ref_source, episodes)

 #Create new sub file, calculate number of attendances/episodes by chi number
attendances <- ae_file %>% 
  lazy_dt() %>% 
  group_by(year, chi) %>%
  summarise(sum_episodes = sum(episodes)) %>%
  ungroup() %>% 
  as_tibble() %>% 
  # Group AE number of attendances as with age group above
  mutate(ae_num = case_when(
    sum_episodes == 1 ~ "1",
    sum_episodes >= 2 & sum_episodes <= 4 ~ "2-4",
    sum_episodes >= 5 ~ "5+"))

# Match on attendance information to main output file by chi
ae_part3 <- left_join(attendances, ae_file, by = c("year", "chi")) %>%
  # No need for LTC groups in the mapping data
  mutate(ltcgroup = "N/A") %>%
  filter(simd >= 1) %>%
  lazy_dt() %>%
  # Aggregate attendances at chi-level
  group_by(
    year, chi, hbrescode, hbtreatcode, lca,  ae_num, age_group, ltc_num,
    ltcgroup, location, datazone, simd, ref_source
  ) %>%
  summarise(
    attendances = sum(episodes, na.rm = TRUE),
    cost = sum(cost_total_net, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  as_tibble() %>%
  # Add a counter for individuals
  mutate(individuals = 1)

# Part 4 aggregates out of chi level, and sums individuals
ae_part4 <- ae_part3 %>%
  lazy_dt() %>%
  group_by(
    year, hbrescode, hbtreatcode, lca,  ae_num, age_group, ltc_num, ltcgroup,
    location, datazone, simd, ref_source
  ) %>%
  summarise(across(c("attendances", "individuals", "cost"), sum)) %>%
  ungroup() %>%
  as_tibble()

# This function allows the adding of 'all' groups, based on the variables you give it
all_groups_chi_start <- function(df_chi, vars) {
  return <- df_chi %>% 
    mutate(across({{vars}}, ~ "All")) %>%
    lazy_dt() %>% 
    group_by(
      year, chi, hbrescode, hbtreatcode, lca,  ae_num, age_group, ltc_num, ltcgroup,
      location, datazone, simd, ref_source) %>% 
    summarise(across(c("attendances", "cost"), sum, na.rm = T)) %>% 
    ungroup() %>% 
    as_tibble() %>% 
    mutate(individuals = 1) %>% 
    lazy_dt() %>%
    group_by(year, hbrescode, hbtreatcode, lca,  ae_num, age_group, ltc_num, ltcgroup,
             location, datazone, simd, ref_source) %>%
    summarise(across(c("attendances", "individuals", "cost"), sum)) %>%
    ungroup() %>%
    as_tibble()
  
  return(return)
}

all_groups_lca_start <- function(df_lca, vars) {
  return <- df_lca %>% 
    mutate(across({{vars}}, ~ "All")) %>%
    lazy_dt() %>%
    group_by(year, hbrescode, hbtreatcode, lca,  ae_num, age_group, ltc_num, ltcgroup,
             location, datazone, simd, ref_source) %>%
    summarise(across(c("attendances", "individuals", "cost"), sum)) %>%
    ungroup() %>%
    as_tibble()
}

# Bind the lca-level aggregate with each one for all groups
# ae_part3 is used for this aggregate because we want to start at chi-level
# and then apply all groupings. This is to preserve accurate individual counts
ae_part4 <- bind_rows(
  ae_part4,
  all_groups_chi_start(ae_part3, c("location")),
  all_groups_chi_start(ae_part3, c("ref_source")),
  all_groups_chi_start(ae_part3, c("location", "ref_source"))
)

ae_part5 <- bind_rows(
  ae_part4,
  all_groups_lca_start(ae_part4, c("ae_num")),
  all_groups_lca_start(ae_part4, c("age_group")),
  all_groups_lca_start(ae_part4, c("ltc_num")),
  all_groups_lca_start(ae_part4, c("datazone"))
) %>% 
  # Get the hospital names
  left_join(., get_hosp_lookup(c("Location", "Locname")) %>% clean_names(),
            by = "location") %>% 
  # Recode some that have been issues in the past
  mutate(locname = case_when(
    location == "All" ~ "All",
    location == "G991Z" ~ "Stobhill ACH",
    TRUE ~ locname)) %>% 
  # Match on to get lca codes and names
  left_join(., get_dz_lookup("20220630", c("datazone2011", "ca2011", "ca2019name", "hb2019name")),
            by = c("datazone" = "datazone2011"))

# Create Clackmannanshire & Stirling data
cs <- ae_part5 %>%
  filter(ca2019name %in% c("Clackmannanshire", "Stirling")) %>%
  mutate(ca2019name = "Clackmannanshire & Stirling")

# Final output
ae_part6 <- bind_rows(ae_part5, cs) %>% 
  # Create HB Residence from hbrescode, same with HB of treatment
  mutate(hbres = match_area(hbrescode),
         hb_treatment = match_area(hbtreatcode),
         data = "map") %>% 
  rename(agegroup = age_group) %>% 
  select(-hbrescode, -hbtreatcode)

## Save out dataset
write_sav(ae_part6, "data/BM-AEpart4.sav", compress = TRUE)
