### 1 - Setup environment and load functions ----
source(here::here("code", "00_setup-environment.R"))

#Read in mapped file and select out latest year only, dashboard only displays latest years information
AEpart4 <- read_sav("/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav")
AEpart4202021 <- filter(AEpart4, year == "202021")

#Read in combined program and locality files
AEprogram <- read_sav("/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav")
AElocality <- read_sav("/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav")

#Combine all files together
Final <- bind_rows(AEpart4202021, AEprogram, AElocality)

#Alter LCAcode variable to match lca so blanks can be filled in
Final <- Final %>% mutate_at("LCAcode", str_replace, "01", "1")
Final <- Final %>% mutate_at("LCAcode", str_replace, "02", "2")
Final <- Final %>% mutate_at("LCAcode", str_replace, "03", "3")
Final <- Final %>% mutate_at("LCAcode", str_replace, "04", "4")
Final <- Final %>% mutate_at("LCAcode", str_replace, "05", "5")
Final <- Final %>% mutate_at("LCAcode", str_replace, "06", "6")
Final <- Final %>% mutate_at("LCAcode", str_replace, "07", "7")
Final <- Final %>% mutate_at("LCAcode", str_replace, "08", "8")
Final <- Final %>% mutate_at("LCAcode", str_replace, "09", "9")

#Fill in blank lca cases
Final <- Final %>% mutate(lca = case_when(is.na(lca) ~ LCAcode, TRUE ~ lca))

#Remove datazones assigned to wrong lca
Final <- Final %>% mutate(
  flag = if_else((datazone == "S01011696" & lca == 17)|
                (datazone == "S01008416" & lca == 17)|
                (datazone == "S01006959" & lca == 1)|
                  (datazone == "S01006950" & lca == 1)|
                  (datazone == "S01006927" & lca == 1)|
                  (datazone == "S01006506" & lca == 2)|
                  (datazone == "S01011974" & lca == 3)|
                  (datazone == "S01007774" & lca == 3)|
                  (datazone == "S01007133" & lca == 9)|
                  (datazone == "S01007141" & lca == 9)|
                  (datazone == "S01007137" & lca == 9)|
                  (datazone == "S01012539" & lca == 10)|
                  (datazone == "S01009763" & lca == 11)|
                  (datazone == "S01009960" & lca == 11)|
                  (datazone == "S01013298" & lca == 14)|
                  (datazone == "S01008029" & lca == 22)|
                  (datazone == "S01007129" & lca == 25)|
                  (datazone == "S01010816" & lca == 26)|
                  (datazone == "S01008303" & lca == 26)|
                  (datazone == "S01007875" & lca == 28)|
                  (datazone == "S01007358" & lca == 7)|
                  (datazone == "S01008099" & lca == 17)|
                  (datazone == "S01006946" & lca == 1)|
                  (datazone == "S01006608" & lca == 1)|
                  (datazone == "S01006931" & lca == 1)|
                  (datazone == "S01011059" & lca == 1)|
                  (datazone == "S01007133" & lca == 9)|
                  (datazone == "S01007137" & lca == 9)|
                  (datazone == "S01012823" & lca == 17)|
                  (datazone == "S01011701" & lca == 17)|
                  (datazone == "S01008107" & lca == 17)|
                  (datazone == "S01010930" & lca == 5)|
                  (datazone == "S01012820" & lca == 29)|
                  (datazone == "S01009071" & lca == 23)|
                  (datazone == "S01010153" & lca == 23)|
                  (datazone == "S01011703" & lca == 23)|
                  (datazone == "S01007141" & lca == 9)|
                  (datazone == "S01007134" & lca == 9)|
                  (datazone == "S01009763" & lca == 13)|
                  (datazone == "S01007358" & lca == 7), 1, 0, missing = 0)
)
count(Final, flag)

#Select out recrods where datazone has been assigned incorrectly
Final <- filter(Final, flag != 1)
Final <- select(Final, -flag)

#Links Health Centre has been included as part of A&E activity in error, remove these records
Final <- filter(Final, Locname != "Links Health Centre")

#Update year variable, include forward slash
Final <- Final %>% mutate(year = case_when(
                                year == 201718 ~ "2017/18",
                                year == 201819 ~ "2018/19",
                                year == 201920 ~ "2019/20",
                                year == 202021 ~ "2020/21")
)

#Filter out 'All' and Unknown age groups, as these are no longer required
Final <- filter(Final, agegroup != "All" & agegroup != "")

#Add dummy row
Final <- Final %>% add_row(LCAname = "Please select Partnership", LA_CODE = "S12000046")

#Save out final file
write_sav(Final, here("output", glue("AE_Final.sav")), compress = TRUE)

#Create level 2 data source
Final_LV2 <- filter(Final, data == "Data")
Final_LV2 <- select(Final_LV2, -LCAcode, -LTC_Num, -simd, -Locality)

#Save out final level 2 file
write_sav(Final_LV2, here("output", glue("AE_Final_LV2.sav")), compress = TRUE)