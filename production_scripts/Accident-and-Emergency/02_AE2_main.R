### 1 - Setup environment and load functions ----
source(here::here("code", "00_setup-environment.R"))

#Filter out variables to be used from SLF
required_vars <- c("year", "recid", "anon_chi", "gender", "age", "hbrescode", "hbtreatcode", "location",
                   "refsource", "ae_arrivalmode", "ae_disdest", "cost_total_net", "lca", "datazone2011",
                   "simd2020v2_hb2019_quintile", "arth", "asthma", "atrialfib", "cancer", "cvd", "liver",
                   "copd", "dementia", "diabetes", "epilepsy", "chd", "hefailure", "ms", "parkinsons",
                   "refailure", "congen", "bloodbfo", "endomet", "digestive")
AE_File <- read_slf_episode(finyear, columns = required_vars, recids = "AE2")

AE_File <- AE_File %>% mutate(year = str_c("20", str_sub(year)))

#Rename variables for matching lookup files
AE_File <- rename(AE_File, datazone = datazone2011
              , chi = anon_chi)

#Create age group variable, frequency count to ensure matching with SPSS output
AE_File <- AE_File %>% standard_age_groups(age)
table(AE_File$age_group)

AE_File <- rename(AE_File, simd = simd2020v2_hb2019_quintile)

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

#Remove blank referral source selections and also remove variables not required in output file
AE_File <- filter(AE_File, Ref_Source != "")
AE_File <- select(AE_File, year, chi, hbrescode, hbtreatcode, lca, datazone, simd, age_group, LTC_Num, cost_total_net, 
                  episodes, Cardiovascular, Neurodegenerative, Respiratory, Other_Organs, Other_LTCs, No_LTC, 
                  location, Destination, Ref_Source)

#Create new sub file, calculate number of attendances/episodes by chi number
Attendances <- AE_File %>% group_by(year, chi) %>%
  summarise(Sum_episodes = sum(episodes)) %>%
  ungroup()

#Group AE number of attendaces as dine with age group above
Attendances <- Attendances %>% mutate(Attendances,
                                      AE_Num = case_when(
                                        Sum_episodes == 1 ~ "1",
                                        Sum_episodes >= 2 & Sum_episodes <= 4 ~ "2-4",
                                        Sum_episodes >= 5 ~ "5+"))

#Match on attendance information to main output file by chi, create new file name, Combined
Combined <- left_join(Attendances, AE_File, by = c("year", "chi"))

#Select only records where an local authority is defined
Combined <- filter(Combined, lca != "")
table(Combined$lca)

#Rename lca variable for matching
Combined <- rename(Combined, LCAcode = lca)

#Alter the strings of the LCA lookup code for matching, variable of both files need to be in same format
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
Combined <- left_join(Combined, LCA_lookup, by = "LCAcode")

#Create HB of residence variable based off LCA name
Combined <- Combined %>% lcaname_to_hb(LCAname)

#Each LTC group is filtered out and grouped together to define total episodes and cost
#Create new sub file for each of these so it doesn't interefere with the main file
#Select out each LTC group defined in lines 55-85
#Rename LTC group variable to match which group has been selected out
#Aggregate by required variables and sum episodes and total net cost
Cardiovascular <- filter(Combined, Cardiovascular == 1)
Cardiovascular <- Cardiovascular %>% mutate(Cardiovascular, LTCgroup = "Cardiovascular")
Cardiovascular <- Cardiovascular %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                             LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
                          summarise(Attendances = sum(episodes),
                                    cost = sum(cost_total_net)) %>%
                          ungroup()

#Neurodegenerative selection and file
Neurodegenerative <- filter(Combined, Neurodegenerative == 1)
Neurodegenerative <- Neurodegenerative %>% mutate(Neurodegenerative, LTCgroup = "Neurodegenerative")
Neurodegenerative <- Neurodegenerative %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

#Respiratory selection and file
Respiratory <- filter(Combined, Respiratory == 1)
Respiratory <- Respiratory %>% mutate(Respiratory, LTCgroup = "Respiratory")
Respiratory <- Respiratory %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

#Other organs selection and file
Other_Organs <- filter(Combined, Other_Organs == 1)
Other_Organs <- Other_Organs %>% mutate(Other_Organs, LTCgroup = "Other_Organs")
Other_Organs <- Other_Organs %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

#Other LTCs selection and file
Other_LTCs <- filter(Combined, Other_LTCs == 1)
Other_LTCs <- Other_LTCs %>% mutate(Other_LTCs, LTCgroup = "Other_LTCs")
Other_LTCs <- Other_LTCs %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

#No LTC selection and file
No_LTC <- filter(Combined, No_LTC == 1)
No_LTC <- No_LTC %>% mutate(No_LTC, LTCgroup = "No_LTC")
No_LTC <- No_LTC %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

#Create similar sub file where LTC group is renamed All so all category is included in outputs
LTCgroup <- Combined
LTCgroup <- LTCgroup %>% mutate(LTCgroup, LTCgroup = "All")
LTCgroup <- LTCgroup %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(episodes),
            cost = sum(cost_total_net)) %>%
  ungroup()

#Combine all LTC sub files together and duplicate this file, AEpart1 and AEpart2
AEpart1 <- bind_rows(Cardiovascular, Neurodegenerative, Respiratory, Other_Organs, Other_LTCs, No_LTC, LTCgroup)
AEpart2 <- AEpart1
table(AEpart2$age_group)

#Similar to LTC groups, create new sub file for requisite 'All' selections on certain variables
#Aggregate totals by same set of variables and sum attendances and costs
#Done to completely match SPSS output file which also includes 'All' totals
#Creates multiple sub files which are then added to main file on completion
#All sub files created using the same process
#First sub file is for Destination='All'
Destination <- AEpart1 %>% mutate(AEpart1, Destination = "All")
Destination <- Destination %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                        LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
                summarise(Attendances = sum(Attendances),
                cost = sum(cost)) %>%
                ungroup()

#Always add to AEpart2 once sub file is created
#Hence duplication of AEpart1 
#AEpart1 required in same format for each sub file, can't include additional rows
AEpart2 <- bind_rows(Destination, AEpart2)

#Location='All'
Location <- AEpart1 %>% mutate(AEpart1, location = "All")
Location <- Location %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                  LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
                summarise(Attendances = sum(Attendances),
                cost = sum(cost)) %>%
                ungroup()

AEpart2 <- bind_rows(Location, AEpart2)

#Referral Source='All'
Referral_source <- AEpart1 %>% mutate(AEpart1, Ref_Source = "All")
Referral_source <- Referral_source %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                  LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Referral_source, AEpart2)

#HB Treatment='All'
HB_Treat <- AEpart1 %>% mutate(AEpart1, hbtreatcode = "All")
HB_Treat <- HB_Treat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                                LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(HB_Treat, AEpart2)

#Destination and Location='All'
Dest_Loc <- AEpart1 %>% mutate(AEpart1, Destination = "All")
Dest_Loc <- Dest_Loc %>% mutate(Dest_Loc, location = "All")
Dest_Loc <- Dest_Loc %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                  LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Dest_Loc, AEpart2)

#Destination and Referral Source='All'
Dest_Refsource <- AEpart1 %>% mutate(AEpart1, Destination = "All")
Dest_Refsource <- Dest_Refsource %>% mutate(Dest_Refsource, Ref_Source = "All")
Dest_Refsource <- Dest_Refsource %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                  LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Dest_Refsource, AEpart2)

#Location and Referral Source='All'
Loc_Refsource <- AEpart1 %>% mutate(AEpart1, location = "All")
Loc_Refsource <- Loc_Refsource %>% mutate(Loc_Refsource, Ref_Source = "All")
Loc_Refsource <- Loc_Refsource %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Loc_Refsource, AEpart2)

#Destination and HB Treatment='All'
Dest_HBtreat <- AEpart1 %>% mutate(AEpart1, Destination = "All")
Dest_HBtreat <- Dest_HBtreat %>% mutate(Dest_HBtreat, hbtreatcode = "All")
Dest_HBtreat <- Dest_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                            LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Dest_HBtreat, AEpart2)

#Location and HB Treatment='All'
Loc_HBtreat <- AEpart1 %>% mutate(AEpart1, location = "All")
Loc_HBtreat <- Loc_HBtreat %>% mutate(Loc_HBtreat, hbtreatcode = "All")
Loc_HBtreat <- Loc_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                           LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Loc_HBtreat, AEpart2)

#Referral Source and HB Treatment='All'
Ref_HBtreat <- AEpart1 %>% mutate(AEpart1, Ref_Source = "All")
Ref_HBtreat <- Ref_HBtreat %>% mutate(Ref_HBtreat, hbtreatcode = "All")
Ref_HBtreat <- Ref_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                        LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Ref_HBtreat, AEpart2)

#Location, Referral Source and Destination='All'
Loc_Ref_Dest <- AEpart1 %>% mutate(AEpart1, location = "All")
Loc_Ref_Dest <- Loc_Ref_Dest %>% mutate(Loc_Ref_Dest, Ref_Source = "All")
Loc_Ref_Dest <- Loc_Ref_Dest %>% mutate(Loc_Ref_Dest, Destination = "All")
Loc_Ref_Dest <- Loc_Ref_Dest %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                        LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Loc_Ref_Dest, AEpart2)

#Destination, Referral Source and HB Treatment='All'
Dest_Loc_HBtreat <- AEpart1 %>% mutate(AEpart1, Destination = "All")
Dest_Loc_HBtreat <- Dest_Loc_HBtreat %>% mutate(Dest_Loc_HBtreat, location = "All")
Dest_Loc_HBtreat <- Dest_Loc_HBtreat %>% mutate(Dest_Loc_HBtreat, hbtreatcode = "All")
Dest_Loc_HBtreat <- Dest_Loc_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                          LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Dest_Loc_HBtreat, AEpart2)

#Destination, Referral Source and HB Treatment='All'
Dest_Ref_HBtreat <- AEpart1 %>% mutate(AEpart1, Destination = "All")
Dest_Ref_HBtreat <- Dest_Ref_HBtreat %>% mutate(Dest_Ref_HBtreat, Ref_Source = "All")
Dest_Ref_HBtreat <- Dest_Ref_HBtreat %>% mutate(Dest_Ref_HBtreat, hbtreatcode = "All")
Dest_Ref_HBtreat <- Dest_Ref_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                              LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Dest_Ref_HBtreat, AEpart2)

#Location, Referral Source and HB Treatment='All'
Loc_Ref_HBtreat <- AEpart1 %>% mutate(AEpart1, location = "All")
Loc_Ref_HBtreat <- Loc_Ref_HBtreat %>% mutate(Loc_Ref_HBtreat, Ref_Source = "All")
Loc_Ref_HBtreat <- Loc_Ref_HBtreat %>% mutate(Loc_Ref_HBtreat, hbtreatcode = "All")
Loc_Ref_HBtreat <- Loc_Ref_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                                  LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Loc_Ref_HBtreat, AEpart2)

#Location, Referral Source, Destination and HB Treatment='All'
Loc_Ref_Dest_HBtreat <- AEpart1 %>% mutate(AEpart1, location = "All")
Loc_Ref_Dest_HBtreat <- Loc_Ref_Dest_HBtreat %>% mutate(Loc_Ref_Dest_HBtreat, Ref_Source = "All")
Loc_Ref_Dest_HBtreat <- Loc_Ref_Dest_HBtreat %>% mutate(Loc_Ref_Dest_HBtreat, Destination = "All")
Loc_Ref_Dest_HBtreat <- Loc_Ref_Dest_HBtreat %>% mutate(Loc_Ref_Dest_HBtreat, hbtreatcode = "All")
Loc_Ref_Dest_HBtreat <- Loc_Ref_Dest_HBtreat %>% group_by(year, chi, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                                LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            cost = sum(cost)) %>%
  ungroup()

AEpart2 <- bind_rows(Loc_Ref_Dest_HBtreat, AEpart2)

#Create flag for individuals and aggregate, removing chi variable
AEpart2 <- AEpart2 %>% mutate(AEpart2, individuals = 1)
AEpart2 <- AEpart2 %>% group_by(year, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            individuals = sum(individuals),
            cost = sum(cost)) %>%
  ungroup()

#Create 'All' age group sub file using same method as before
Age_Group <- AEpart2 %>% mutate(AEpart2, age_group="All")
Age_Group <- Age_Group %>% group_by(year, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            individuals = sum(individuals),
            cost = sum(cost)) %>%
  ungroup()

#Combine 'All' age group file to main AEpart2 file
AEpart2 <- bind_rows(Age_Group, AEpart2)

#Create sub file for AE attendance number ='All' category, using same method as before
AE_Number <- AEpart2 %>% mutate(AEpart2, AE_Num= "All")
AE_Number <- AE_Number %>% group_by(year, hbtreatcode, LCAcode, AE_Num, Destination, age_group,
                                    LTCgroup, location, Ref_Source, Hbres, LCAname) %>%
  summarise(Attendances = sum(Attendances),
            individuals = sum(individuals),
            cost = sum(cost)) %>%
  ungroup()

#Combine AE Num='All' with main AEpart2 file
AEpart2 <- bind_rows(AE_Number, AEpart2)

#Compute patient sex=3 which is the 'All' category and rename variables for matching on lookup file
AEpart2 <- AEpart2 %>% mutate(AEpart2, Sex = "3")
AEpart2 <- rename(AEpart2, lca = LCAcode)
AEpart2 <- rename(AEpart2, agegroup = age_group)
table(AEpart2$Sex)

#Match on population lookup by lca, sex and age group
AEpart2 <- left_join(AEpart2, Pop, by = c("year", "lca", "Sex", "agegroup"))

#Modify strings of lca variable
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "01", "1")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "02", "2")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "03", "3")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "04", "4")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "05", "5")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "06", "6")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "07", "7")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "08", "8")
AEpart2 <- AEpart2 %>% mutate_at("lca", str_replace, "09", "9")
table(AEpart2$lca)

#Remove variables no longer required and compute datazone='All'
AEpart2 <- select(AEpart2, -Sex, -hbres_population)
AEpart2 <- AEpart2 %>% mutate(AEpart2, datazone = "All")

#Create new aggregate file which will now calculate Scotland level attendances, individuals and cost
AEpart2 <- AEpart2 %>% group_by(year, hbtreatcode, agegroup, AE_Num, LTCgroup, Destination,
                                    Ref_Source, location, datazone) %>%
  mutate(Scot_Attendances = sum(Attendances),
            Scot_individuals = sum(individuals),
            Scot_cost = sum(cost)) %>%
  ungroup()

#Rename variables for location lookup file
AEpart2 <- rename(AEpart2, Discharge_Dest = Destination)
AEpart2 <- rename(AEpart2, Location = location)

#Read in location lookup file and match on to AEpart2
Loc_lookup <- get_hosp_lookup(c("Location", "Locname"))
AEpart2 <- left_join(AEpart2, Loc_lookup, by = "Location")

#Apply location recoding adjustments provided
AEpart2$Locname[AEpart2$Location %in% "All"] <- "All"
AEpart2$Locname[AEpart2$Location %in% "G991Z"] <- "Stobhill ACH"
AEpart2$Postcode[AEpart2$Location %in% "G991Z"] <- "G21 3UW"

#Create LA code from LCA name
AEpart2 <- AEpart2 %>% lcaname_to_code(LCAname)

# Create Clackmannanshire & Stirling data by selecting the two LCAs seperately,
# giving them both the LA Code for Stirling, and aggregating. Then adding that to source_overview
cs <- AEpart2 %>%
  filter(LCAname %in% c("Clackmannanshire", "Stirling")) %>%
  mutate(LCAname = "Clackmannanshire & Stirling")
AEpart2 <- bind_rows(AEpart2, cs)
table(AEpart2$LCAname)

#Create HB treatment names base on code provided from location lookup
AEpart2 <- AEpart2 %>% hbcode_to_hb(hbtreatcode)
AEpart2 <- select(AEpart2, -hbtreatcode)

#Create new sub file which calculate outside Health Board totals
Outside_HB_Totals <- filter(AEpart2, Hb_Treatment != Hbres)
Outside_HB_Totals <- filter(Outside_HB_Totals, Hb_Treatment != "All")
Outside_HB_Totals <- filter(Outside_HB_Totals, Location != "All")
Outside_HB_Totals <- Outside_HB_Totals %>% mutate(Outside_HB_Totals, Location = "Other")
Outside_HB_Totals <- Outside_HB_Totals %>% mutate(Outside_HB_Totals, Postcode = "Other")
Outside_HB_Totals <- Outside_HB_Totals %>% mutate(Outside_HB_Totals, Locname = "Hospital outside Health Board")
Outside_HB_Totals <- Outside_HB_Totals %>% mutate(Outside_HB_Totals, Hb_Treatment = Hbres)

#Once selections have been made to filter out information, aggregate, include LCA totals and Scotland totals in output
Outside_HB_Totals <- Outside_HB_Totals %>% group_by(Hbres, Hb_Treatment, lca, AE_Num, Discharge_Dest, agegroup, LTCgroup, 
                                        Location, Ref_Source, Postcode, Locname, year, LA_CODE, LCAname, datazone) %>%
  summarise(Attendances = sum(Attendances),
            Scot_Attendances = sum(Attendances),
            Scot_individuals = sum(individuals),
            Scot_cost = sum(cost),
            individuals = sum(individuals),
            cost = sum(cost),
            population = max(population),
            scot_population = max(scot_population)) %>%
            ungroup()

#Combine outside HB totals with AEpart2 to create final output file
Final <- bind_rows(AEpart2, Outside_HB_Totals)
table(Final$year)
Final <- Final %>% mutate(data = "Data")

## Save out dataset
write_sav(Final, here("data", glue("AEprogram.sav")), compress = TRUE)

