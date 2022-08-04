HC_PC_Hours <-
  read_csv("/conf/irf/01-CPTeam/02-Functional-outputs/02-Combined Health and Social Care File/Workings/19-20/HC-PC-Hours-19-20.csv",
           col_names = c("LCA", "Agegroup", "HC_Hours", "PC_Hours"),
           col_types = "ccii",
           skip = 1)

HC_PC_Hours <- HC_PC_Hours %>%
  mutate(LCA = recode(LCA, "Edinburgh, City of" = "City of Edinburgh", "Eilean Siar" = "Western Isles"))

data <- HC_PC_Hours %>%
  group_by(LCA) %>%
  mutate(Total_HC_Hours = sum(HC_Hours),
         Total_PC_Hours = sum(PC_Hours)) %>%
  ungroup()

data_OP <- data

data_OP$HC_Hours[data_OP$Agegroup %in% "0-17"] <- 0 
data_OP$PC_Hours[data_OP$Agegroup %in% "0-17"] <- 0 

data_OP <- data_OP %>%
  group_by(LCA) %>%
  mutate(OP_HC_Hours = sum(HC_Hours),
         OP_PC_Hours = sum(PC_Hours)) %>%
  ungroup()

data_OP <- select(data_OP, -HC_Hours, -PC_Hours, -Total_HC_Hours, -Total_PC_Hours)
data <- left_join(data, data_OP, by = c("LCA", "Agegroup"))

data <- mutate(data, HC_share_total = HC_Hours/Total_HC_Hours, PC_share_total = PC_Hours/Total_PC_Hours, 
               HC_share_OP = HC_Hours/OP_HC_Hours, PC_share_OP = PC_Hours/OP_PC_Hours)

saveRDS(data, file = glue("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/",
                            "LCA_Proportion_Shares_HomeCare_PersonalCare_","{year}",".rds"))


Direct_Payments <-
  read_csv("/conf/irf/01-CPTeam/02-Functional-outputs/02-Combined Health and Social Care File/Workings/19-20/Direct-Payments-19-20.csv",
           col_names = c("LCA", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "TOTAL"),
           col_types = "ciiiiiii",
           skip = 1)

Direct_Payments <- Direct_Payments %>%
  mutate(LCA = recode(LCA, "Edinburgh, City of" = "City of Edinburgh", "Eilean Siar" = "Western Isles"))

Direct_Payments <- mutate(Direct_Payments, DP_OP = TOTAL - ONE)

Direct_Payments <- gather(Direct_Payments, "Agegroup", "Direct_Payments", ONE, TWO, THREE, FOUR, FIVE, SIX)
Direct_Payments <- rename(Direct_Payments, Ageband = Agegroup)
Direct_Payments <- mutate(Direct_Payments, Agegroup = case_when(
                          Ageband == "ONE" ~ "0-17",
                          Ageband == "TWO" ~ "18-64",
                          Ageband == "THREE" ~ "0-64",
                          Ageband == "FOUR" ~ "65-74",
                          Ageband == "FIVE" ~ "75-84",
                          Ageband == "SIX" ~ "85+")
)

Direct_Payments <- mutate(Direct_Payments, Proportion_Share_DP = case_when(
                          Agegroup == "0-17" ~ 0, 
                          Agegroup == "18-64" ~ Direct_Payments/DP_OP,
                          Agegroup == "0-64" ~ Direct_Payments/DP_OP,
                          Agegroup == "65-74" ~ Direct_Payments/DP_OP,
                          Agegroup == "75-84" ~ Direct_Payments/DP_OP,
                          Agegroup == "85+" ~ Direct_Payments/DP_OP)
)

saveRDS(Direct_Payments, file = glue("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/",
                          "LCA_Proportion_Shares_DirectPayments_","{year}",".rds"))

Care_Home <-
  read_csv("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA-Care-Home-Proportions-19-20.csv",
           col_names = c("LCA", "Agegroup", "Proportion", "Proportion_65", "Proportion_Care_Home"),
           col_types = "ccccc",
           skip = 1)

Care_Home <- Care_Home %>%
  mutate(LCA = recode(LCA, "Edinburgh, City of" = "City of Edinburgh", "Highlands" = "Highland"))

saveRDS(Care_Home, file = glue("/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/",
                                     "LCA_Proportion_Shares_CH_","{year}",".rds"))