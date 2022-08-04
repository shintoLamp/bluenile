LFR03 <-
  read_csv("/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/01-HSC-Expenditure/2019-20/LFR3-19-20-Data.csv",
           col_names = c("service", "sector", "mapname", "detailed_level_for_match", "Year", "Client_group", 
                         "Aberdeen_City", "Aberdeenshire", "Angus", "Argyll_and_Bute", "Clackmannanshire", "Dumfries_and_Galloway",
                         "Dundee_City", "East_Ayrshire", "East_Dunbartonshire", "East_Lothian", "East_Renfrewshire", "City_of_Edinburgh",
                         "Eilean_Siar", "Falkirk", "Fife", "Glasgow_City", "Highland", "Inverclyde", "Midlothian", "Moray", "North_Ayrshire",
                         "North_Lanarkshire", "Orkney_Islands", "Perth_and_Kinross", "Renfrewshire", "Scottish_Borders", "Shetland_Islands",
                         "South_Ayrshire", "South_Lanarkshire", "Stirling", "West_Dunbartonshire", "West_Lothian"),
           col_types = "cccccciiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii",
           skip = 1)

LFR03 <- gather(LFR03, "HSCP", "Expenditure", Aberdeen_City, Aberdeenshire, Angus, Argyll_and_Bute, Clackmannanshire, Dumfries_and_Galloway,
                Dundee_City, East_Ayrshire, East_Dunbartonshire, East_Lothian, East_Renfrewshire, City_of_Edinburgh,
                Eilean_Siar, Falkirk, Fife, Glasgow_City, Highland, Inverclyde, Midlothian, Moray, North_Ayrshire,
                North_Lanarkshire, Orkney_Islands, Perth_and_Kinross, Renfrewshire, Scottish_Borders, Shetland_Islands,
                South_Ayrshire, South_Lanarkshire, Stirling, West_Dunbartonshire, West_Lothian)

LFR03 <- mutate(LFR03, HSCP_NAME = case_when(
  HSCP == "Aberdeen_City" ~ "Aberdeen City",
  HSCP == "Argyll_and_Bute" ~ "Argyll & Bute",
  HSCP == "Dumfries_and_Galloway" ~ "Dumfries & Galloway",
  HSCP == "Dundee_City" ~ "Dundee City",
  HSCP == "East_Ayrshire" ~ "East Ayrshire",
  HSCP == "East_Dunbartonshire" ~ "East Dunbartonshire",
  HSCP == "East_Lothian" ~ "East Lothian",
  HSCP == "East_Renfrewshire" ~ "East Renfrewshire",
  HSCP == "City_of_Edinburgh" ~ "City of Edinburgh",
  HSCP == "Eilean_Siar" ~ "Western Isles",
  HSCP == "Glasgow_City" ~ "Glasgow City",
  HSCP == "North_Ayrshire" ~ "North Ayrshire",
  HSCP == "North_Lanarkshire" ~ "North Lanarkshire",
  HSCP == "Orkney_Islands" ~ "Orkney",
  HSCP == "Perth_and_Kinross" ~ "Perth & Kinross",
  HSCP == "Scottish_Borders" ~ "Scottish Borders",
  HSCP == "Shetland_Islands" ~ "Shetland",
  HSCP == "South_Ayrshire" ~ "South Ayrshire",
  HSCP == "South_Lanarkshire" ~ "South Lanarkshire",
  HSCP == "West_Dunbartonshire" ~ "West Dunbartonshire",
  HSCP == "West_Lothian" ~ "West Lothian",
  TRUE ~ as.character(HSCP))
)

LFR03 <- mutate(LFR03, hbr = case_when(
  HSCP_NAME == "North Ayrshire" | HSCP_NAME == "South Ayrshire" | HSCP_NAME == "East Ayrshire" ~ "A",
  HSCP_NAME == "East Dunbartonshire" | HSCP_NAME == "Glasgow City" | HSCP_NAME == "East Renfrewshire" |
  HSCP_NAME == "West Dunbartonshire" | HSCP_NAME == "Renfrewshire" | HSCP_NAME == "Inverclyde" ~ "G",
  HSCP_NAME == "Highland" | HSCP_NAME == "Argyll & Bute" ~ "H",
  HSCP_NAME == "North Lanarkshire" | HSCP_NAME == "South Lanarkshire" ~ "L",
  HSCP_NAME == "Aberdeen City" | HSCP_NAME == "Aberdeenshire" | HSCP_NAME == "Moray" ~ "N",
  HSCP_NAME == "East Lothian" | HSCP_NAME == "West Lothian" | HSCP_NAME == "Midlothian" | HSCP_NAME == "City of Edinburgh" ~ "S",
  HSCP_NAME == "Perth & Kinross" | HSCP_NAME == "Dundee City" | HSCP_NAME == "Angus" ~ "T",
  HSCP_NAME == "Clackmannanshire" | HSCP_NAME == "Stirling" | HSCP_NAME == "Falkirk" ~ "V",
  HSCP_NAME == "Scottish Borders" ~ "B",
  HSCP_NAME == "Fife" ~ "F",
  HSCP_NAME == "Orkney" ~ "R",
  HSCP_NAME == "Western Isles" ~ "W",
  HSCP_NAME == "Dumfries & Galloway" ~ "Y",
  HSCP_NAME == "Shetland" ~ "Z")
)

LFR03 <- mutate(LFR03, Expenditure = Expenditure*1000)

LFR03 <- mutate(LFR03,
              AGEGROUP = case_when(
              Client_group == "Children & Families" ~ "<18",
              Client_group == "Adult Social Care" ~ "18+")
)

saveRDS(LFR03, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/H&SC Expenditure/data/",
                           "LFR3_","{year}","_Master.rds"))

Home_Care <- read_rds(file = glue("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/",
                            "LCA_Proportion_Shares_HomeCare_PersonalCare_","{year}",".rds"))

Home_Care <- rename(Home_Care, HSCP_NAME = LCA)
Home_Care <- Home_Care %>%
  mutate(HSCP_NAME = recode(HSCP_NAME, "Orkney Islands" = "Orkney", "Shetland Islands" = "Shetland"))

Home_Care <- filter(Home_Care, Agegroup != "0-17")

Home_Care <- mutate(Home_Care, Proportion_Share_HC18_64 = case_when(Agegroup == "18-64" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_PC18_64 = case_when(Agegroup == "18-64" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_HC65_74 = case_when(Agegroup == "65-74" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_PC65_74 = case_when(Agegroup == "65-74" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_HC75_84 = case_when(Agegroup == "75-84" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_PC75_84 = case_when(Agegroup == "75-84" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_HC85 = case_when(Agegroup == "85+" ~ HC_share_OP, TRUE ~ 0)) 
Home_Care <- mutate(Home_Care, Proportion_Share_PC85 = case_when(Agegroup == "85+" ~ HC_share_OP, TRUE ~ 0))

Home_Care <- Home_Care %>% group_by(HSCP_NAME) %>%
  summarise(Proportion_Share_HC18_64=sum(Proportion_Share_HC18_64),
            Proportion_Share_PC18_64=sum(Proportion_Share_PC18_64),
            Proportion_Share_HC65_74=sum(Proportion_Share_HC65_74),
            Proportion_Share_PC65_74=sum(Proportion_Share_PC65_74),
            Proportion_Share_HC75_84=sum(Proportion_Share_HC75_84),
            Proportion_Share_PC75_84=sum(Proportion_Share_PC75_84),
            Proportion_Share_HC85=sum(Proportion_Share_HC85),
            Proportion_Share_PC85=sum(Proportion_Share_PC85)) %>%
  ungroup()

saveRDS(Home_Care, "/conf/sourcedev/TableauUpdates/H&SC Expenditure/H&SC Expenditure/data/Shares_Non residential_1920.rds")

Direct_Payments <- read_rds(file = glue("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/",
                                     "LCA_Proportion_Shares_DirectPayments_","{year}",".rds"))

Direct_Payments <- rename(Direct_Payments, HSCP_NAME = LCA)
Direct_Payments <- Direct_Payments %>%
  mutate(HSCP_NAME = recode(HSCP_NAME, "Argyll and Bute" = "Argyll & Bute", "Dumfries and Galloway" = "Dumfries & Galloway",
"Perth and Kinross" = "Perth & Kinross", "Orkney Islands" = "Orkney", "Shetland Islands" = "Shetland", "Borders" = "Scottish Borders",
"Edinburgh, City of" = "City of Edinburgh", "Eilean Siar" = "Western Isles"))

Direct_Payments <- filter(Direct_Payments, Agegroup != "0-17")

Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP0_64 = case_when(Agegroup == "0-64" ~ Proportion_Share_DP, TRUE ~ 0)) 
Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP18_64 = case_when(Agegroup == "18-64" ~ Proportion_Share_DP, TRUE ~ 0)) 
Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP65_74 = case_when(Agegroup == "65-74" ~ Proportion_Share_DP, TRUE ~ 0)) 
Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP75_84 = case_when(Agegroup == "75-84" ~ Proportion_Share_DP, TRUE ~ 0)) 
Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP85 = case_when(Agegroup == "85+" ~ Proportion_Share_DP, TRUE ~ 0)) 

Direct_Payments <- Direct_Payments %>% group_by(HSCP_NAME) %>%
  summarise(Proportion_Share_DP0_64=sum(Proportion_Share_DP0_64),
            Proportion_Share_DP18_64=sum(Proportion_Share_DP18_64),
            Proportion_Share_DP65_74=sum(Proportion_Share_DP65_74),
            Proportion_Share_DP75_84=sum(Proportion_Share_DP75_84),
            Proportion_Share_DP85=sum(Proportion_Share_DP85)) %>%
  ungroup()

saveRDS(Direct_Payments, "/conf/sourcedev/TableauUpdates/H&SC Expenditure/H&SC Expenditure/data/Shares_DP_1920.rds")

Care_Home <- read_rds(file = glue("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/",
                               "LCA_Proportion_Shares_CH_","{year}",".rds"))

Care_Home <- rename(Care_Home, HSCP_NAME = LCA)
Care_Home <- Care_Home %>%
  mutate(HSCP_NAME = recode(HSCP_NAME, "Orkney Islands" = "Orkney", "Shetland Islands" = "Shetland", "Na h-Eileanan Siar" = "Western Isles"))

Care_Home <- mutate(Care_Home, Proportion_Care_Home = as.double(Proportion_Care_Home))
Care_Home <- mutate(Care_Home, Proportion_Share_CH18_64 = case_when(Agegroup == "18-64" ~ Proportion_Care_Home, TRUE ~ 0))
Care_Home <- mutate(Care_Home, Proportion_Share_CH65_74 = case_when(Agegroup == "65-74" ~ Proportion_Care_Home, TRUE ~ 0))
Care_Home <- mutate(Care_Home, Proportion_Share_CH75_84 = case_when(Agegroup == "75-84" ~ Proportion_Care_Home, TRUE ~ 0))
Care_Home <- mutate(Care_Home, Proportion_Share_CH85 = case_when(Agegroup == "85+" ~ Proportion_Care_Home, TRUE ~ 0))

Care_Home <- Care_Home %>% group_by(HSCP_NAME) %>%
  summarise(Proportion_Share_CH18_64=sum(Proportion_Share_CH18_64),
            Proportion_Share_CH65_74=sum(Proportion_Share_CH65_74),
            Proportion_Share_CH75_84=sum(Proportion_Share_CH75_84),
            Proportion_Share_CH85=sum(Proportion_Share_CH85)) %>%
  ungroup()

saveRDS(Care_Home, "/conf/sourcedev/TableauUpdates/H&SC Expenditure/H&SC Expenditure/data/Shares_Residential_1920.rds")

Home_Care <- mutate(Home_Care, HC_Check = Proportion_Share_HC18_64 + Proportion_Share_HC65_74 + Proportion_Share_HC75_84 + 
                      Proportion_Share_HC85)
Home_Care <- mutate(Home_Care, adjment = 1 - HC_Check)
Home_Care <- mutate(Home_Care, Proportion_Share_HC85 = Proportion_Share_HC85 + adjment)
Home_Care <- mutate(Home_Care, HC_Check2 = Proportion_Share_HC18_64 + Proportion_Share_HC65_74 + Proportion_Share_HC75_84 + 
                      Proportion_Share_HC85)

Home_Care <- mutate(Home_Care, PC_Check = Proportion_Share_PC18_64 + Proportion_Share_PC65_74 + Proportion_Share_PC75_84 + 
                      Proportion_Share_PC85)
Home_Care <- mutate(Home_Care, adjment = 1 - PC_Check)
Home_Care <- mutate(Home_Care, Proportion_Share_PC85 = Proportion_Share_PC85 + adjment)
Home_Care <- mutate(Home_Care, PC_Check2 = Proportion_Share_PC18_64 + Proportion_Share_PC65_74 + Proportion_Share_PC75_84 + 
                      Proportion_Share_PC85)

Home_Care <- select(Home_Care, -HC_Check, -HC_Check2, -PC_Check, -PC_Check2, -adjment)

Direct_Payments <- mutate(Direct_Payments, DP_Check = Proportion_Share_DP0_64 + Proportion_Share_DP18_64 + Proportion_Share_DP65_74 + 
                            Proportion_Share_DP75_84 +  Proportion_Share_DP85)
Direct_Payments <- mutate(Direct_Payments, adjment = 1 - DP_Check)
Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP85 = Proportion_Share_DP85 + adjment)
Direct_Payments <- mutate(Direct_Payments, DP_Check2 = Proportion_Share_DP0_64 + Proportion_Share_DP18_64 + Proportion_Share_DP65_74 + 
                            Proportion_Share_DP75_84 +  Proportion_Share_DP85)

Direct_Payments <- select(Direct_Payments, -DP_Check, -DP_Check2, -adjment)

Care_Home <- mutate(Care_Home, CH_Check = Proportion_Share_CH18_64 + Proportion_Share_CH65_74 + 
                            Proportion_Share_CH75_84 +  Proportion_Share_CH85)
Care_Home <- mutate(Care_Home, adjment = 1 - CH_Check)
Care_Home <- mutate(Care_Home, Proportion_Share_CH85 = Proportion_Share_CH85 + adjment)
Care_Home <- mutate(Care_Home, CH_Check2 = Proportion_Share_CH18_64 + Proportion_Share_CH65_74 + 
                            Proportion_Share_CH75_84 +  Proportion_Share_CH85)

Care_Home <- select(Care_Home, -CH_Check, -CH_Check2, -adjment)

Home_Care_18_plus <- filter(LFR03, AGEGROUP == "18+")
Home_Care_18_plus <- filter(Home_Care_18_plus, sector != "06-Accommodation-based services")
Home_Care_18_plus <- filter(Home_Care_18_plus, mapname != "32-Direct Payments")

Home_Care_18_plus <- Home_Care_18_plus %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
                    summarise(Expenditure=sum(Expenditure)) %>%
                    ungroup()

Home_Care_18_plus <- left_join(Home_Care_18_plus, Home_Care, by = "HSCP_NAME")

Home_Care_18_plus <- mutate(Home_Care_18_plus, Expenditure = case_when(
  detailed_level_for_match == "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_PC18_64, TRUE ~ Expenditure))
Home_Care_18_plus <- mutate(Home_Care_18_plus, Expenditure = case_when(
  detailed_level_for_match != "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_HC18_64, TRUE ~ Expenditure))
Home_Care_18_plus <- mutate(Home_Care_18_plus, AGEGROUP = "18-64")

saveRDS(Home_Care_18_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                            "H&SC Expenditure/data/LFR3_","{year}","_1864_non_residential_ExDP.rds"))

Direct_Payments_18_plus <- filter(LFR03, AGEGROUP == "18+")
Direct_Payments_18_plus <- filter(Direct_Payments_18_plus, sector != "06- Accommodation-based services")
Direct_Payments_18_plus <- filter(Direct_Payments_18_plus, mapname == "32-Direct Payments")

Direct_Payments_18_plus <- Direct_Payments_18_plus %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                                mapname, detailed_level_for_match) %>%
                            summarise(Expenditure=sum(Expenditure)) %>%
                          ungroup()

Direct_Payments_18_plus <- left_join(Direct_Payments_18_plus, Direct_Payments, by = "HSCP_NAME")

Direct_Payments_18_plus <- mutate(Direct_Payments_18_plus, Expenditure = Expenditure*Proportion_Share_DP18_64)
Direct_Payments_18_plus <- mutate(Direct_Payments_18_plus, AGEGROUP = "18-64")

saveRDS(Direct_Payments_18_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_1864_non_residential_DP.rds"))

Care_Home_18_plus <- filter(LFR03, AGEGROUP == "18+")
Care_Home_18_plus <- filter(Care_Home_18_plus, sector != "06-Accommodation-based services")

Care_Home_18_plus <- Care_Home_18_plus %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                                mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Care_Home_18_plus <- left_join(Care_Home_18_plus, Care_Home, by = "HSCP_NAME")

Care_Home_18_plus <- mutate(Care_Home_18_plus, Expenditure = Expenditure*Proportion_Share_CH18_64)
Care_Home_18_plus <- mutate(Care_Home_18_plus, AGEGROUP = "18-64")

saveRDS(Care_Home_18_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                             "H&SC Expenditure/data/LFR3_","{year}","_1864_residential.rds"))

Home_Care_65_74 <- filter(LFR03, AGEGROUP == "18+")
Home_Care_65_74 <- filter(Home_Care_65_74, sector != "06-Accommodation-based services")
Home_Care_65_74 <- filter(Home_Care_65_74, mapname != "32-Direct Payments")

Home_Care_65_74 <- Home_Care_65_74 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Home_Care_65_74 <- left_join(Home_Care_65_74, Home_Care, by = "HSCP_NAME")

Home_Care_65_74 <- mutate(Home_Care_65_74, Expenditure = case_when(
  detailed_level_for_match == "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_PC65_74, TRUE ~ Expenditure))
Home_Care_65_74 <- mutate(Home_Care_65_74, Expenditure = case_when(
  detailed_level_for_match != "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_HC65_74, TRUE ~ Expenditure))
Home_Care_65_74 <- mutate(Home_Care_65_74, AGEGROUP = "65-74")

saveRDS(Home_Care_65_74, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_6574_non_residential_ExDP.rds"))

Direct_Payments_65_74 <- filter(LFR03, AGEGROUP == "18+")
Direct_Payments_65_74 <- filter(Direct_Payments_65_74, sector != "06- Accommodation-based services")
Direct_Payments_65_74 <- filter(Direct_Payments_65_74, mapname == "32-Direct Payments")

Direct_Payments_65_74 <- Direct_Payments_65_74 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                                mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Direct_Payments_65_74 <- left_join(Direct_Payments_65_74, Direct_Payments, by = "HSCP_NAME")

Direct_Payments_65_74 <- mutate(Direct_Payments_65_74, Expenditure = Expenditure*Proportion_Share_DP65_74)
Direct_Payments_65_74 <- mutate(Direct_Payments_65_74, AGEGROUP = "65-74")

saveRDS(Direct_Payments_65_74, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                             "H&SC Expenditure/data/LFR3_","{year}","_6574_non_residential_DP.rds"))

Care_Home_65_74 <- filter(LFR03, AGEGROUP == "18+")
Care_Home_65_74 <- filter(Care_Home_65_74, sector != "06-Accommodation-based services")

Care_Home_65_74 <- Care_Home_65_74 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Care_Home_65_74 <- left_join(Care_Home_65_74, Care_Home, by = "HSCP_NAME")

Care_Home_65_74 <- mutate(Care_Home_65_74, Expenditure = Expenditure*Proportion_Share_CH65_74)
Care_Home_65_74 <- mutate(Care_Home_65_74, AGEGROUP = "65-74")

saveRDS(Care_Home_65_74, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_6574_residential.rds"))

Home_Care_75_84 <- filter(LFR03, AGEGROUP == "18+")
Home_Care_75_84 <- filter(Home_Care_75_84, sector != "06-Accommodation-based services")
Home_Care_75_84 <- filter(Home_Care_75_84, mapname != "32-Direct Payments")

Home_Care_75_84 <- Home_Care_75_84 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Home_Care_75_84 <- left_join(Home_Care_75_84, Home_Care, by = "HSCP_NAME")

Home_Care_75_84 <- mutate(Home_Care_75_84, Expenditure = case_when(
  detailed_level_for_match == "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_PC75_84, TRUE ~ Expenditure))
Home_Care_75_84 <- mutate(Home_Care_75_84, Expenditure = case_when(
  detailed_level_for_match != "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_HC75_84, TRUE ~ Expenditure))
Home_Care_75_84 <- mutate(Home_Care_75_84, AGEGROUP = "75-84")

saveRDS(Home_Care_75_84, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_7584_non_residential_ExDP.rds"))

Direct_Payments_75_84 <- filter(LFR03, AGEGROUP == "18+")
Direct_Payments_75_84 <- filter(Direct_Payments_75_84, sector != "06- Accommodation-based services")
Direct_Payments_75_84 <- filter(Direct_Payments_75_84, mapname == "32-Direct Payments")

Direct_Payments_75_84 <- Direct_Payments_75_84 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                                mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Direct_Payments_75_84 <- left_join(Direct_Payments_75_84, Direct_Payments, by = "HSCP_NAME")

Direct_Payments_75_84 <- mutate(Direct_Payments_75_84, Expenditure = Expenditure*Proportion_Share_DP75_84)
Direct_Payments_75_84 <- mutate(Direct_Payments_75_84, AGEGROUP = "75-84")

saveRDS(Direct_Payments_75_84, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                             "H&SC Expenditure/data/LFR3_","{year}","_7584_non_residential_DP.rds"))

Care_Home_75_84 <- filter(LFR03, AGEGROUP == "18+")
Care_Home_75_84 <- filter(Care_Home_75_84, sector != "06-Accommodation-based services")

Care_Home_75_84 <- Care_Home_75_84 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Care_Home_75_84 <- left_join(Care_Home_75_84, Care_Home, by = "HSCP_NAME")

Care_Home_75_84 <- mutate(Care_Home_75_84, Expenditure = Expenditure*Proportion_Share_CH75_84)
Care_Home_75_84 <- mutate(Care_Home_75_84, AGEGROUP = "75-84")

saveRDS(Care_Home_75_84, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_7584_residential.rds"))

Home_Care_85_plus <- filter(LFR03, AGEGROUP == "18+")
Home_Care_85_plus <- filter(Home_Care_85_plus, sector != "06-Accommodation-based services")
Home_Care_85_plus <- filter(Home_Care_85_plus, mapname != "32-Direct Payments")

Home_Care_85_plus <- Home_Care_85_plus %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Home_Care_85_plus <- left_join(Home_Care_85_plus, Home_Care, by = "HSCP_NAME")

Home_Care_85_plus <- mutate(Home_Care_85_plus, Expenditure = case_when(
  detailed_level_for_match == "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_PC85, TRUE ~ Expenditure))
Home_Care_85_plus <- mutate(Home_Care_85_plus, Expenditure = case_when(
  detailed_level_for_match != "Home Care - Free Personal Care (aged 65+)" ~ Expenditure*Proportion_Share_HC85, TRUE ~ Expenditure))
Home_Care_85_plus <- mutate(Home_Care_85_plus, AGEGROUP = "85+")

saveRDS(Home_Care_85_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_85_non_residential_ExDP.rds"))

Direct_Payments_85_plus <- filter(LFR03, AGEGROUP == "18+")
Direct_Payments_85_plus <- filter(Direct_Payments_85_plus, sector != "06- Accommodation-based services")
Direct_Payments_85_plus <- filter(Direct_Payments_85_plus, mapname == "32-Direct Payments")

Direct_Payments_85_plus <- Direct_Payments_85_plus %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                                mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Direct_Payments_85_plus <- left_join(Direct_Payments_85_plus, Direct_Payments, by = "HSCP_NAME")

Direct_Payments_85_plus <- mutate(Direct_Payments_85_plus, Expenditure = Expenditure*Proportion_Share_DP85)
Direct_Payments_85_plus <- mutate(Direct_Payments_85_plus, AGEGROUP = "85+")

saveRDS(Direct_Payments_85_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                             "H&SC Expenditure/data/LFR3_","{year}","_85_non_residential_DP.rds"))

Care_Home_85_plus <- filter(LFR03, AGEGROUP == "18+")
Care_Home_85_plus <- filter(Care_Home_85_plus, sector != "06-Accommodation-based services")

Care_Home_85_plus <- Care_Home_85_plus %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                    mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Care_Home_85_plus <- left_join(Care_Home_85_plus, Care_Home, by = "HSCP_NAME")

Care_Home_85_plus <- mutate(Care_Home_85_plus, Expenditure = Expenditure*Proportion_Share_CH85)
Care_Home_85_plus <- mutate(Care_Home_85_plus, AGEGROUP = "85+")

saveRDS(Care_Home_85_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                       "H&SC Expenditure/data/LFR3_","{year}","_85_residential.rds"))

Direct_Payments_0_64 <- filter(LFR03, AGEGROUP == "18+")
Direct_Payments_0_64 <- filter(Direct_Payments_0_64, sector != "06- Accommodation-based services")
Direct_Payments_0_64 <- filter(Direct_Payments_0_64, mapname == "32-Direct Payments")

Direct_Payments_0_64 <- Direct_Payments_0_64 %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                                                                mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Direct_Payments_0_64 <- left_join(Direct_Payments_0_64, Direct_Payments, by = "HSCP_NAME")

Direct_Payments_0_64 <- mutate(Direct_Payments_0_64, Expenditure = Expenditure*Proportion_Share_DP0_64)
Direct_Payments_0_64 <- filter(Direct_Payments_0_64, Expenditure != 0)
Direct_Payments_0_64 <- mutate(Direct_Payments_0_64, AGEGROUP = "0-64")

saveRDS(Direct_Payments_85_plus, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                             "H&SC Expenditure/data/LFR3_","{year}","_0_64_non_residential_DP.rds"))

All_Ages <- mutate(LFR03, AGEGROUP = "All")

saveRDS(All_Ages, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                             "H&SC Expenditure/data/LFR3_","{year}","_AllAge.rds"))

Final <- bind_rows(Home_Care_18_plus, Direct_Payments_18_plus, Care_Home_18_plus, Direct_Payments_0_64,
                   Home_Care_65_74, Direct_Payments_65_74, Care_Home_65_74, Home_Care_75_84, Direct_Payments_75_84,
                   Care_Home_75_84, Home_Care_85_plus, Direct_Payments_85_plus, Care_Home_85_plus, All_Ages)

Final <- Final %>% group_by(Year, hbr, HSCP_NAME, AGEGROUP, service, sector,
                            mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

saveRDS(Final, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                              "H&SC Expenditure/data/LFR3_","{year}","_T1.rds"))

Final_HB <- Final %>% group_by(Year, hbr, AGEGROUP, service, sector,
                            mapname, detailed_level_for_match) %>%
  summarise(Expenditure=sum(Expenditure)) %>%
  ungroup()

Final_HB <- mutate(Final_HB, HSCP_NAME = case_when(
  hbr == "A" ~ "NHS Ayrshire & Arran",
  hbr == "B" ~ "NHS Borders",
  hbr == "F" ~ "NHS Fife",
  hbr == "G" ~ "NHS Greater Glasgow & Clyde",
  hbr == "H" ~ "NHS Highland",
  hbr == "L" ~ "NHS Lanarkshire",
  hbr == "N" ~ "NHS Grampian",
  hbr == "R" ~ "NHS Orkney",
  hbr == "S" ~ "NHS Lothian",
  hbr == "T" ~ "NHS Tayside",
  hbr == "V" ~ "NHS Forth Valley",
  hbr == "W" ~ "NHS Western Isles",
  hbr == "Y" ~ "NHS Dumfries & Galloway",
  hbr == "Z" ~ "NHS Shetland")
)

saveRDS(Final_HB, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                           "H&SC Expenditure/data/LFR3_","{year}","_T2.rds"))

Final_Data <- bind_rows(Final, Final_HB)
Final_Data <- filter(Final_Data, AGEGROUP != "18+")

saveRDS(Final_Data, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                              "H&SC Expenditure/data/LFR3_","{year}","_T3.rds"))

Final_Data <- mutate(Final_Data, service = "Social Care")

Final_Data <- Final_Data %>%
  mutate(sector = recode(sector, "06-Accommodation-based services" = "Accommodation based services", 
                         "07-Community-based services" = "Community based services"))

Final_Data <- Final_Data %>%
  mutate(mapname = recode(mapname, "27-Care Homes" = "Care Homes", "28-Other-Accommodation-based service" = "Other", 
                         "30-Home Care" = "Home Care", "31-Day Care" = "Day Care", 
                         "32-Direct Payments" = "Direct Payments", "33-Other-Community-based service" = "Other"))

Final_Data <- rename(Final_Data, Sub_Sector = mapname)

saveRDS(Final_Data, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                "H&SC Expenditure/data/LFR3_","{year}","_Final.rds"))