### 1 - Setup environment and load functions ----
source(here::here("code", "00_setup-environment.R"))

#Clear environment before running script
#Filter out variables to be used from SLF
required_vars <- c("year", "recid", "anon_chi", "gender", "age", "hbrescode", "hbtreatcode", "location",
                   "refsource", "ae_arrivalmode", "ae_disdest", "cost_total_net", "lca", "datazone2011",
                   "simd2020v2_hb2019_quintile", "arth", "asthma", "atrialfib", "cancer", "cvd", "liver",
                   "copd", "dementia", "diabetes", "epilepsy", "chd", "hefailure", "ms", "parkinsons",
                   "refailure", "congen", "bloodbfo", "endomet", "digestive")
AE_File <- read_slf_episode(finyear, columns = required_vars, recids = "AE2")

AE_File <- AE_File %>% mutate(year = str_c("20", str_sub(year)))

#Rename variables for matching lookup files
AE_File <- rename(AE_File, chi = anon_chi)

#Match on Locality lookup to Combined output file
Locality_lookup <- get_dz_lookup("20200825", c("datazone2011", "hscp_locality"))
AE_File <- left_join(AE_File, Locality_lookup, by = "datazone2011")
AE_File$hscp_locality[is.na(AE_File$hscp_locality)] <- "No Locality Information"
AE_File <- rename(AE_File, HSCPLocality = hscp_locality)

#Create age group variable, frequency count to ensure matching with SPSS output
AE_File <- AE_File %>% standard_age_groups(age)
table(AE_File$age_group)

#Create LTC flag variable, episode with any type of LTC
AE_File <- AE_File %>% mutate(
  LTC = ifelse((cvd == 1)|(copd == 1)|(dementia == 1)|(diabetes == 1)|
                 (chd == 1)|(hefailure == 1)|(refailure == 1)|(epilepsy == 1)|
                 (asthma == 1)|(atrialfib == 1)|(cancer == 1)|(arth == 1)|
                 (parkinsons == 1)|(liver == 1)|(ms == 1), 1, 0)
)
table(AE_File$LTC)

#Create total number of LTCs variable
AE_File <- AE_File %>% mutate(Num_LTC = cvd + copd + dementia + diabetes + chd + hefailure + refailure + 
                                epilepsy + asthma + atrialfib + cancer + arth + parkinsons + liver + ms)

#Subsequent number of LTCs combined into broader groups, similar to age group variable
AE_File <- AE_File %>% mutate(AE_File,
                              LTC_Num = case_when(
                                Num_LTC == 0 ~ "0",
                                Num_LTC == 1 ~ "1",
                                Num_LTC >= 2 ~ "2+")
)

#Combine LTCs into groups as defined by lookup files, new variable for each grouping
AE_File <- AE_File %>% mutate(
  Cardiovascular = if_else((atrialfib == 1)|(chd == 1)|(cvd == 1)|(hefailure == 1), 1, 0)
)

#Neurodegenerative grouping
AE_File <- AE_File %>% mutate(
  Neurodegenerative = if_else((dementia == 1)|(ms == 1)|(parkinsons == 1), 1, 0)
)

#Respiratory grouping
AE_File <- AE_File %>% mutate(
  Respiratory = if_else((asthma == 1)|(copd == 1), 1, 0)
)

#Other organs grouping
AE_File <- AE_File %>% mutate(
  Other_Organs = if_else((liver == 1)|(refailure == 1), 1, 0)
)

#Other LTCs grouping
AE_File <- AE_File %>% mutate(
  Other_LTCs = if_else((arth == 1)|(cancer == 1)|(diabetes == 1)|(epilepsy == 1), 1, 0)
)

#No LTC grouping
AE_File <- AE_File %>% mutate(
  No_LTC = if_else(LTC == 0, 1, 0)
)

#Create flag for episodes to be used in group by commands
AE_File <- AE_File %>% mutate(episodes = 1)

#Define disscharge destination based on code
AE_File <- AE_File %>% mutate(AE_File,
                              Destination = case_when(
                                ae_disdest == "00" ~ "Death",
                                ae_disdest == "01" ~ "Private Residence",
                                ae_disdest == "01A" ~ "Private Residence",
                                ae_disdest == "01B" ~ "Private Residence",
                                ae_disdest == "02" ~ "Residential Institution",
                                ae_disdest == "02A" ~ "Residential Institution",
                                ae_disdest == "02B" ~ "Residential Institution",
                                ae_disdest == "03" ~ "Other",
                                ae_disdest == "03A" ~ "Other",
                                ae_disdest == "03B" ~ "Other",
                                ae_disdest == "03C" ~ "Other",
                                ae_disdest == "03D" ~ "Other",
                                ae_disdest == "03Z" ~ "Other",
                                ae_disdest == "04" ~ "Admission",
                                ae_disdest == "04A" ~ "Admission",
                                ae_disdest == "04B" ~ "Admission",
                                ae_disdest == "04C" ~ "Admission",
                                ae_disdest == "04D" ~ "Admission",
                                ae_disdest == "04Z" ~ "Admission",
                                ae_disdest == "05" ~ "Transfer",
                                ae_disdest == "05A" ~ "Transfer",
                                ae_disdest == "05B" ~ "Transfer",
                                ae_disdest == "05C" ~ "Transfer",
                                ae_disdest == "05D" ~ "Transfer",
                                ae_disdest == "05E" ~ "Transfer",
                                ae_disdest == "05F" ~ "Transfer",
                                ae_disdest == "05G" ~ "Transfer",
                                ae_disdest == "05H" ~ "Transfer",
                                ae_disdest == "05Z" ~ "Transfer",
                                ae_disdest == "06" ~ "Other",
                                ae_disdest == "98" ~ "Other",
                                ae_disdest == "99" ~ "Other",
                                ae_disdest == "" ~ "Unknown")
)

#Define referral source based on code
AE_File <- AE_File %>% mutate(AE_File,
                              Ref_Source = case_when(
                                refsource == "01" ~ "Self referral",
                                refsource == "01A" ~ "Self referral",
                                refsource == "01B" ~ "Self referral",
                                refsource == "02" ~ "Other",
                                refsource == "02A" ~ "GP Referral",
                                refsource == "02B" ~ "Other",
                                refsource == "02C" ~ "Ambulance",
                                refsource == "02D" ~ "Other",
                                refsource == "02E" ~ "Other",
                                refsource == "02F" ~ "Other",
                                refsource == "02G" ~ "Other",
                                refsource == "02H" ~ "Other",
                                refsource == "02J" ~ "GP Referral",
                                refsource == "03" ~ "Local Authority",
                                refsource == "03A" ~ "Local Authority",
                                refsource == "03B" ~ "Local Authority",
                                refsource == "03C" ~ "Local Authority",
                                refsource == "03D" ~ "Local Authority",
                                refsource == "04" ~ "Private professional/agency/organisation",
                                refsource == "05" ~ "Other",
                                refsource == "05A" ~ "Other",
                                refsource == "05B" ~ "Other",
                                refsource == "05C" ~ "Other",
                                refsource == "05D" ~ "Other",
                                refsource == "98" ~ "Other",
                                refsource == "99" ~ "Not Known",
                                refsource == "" ~ "Not Known")
)

#Redefine combination of arrival mode and referral source codes
AE_File$Ref_Source[AE_File$ae_arrivalmode %in% c("01", "02", "03") & 
                     AE_File$refsource %in% c("01", "01A", "01B")] <- "Ambulance"
table(AE_File$Ref_Source)
AE_File <- filter(AE_File, Ref_Source != "")

AE_number <- AE_File %>% group_by(year, chi) %>%
  summarise(sum_episodes=sum(episodes)) %>%
  ungroup()

AE_number <- AE_number %>% mutate(AE_number,
                                  AE_Num = case_when(
                                    sum_episodes == 1 ~ "1",
                                    between(sum_episodes, 2, 4) ~ "2-4",
                                    sum_episodes >= 5 ~ "5+")
)

AE_File <- left_join(AE_File, AE_number, by = c("year", "chi"))

#Select only records where an local authority is defined
AE_File <- filter(AE_File, lca != "")
table(AE_File$lca)

AEpart3 <- AE_File %>% mutate(LTCgroup = "N/A")
AEpart3 <- AEpart3 %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, LTCgroup,
                                location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

AElocality <- AEpart3 %>% mutate(individuals = 1)
AElocality <- AElocality %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, LTCgroup,
                                      location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances = sum(Attendances),
            individuals = sum(individuals),
            cost = sum(cost)) %>%
  ungroup()

Location <- AEpart3 %>% mutate(AEpart3, location = "All")
Location <- Location %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                  LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            cost=sum(cost)) %>%
  ungroup()

Location <- Location %>% mutate(individuals = 1)
Location <- Location %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                  LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(Location, AElocality)

Ref_Source <- AEpart3 %>% mutate(AEpart3, Ref_Source = "All")
Ref_Source <- Ref_Source %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                      LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            cost=sum(cost)) %>%
  ungroup()

Ref_Source <- Ref_Source %>% mutate(individuals = 1)
Ref_Source <- Ref_Source %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                      LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(Ref_Source, AElocality)

Loc_Refsource <- AEpart3 %>% mutate(AEpart3, location = "All")
Loc_Refsource <- Loc_Refsource %>% mutate(Loc_Refsource, Ref_Source = "All")
Loc_Refsource <- Loc_Refsource %>% group_by(year, chi, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                            LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            cost=sum(cost)) %>%
  ungroup()

Loc_Refsource <- Loc_Refsource %>% mutate(individuals = 1)
Loc_Refsource <- Loc_Refsource %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num, 
                                            LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(Loc_Refsource, AElocality)

Agegroup <- AElocality %>% mutate(AElocality, age_group = "All")
Agegroup <- Agegroup %>% group_by(year, hbrescode, hbtreatcode, lca, age_group, LTC_Num, LTCgroup,
                                  AE_Num, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(AElocality, Agegroup)

LTC_Number <- AElocality %>% mutate(AElocality, LTC_Num = "All")
LTC_Number <- LTC_Number %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                      LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(AElocality, LTC_Number)

AE_Number <- AElocality %>% mutate(AElocality, AE_Num = "All")
AE_Number <- AE_Number %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                    LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(AElocality, AE_Number)

Locality <- AElocality %>% mutate(AElocality, HSCPLocality = "Agg")
Locality <- Locality %>% group_by(year, hbrescode, hbtreatcode, lca, AE_Num, age_group, LTC_Num,
                                  LTCgroup, location, HSCPLocality, Ref_Source) %>%
  summarise(Attendances=sum(Attendances),
            individuals=sum(individuals),
            cost=sum(cost)) %>%
  ungroup()

AElocality <- bind_rows(AElocality, Locality)

AElocality <- rename(AElocality, Location = location)
Location_lookup <- get_hosp_lookup(c("Location", "Locname"))
AElocality <- left_join(AElocality, Location_lookup, by = "Location")

#Apply location recoding adjustments provided
AElocality$Locname[AElocality$Location %in% "All"] <- "All"
AElocality$Locname[AElocality$Location %in% "G991Z"] <- "Stobhill ACH"

#Rename lca variable for matching and read in lca lookup as new file
AElocality <- rename(AElocality, LCAcode = lca)

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
AElocality <- left_join(AElocality, LCA_lookup, by = "LCAcode")

#Create LA code from LCA name
AElocality <- AElocality %>% lcaname_to_code(LCAname)

# Create Clackmannanshire & Stirling data by selecting the two LCAs seperately,
# giving them both the LA Code for Stirling, and aggregating. Then adding that to source_overview
cs <- AElocality %>%
  filter(LCAname %in% c("Clackmannanshire", "Stirling")) %>%
  mutate(LCAname = "Clackmannanshire & Stirling")
AElocality <- bind_rows(AElocality, cs)

#Create HB Residence from LCA name
AElocality <- AElocality %>% lcaname_to_hb(LCAname)

#Create HB treatment names base on code provided from location lookup
AElocality <- AElocality %>% hbcode_to_hb(hbtreatcode)

#Compute year variable
AElocality <- AElocality %>% mutate(data = "Loc")
AElocality <- rename(AElocality, agegroup = age_group, Locality = HSCPLocality)
AElocality <- select(AElocality, -hbrescode, -hbtreatcode)

## Save out dataset
write_sav(AElocality, here("data", glue("AElocality.sav")), compress = TRUE)