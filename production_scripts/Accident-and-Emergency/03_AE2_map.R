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
  select(year, `chi` = anon_chi, hbrescode, hbtreatcode, lca, `datazone` = datazone2011, simd, age_group, ltc_num, cost_total_net, 
        episodes, cardiovascular, neurodegenerative, respiratory, other_organs, other_ltcs, no_ltc, 
                  location, destination, ref_source)

 #Create new sub file, calculate number of attendances/episodes by chi number
attendances <- ae_file %>% 
  lazy_dt() %>% 
  group_by(year, chi) %>%
  summarise(sum_episodes = sum(episodes)) %>%
  ungroup() %>% 
  as_tibble() %>% 
  # Group AE number of attendances as with age group above
  mutate(AE_Num = case_when(
    sum_episodes == 1 ~ "1",
    sum_episodes >= 2 & Sum_episodes <= 4 ~ "2-4",
    sum_episodes >= 5 ~ "5+"))

#Match on attendance information to main output file by chi, create new file name, Combined
combined <- left_join(attendances, ae_file, by = c("year", "chi"))

Combined <- Combined %>% mutate(Combined, LTCgroup = "N/A")
AEpart3 <- Combined %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                  LTCgroup, location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(episodes),
                      cost=sum(cost_total_net)) %>%
            ungroup()

AEpart3 <- filter(AEpart3, simd >=1)
count(AEpart3, simd)

AEpart3 <- AEpart3 %>% mutate(individuals = 1)
AEpart4 <- AEpart3 %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, LTCgroup,
                                location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(Attendances),
                      individuals=sum(individuals),
                      cost=sum(cost)) %>%
            ungroup()

Location <- AEpart3 %>% mutate(AEpart3, location = "All")
Location <- Location %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                  LTCgroup, location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(Attendances),
                      cost=sum(cost)) %>%
            ungroup()

Location <- Location %>% mutate(individuals = 1)
Location <- Location %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                  LTCgroup, location, datazone, simd, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AEpart4 <- bind_rows(Location, AEpart4)

Ref_Source <- AEpart3 %>% mutate(AEpart3, Ref_Source = "All")
Ref_Source <- Ref_Source %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                      LTCgroup, location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(Attendances),
                      cost=sum(cost)) %>%
            ungroup()

Ref_Source <- Ref_Source %>% mutate(individuals = 1)
Ref_Source <- Ref_Source %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                  LTCgroup, location, datazone, simd, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AEpart4 <- bind_rows(Ref_Source, AEpart4)

Loc_Refsource <- AEpart3 %>% mutate(AEpart3, location = "All")
Loc_Refsource <- Loc_Refsource %>% mutate(Loc_Refsource, Ref_Source = "All")
Loc_Refsource <- Loc_Refsource %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                            LTCgroup, location, datazone, simd, Ref_Source) %>%
                  summarise(Attendances=sum(Attendances),
                            cost=sum(cost)) %>%
                  ungroup()

Loc_Refsource <- Loc_Refsource %>% mutate(individuals = 1)
Loc_Refsource <- Loc_Refsource %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                      LTCgroup, location, datazone, simd, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AEpart4 <- bind_rows(Loc_Refsource, AEpart4)

Agegroup <- AEpart4 %>% mutate(AEpart4, age_group = "All")
Agegroup <- Agegroup %>% group_by(year, hbrescode, hbtreatcode, lca, age_group, LTC_Num, LTCgroup,
                                  AE_Num, location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(Attendances),
                      individuals=sum(individuals),
                      cost=sum(cost)) %>%
            ungroup()

AEpart4 <- bind_rows(AEpart4, Agegroup)

LTC_Number <- AEpart4 %>% mutate(AEpart4, LTC_Num = "All")
LTC_Number <- LTC_Number %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                LTCgroup, location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(Attendances),
                      individuals=sum(individuals),
                      cost=sum(cost)) %>%
            ungroup()

AEpart4 <- bind_rows(AEpart4, LTC_Number)

AE_Number <- AEpart4 %>% mutate(AEpart4, AE_Num = "All")
AE_Number <- AE_Number %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                    LTCgroup, location, datazone, simd, Ref_Source) %>%
              summarise(Attendances=sum(Attendances),
                        individuals=sum(individuals),
                        cost=sum(cost)) %>%
              ungroup()

AEpart4 <- bind_rows(AEpart4, AE_Number)

Datazone <- AEpart4 %>% mutate(AEpart4, datazone = "All")
Datazone <- Datazone %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                  LTCgroup, location, datazone, simd, Ref_Source) %>%
            summarise(Attendances=sum(Attendances),
                      individuals=sum(individuals),
                      cost=sum(cost)) %>%
            ungroup()

AEpart4 <- bind_rows(AEpart4, Datazone)

#Read in location lookup file and match on to AEpart2
AEpart4 <- rename(AEpart4, Location = location)
Loc_lookup <- get_hosp_lookup(c("Location", "Locname"))
AEpart4 <- left_join(AEpart4, Loc_lookup, by = "Location")

#Apply location recoding adjustments provided
AEpart4$Locname[AEpart4$Location %in% "All"] <- "All"
AEpart4$Locname[AEpart4$Location %in% "G991Z"] <- "Stobhill ACH"

#Rename lca variable for matching and read in lca lookup as new file
AEpart4 <- rename(AEpart4, LCAcode = lca)

#Alter the strings of the LCA code for matching, variable of both files need to be in same format
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 1", "01")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 2", "02")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 3", "03")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 4", "04")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 5", "05")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 6", "06")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 7", "07")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 8", "08")
LCA_lookup <- LCA_lookup %>% mutate_at("LCAcode", str_replace, " 9", "09")

#Match on LCA lookup to Combined output file
AEpart4 <- left_join(AEpart4, LCA_lookup, by = "LCAcode")

#Create LA code from LCA name
AEpart4 <- AEpart4 %>% lcaname_to_code(LCAname)

# Create Clackmannanshire & Stirling data by selecting the two LCAs seperately,
# giving them both the LA Code for Stirling, and aggregating. Then adding that to source_overview
cs <- AEpart4 %>%
  filter(LCAname %in% c("Clackmannanshire", "Stirling")) %>%
  mutate(LCAname = "Clackmannanshire & Stirling")
AEpart4 <- bind_rows(AEpart4, cs)
table(AEpart4$LCAname)

#Create HB Residence from LCA name
AEpart4 <- AEpart4 %>% lcaname_to_hb(LCAname)

#Create HB treatment names base on code provided from location lookup
AEpart4 <- AEpart4 %>% hbcode_to_hb(hbtreatcode)

AEpart4 <- rename(AEpart4, agegroup = age_group)
AEpart4 <- select(AEpart4, -hbrescode, -hbtreatcode)
AEpart4 <- AEpart4 %>% mutate(data = "map")

## Save out dataset
write_sav(AEpart4, here("data", glue("AEpart4.sav")), compress = TRUE)