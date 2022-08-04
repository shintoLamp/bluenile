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
  standard_age_groups(age) %>% 
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
  left_join(., get_dz_lookup("20220630", c("datazone2011", "hscp_locality")), by = "datazone2011") %>% 
  mutate(hscp_locality = replace_na(hscp_locality, "No Locality Information"))

#Create new sub file, calculate number of attendances/episodes by chi number
attendances <- ae_file %>% 
  lazy_dt() %>% 
  group_by(year, anon_chi) %>%
  summarise(sum_episodes = sum(episodes)) %>%
  ungroup() %>% 
  as_tibble() %>% 
  # Group AE number of attendances as with age group above
  mutate(ae_num = case_when(
    sum_episodes == 1 ~ "1",
    sum_episodes >= 2 & sum_episodes <= 4 ~ "2-4",
    sum_episodes >= 5 ~ "5+"))

ae_part3 <- left_join(ae_file, attendances, by = c("year", "anon_chi")) %>% 
  mutate(ltcgroup = "N/A") %>% 
  lazy_dt() %>% 
  group_by(year, `chi` = anon_chi, hbrescode, hbtreatcode, lca, ae_num, age_group, ltc_num, ltcgroup,
                                location, hscp_locality, ref_source) %>%
  summarise(
    attendances = sum(episodes, na.rm = TRUE),
    cost = sum(cost_total_net, na.rm = TRUE)
  ) %>% 
  ungroup() %>%
  as_tibble()

ae_locality <- ae_part3 %>% mutate(individuals = 1) %>% 
  lazy_dt() %>%
  group_by(
    year, hbrescode, hbtreatcode, lca, ae_num, age_group, ltc_num, ltcgroup,
    location, hscp_locality, ref_source
  ) %>%
  summarise(across(c("attendances", "individuals", "cost"), sum)) %>%
  ungroup() %>%
  as_tibble()

# This function allows the adding of 'all' groups, based on the variables you give it
all_groups_locality_chi <- function(df_chi, vars) {
  return <- df_chi %>% 
    mutate(across({{vars}}, ~ "All")) %>%
    lazy_dt() %>% 
    group_by(
      year, chi, hbrescode, hbtreatcode, lca, ae_num, age_group, ltc_num, ltcgroup,
      location, hscp_locality, ref_source) %>% 
    summarise(across(c("attendances", "cost"), sum, na.rm = T)) %>% 
    ungroup() %>% 
    as_tibble() %>% 
    mutate(individuals = 1) %>% 
    lazy_dt() %>%
    group_by(year, hbrescode, hbtreatcode, lca,  ae_num, age_group, ltc_num, ltcgroup,
             location, hscp_locality, ref_source) %>%
    summarise(across(c("attendances", "individuals", "cost"), sum)) %>%
    ungroup() %>%
    as_tibble()
  
  return(return)
}

all_groups_locality_lca <- function(df_lca, vars) {
  return <- df_lca %>% 
    mutate(across({{vars}}, ~ "All")) %>%
    lazy_dt() %>%
    group_by(year, hbrescode, hbtreatcode, lca, ae_num, age_group, ltc_num, ltcgroup,
             location, hscp_locality, ref_source) %>%
    summarise(across(c("attendances", "individuals", "cost"), sum)) %>%
    ungroup() %>%
    as_tibble()
  return(return)
}

ae_part4 <- bind_rows(
  ae_locality,
  all_groups_locality_chi(ae_part3, c("location")),
  all_groups_locality_chi(ae_part3, c("ref_source")),
  all_groups_locality_chi(ae_part3, c("location", "ref_source"))
)

ae_part5 <- bind_rows(
  ae_part4,
  all_groups_locality_lca(ae_part4, c("ae_num")),
  all_groups_locality_lca(ae_part4, c("age_group")),
  all_groups_locality_lca(ae_part4, c("ltc_num")),
  all_groups_locality_lca(ae_part4, c("hscp_locality"))
) %>% 
  mutate(hscp_locality = if_else(hscp_locality == "All", "Agg", hscp_locality)) %>% 
  # Get the hospital names
  left_join(., get_hosp_lookup(c("Location", "Locname")) %>% clean_names(),
            by = "location") %>% 
  # Recode some that have been issues in the past
  mutate(locname = case_when(
    location == "All" ~ "All",
    location == "G991Z" ~ "Stobhill ACH",
    TRUE ~ locname),
    lca = str_replace(lca, "^0", "")) %>%
  left_join(., lca_lookup_2, 
            by = "lca")

# Create Clackmannanshire & Stirling data by selecting the two LCAs seperately,
# giving them both the LA Code for Stirling, and aggregating. Then adding that to source_overview
cs <- ae_part5 %>%
  filter(LCAname %in% c("Clackmannanshire", "Stirling")) %>%
  mutate(LCAname = "Clackmannanshire & Stirling")

ae_part5 <- bind_rows(ae_part5, cs) %>% 
  # Create HB Residence from LCA name
  mutate(hbres = match_area(hbrescode),
         hb_treatment = match_area(hbtreatcode),
         data = "Loc") %>% 
  rename(agegroup = age_group, locality = hscp_locality) %>% 
  select(-hbrescode, -hbtreatcode)

## Save out dataset
write_sav(ae_part5, "data/BM-AElocality", compress = TRUE)
