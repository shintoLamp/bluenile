Mapped_File <- read_sav("/conf/hscdiip/11-mapping/2019/data/outputs/Mapped-Summary-Final-Scotland4_0421.sav")
Unmapped_File <- read_sav("/conf/hscdiip/11-mapping/2019/data/outputs/Unmapped-Summary-Final-Scotland.sav")

Mapped_File <- bind_rows(Mapped_File, Unmapped_File)
Mapped_File <- select(Mapped_File, -mapyear, -Sector, -SubSector)

Mapped_File <- mutate(Mapped_File, hscp_name = case_when(
  hscp_code == "S37000032" & hscp_name == "" ~ "Fife",
  hscp_code == "S37000033" & hscp_name == "" ~ "Perth & Kinross",
  hscp_code == "S37000034" & hscp_name == "" ~ "Glasgow City",
  hscp_code == "S37000035" & hscp_name == "" ~ "North Lanarkshire",
  TRUE ~ as.character(hscp_name))
  )

Mapped_File <- mutate(Mapped_File, hbr = as.character(hbr))
Mapped_File <- mutate(Mapped_File, hbr = case_when(hbr == "" ~ hbt, TRUE ~ hbr))
Mapped_File <- mutate(Mapped_File, HealthBoardR = case_when(HealthBoardR == "" ~ HealthBoardT, TRUE ~ HealthBoardR))
Mapped_File <- mutate(Mapped_File, hscp_code = case_when(hscp_code == "" ~ "N/A", TRUE ~ hscp_code))
Mapped_File <- mutate(Mapped_File, hscp_name = case_when(hscp_name == "" ~ "Non HSCP", TRUE ~ hscp_name))
Mapped_File <- Mapped_File %>% mutate(Age_band = recode(Age_band, `0` = 999))
Mapped_File <- mutate(Mapped_File, Age_desc = case_when(Age_desc == "" ~ "Missing", TRUE ~ Age_desc))
Mapped_File <- mutate(Mapped_File, hscp_name = case_when(hscp_name == "N/A" ~ "Non HSCP", TRUE ~ hscp_name))
Mapped_File <- mutate(Mapped_File, YEAR == "2019/20")

Functional_Output <- read_sav("/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/",
                  "01-HSC-Expenditure/Lookups/Functional_output_summary_level_lookup_1920.sav")
Mapped_File <- left_join(Mapped_File, Functional_Output, by = "MapCode")

Mapped_File <- filter(Mapped_File, Sub_Sector != "Drop")

Mapped_File <- mutate(Mapped_File, Age_desc = case_when(
      Age_band = `1` ~ "<18",
      Age_band = `2` ~ "18-64",
      Age_band = `3` ~ "65-74",
      Age_band = `4` ~ "75-84",
      Age_band = `5` ~ "85+",
      TRUE ~ Age_desc)
      )

Mapped_File <- rename(Mapped_File, AGEGROUP = Age_desc, Expenditure = Total_Net_Costs)
Mapped_File <- select(Mapped_File, YEAR, hbr, hscp_name, AGEGROUP, service, Sub_Sector, Detail_Sector, Expenditure)
saveRDS(Mapped_File, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                "H&SC Expenditure/data/All-chps-Temp1-","{year}",".rds"))

Mapped_File_All_Ages <- mutate(Mapped_File, AGEGROUP = "All")

Mapped_File_All_Ages <- Mapped_File_All_Ages %>% group_by(YEAR, hbr, hscp_name, AGEGROUP, service,
                                                          Sector, Sub_Sector, Detail_Sector) %>%
                  summarise(Expenditure = sum(Expenditure)) %>%
                  ungroup()

saveRDS(Mapped_File_All_Ages, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                 "H&SC Expenditure/data/All-chps-Temp2-","{year}",".rds"))

Final_Mapped_File <- bind_rows(Mapped_File, Mapped_File_All_Ages)

saveRDS(Final_Mapped_File, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                          "H&SC Expenditure/data/All-chps-Temp3-","{year}",".rds"))

Final_Mapped_File_Board <- filter(Final_Mapped_File, hbr != "O")
Final_Mapped_File_Board <- Final_Mapped_File %>% group_by(YEAR, hbr, AGEGROUP, service,
                                                    Sector, Sub_Sector, Detail_Sector) %>%
  summarise(Expenditure = sum(Expenditure)) %>%
  ungroup()

Final_Mapped_File_Board <- mutate(Final_Mapped_File_Board, hscp_name = case_when(
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
          hbr == "Z" ~ "NHS Shetland",
          hbr == "O" ~ "Non Scottish Residents")
      )

saveRDS(Final_Mapped_File_Board, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                                          "H&SC Expenditure/data/All-chps-Temp4-","{year}",".rds"))

Final <- bind_rows(Final_Mapped_File, Final_Mapped_File_Board)
Final <- Final %>% mutate(hscp_name = recode(hscp_name, "Dundee" = "Dundee City",
                                             "Edinburgh" = "City of Edinburgh"))

Final <- Final %>% group_by(YEAR, hbr,hscp_name, AGEGROUP, service,
                            Sector, Sub_Sector, Detail_Sector) %>%
  summarise(Expenditure = sum(Expenditure)) %>%
  ungroup()

Final <- filter(Final, hbr != "D")
Final <- Final %>% mutate(hscp_name = recode(hscp_name, "Argyll and Bute" = "Argyll & Bute",
                                             "Dumfries and Galloway" = "Dumfries & Galloway",
                                             "Orkney Islands" = "Orkney",
                                             "Shetland Islands" = "Shetland"))

saveRDS(Final, file = glue("/conf/sourcedev/TableauUpdates/H&SC Expenditure/",
                          "H&SC Expenditure/data/All-chps-Final-","{year}",".rds"))
