library(slfhelper)
library(dplyr)
library(scales)
library(stringr)
library(haven)
library(glue)
library(tidylog)
library(phsmethods)
library(magrittr)

# Lookup for supressing Health Board codes
hbcode_lookup <- data.frame(
  hbrescode = glue("S080000{as.character(c(23, 28, 24, 26, 16, 25, 19, 21, 15, 30, 17, 29, 22, 20))}"),
  hb_tab_code = glue("HBVC{as.character(c(1:14))}")
)

# Lookup for supressing Local Authority codes
lacode_lookup <- data.frame(
  ca2018 = paste("S120000", 
                 c("08","47","18","17","20","19","48","13","27","21","26","11","39","29","34","36","40","05","30","06","28","45","46","35","33","23","10","42","14","41","38","44"),
                 sep = ""),
  la_tab_code = glue("LAVC{as.character(c(1:32))}"))

valid_council_names <- c(
  "Aberdeen City", "Aberdeenshire", "Angus", "Argyll and Bute", "Dundee City", "East Ayrshire",
  "East Dunbartonshire", "East Renfrewshire", "Glasgow City", "Inverclyde", "North Ayrshire",
  "North Lanarkshire", "Renfrewshire", "South Ayrshire", "South Lanarkshire", "West Dunbartonshire",
  "Fife", "Highland", "Moray", "Orkney Islands", "Scottish Borders", "Shetland Islands", "Na h-Eileanan Siar",
  "Perth and Kinross", "City of Edinburgh", "West Lothian", "Midlothian", "East Lothian", "Dumfries and Galloway",
  "Clackmannanshire", "Stirling", "Falkirk", "Clackmannanshire and Stirling"
)

# Uses user_type to determine HRI grouping and Service Type
assign_thresholds <- function(df) {
  mutate(df, user_type = str_c("HRI Threshold ", word(type, -1, sep = "_"), "%"),
         service_type = word(type, 1, sep = "_"),
         user_type = if_else(user_type == "HRI Threshold all%", "All Service users", user_type),
         all_patient_flag = user_type == "All Service users",
         hri50_flag = str_detect(user_type, "50"),
         hri65_flag = str_detect(user_type, "65"),
         hri80_flag = str_detect(user_type, "80"),
         hri95_flag = str_detect(user_type, "95"))
}

# Create standard age bandings
age_bands <- function(df) {
  df %>% mutate(
    ageband = case_when(
      age < 18 ~ "<18",
      between(age, 18, 44) ~ "18-44",
      between(age, 45, 64) ~ "45-64",
      between(age, 65, 74) ~ "65-74",
      between(age, 75, 84) ~ "75-84",
      age >= 85 ~ "85+",
      TRUE ~ "Missing"
    )
  )
}

# Uses the HRI variables from SLFs to give flags to HRI thresholds
hri_percentage_flags <- function(df) {
  df %>% mutate(
  lca_flag_50 = (df$hri_lcap <= 50),
  lca_flag_65 = (df$hri_lcap <= 65),
  lca_flag_80 = (df$hri_lcap <= 80),
  lca_flag_95 = (df$hri_lcap <= 95),
  hb_flag_50 = (df$hri_hbp <= 50),
  hb_flag_65 = (df$hri_hbp <= 65),
  hb_flag_80 = (df$hri_hbp <= 80),
  hb_flag_95 = (df$hri_hbp <= 95),
  scot_flag_50 = (df$hri_scotp <= 50),
  scot_flag_65 = (df$hri_scotp <= 65),
  scot_flag_80 = (df$hri_scotp <= 80),
  scot_flag_95 = (df$hri_scotp <= 95))
}

# Names the HRI groups in English
hri_group_names <- function(df) {
  df %>% mutate(
  hri_group = case_when(
    df$hri_lcap < 50 ~ "High",
    df$hri_lcap >= 50 & hri_lcap < 65 ~ "High to Medium",
    df$hri_lcap >= 65 & hri_lcap < 80 ~ "Medium",
    df$hri_lcap >= 80 & hri_lcap < 95 ~ "Medium to Low",
    df$hri_lcap >= 95 ~ "Low"))
}

# Adds different types of episodes/beddays together to determine the totals for 
# the 'all service type' group
all_group_sum <- function(df) {
  df %>% mutate(
    episodes_attendances =
      acute_episodes + mh_episodes + gls_episodes +
      mat_episodes + op_newcons_attendances + ae_attendances + pis_dispensed_items,
    beddays =
      acute_inpatient_beddays + mh_inpatient_beddays + gls_inpatient_beddays + 
      mat_inpatient_beddays
  )
}

# Aggregate for the overtable on DB1
overtable <- function(df) {
  return_df <-
    df %>%
    arrange(year, lca, ageband, hri_group) %>%
    group_by(year, lca, ageband, hri_group) %>%
    summarise(
      health_expenditure_cost_min = min(health_net_cost),
      health_expenditure_cost_max = max(health_net_cost),
      health_expenditure_cost = sum(health_net_cost),
      individuals = n(),
      .groups = "keep"
    ) %>%
    ungroup() %>% 
    group_by(year, lca, ageband) %>% 
    mutate(individuals_sum = sum(individuals)) %>% 
    ungroup() %>% 
    mutate(percentage_pop = round((individuals/individuals_sum) * 100, 1),
           average_cost = health_expenditure_cost/individuals)
  return(return_df)
}

# Function to create the chart data for DB1
overchart <- function(df) {
  return_df <-
    df %>%
    # Make sure the df is in order
    arrange(year, lca, ageband, hri_lcap) %>%
    group_by(year, lca, ageband) %>%
    mutate(
      # Get the number of service users
      service_users = n(),
      # Calculate the inverse
      ind_per = (1 / service_users) * 100,
      # Get the percentage of service users
      lca_rpercent = cumsum(ind_per)
    ) %>%
    # We want to perform the following on each lca individually
    split(.$lca) %>%
    purrr::map_dfr(~
    mutate(.x,
      # Round the lca_rpercent to 1dp
      pop_rounded = round(lca_rpercent, 1),
      # Make sure the lowest value is 0.1
      pop_rounded = if_else(pop_rounded < 0.1, 0.1, pop_rounded),
      # Flag when the hri_group has changed
      flag = hri_group != lag(hri_group),
      flag = if_else(is.na(flag), FALSE, flag)
    ) %>%
      group_by(year, lca, ageband) %>%
      # We will need to increment some values of pop_rounded so that we don't have 
      # a situation where two hri groups have the same population figure
      mutate(increment = cumsum(flag) * 0.1) %>%
      select(year, lca, ageband, hri_group, pop_rounded, flag, increment, health_net_cost)) %>%
    # Add the increment to each value of pop_rounded
    mutate(population = pop_rounded + increment) %>%
    # Population can only be maximum 100%
    mutate(population = if_else(population > 100, 100, population)) %>%
    group_by(year, lca, ageband, hri_group, population) %>%
    # Aggregate to get the health cost for each hri group and population %
    summarise(across(health_net_cost, sum, na.rm = TRUE), .groups = "keep") %>%
    group_by(year, lca, ageband) %>%
    # Get the rolling sum of health cost, and the overall total
    mutate(
      rtotal_exp = cumsum(health_net_cost),
      health_cost_total = sum(health_net_cost)
    ) %>%
    ungroup() %>%
    # Get the rolling percentage total of healthcare cost
    mutate(rtotal_exp_percent = (rtotal_exp / health_cost_total) * 100)
  return(return_df)
}

# Recoding LCA codes
lca_to_lcaname <- function(df) {return_df <- df %>%
  mutate(lcaname = str_to_title(case_when(
    lca == "01" ~ "aberdeen city",
    lca == "02" ~ "aberdeenshire",
    lca == "03" ~ "angus",
    lca == "04" ~ "argyll & bute",
    lca == "05" ~ "scottish borders",
    lca == "06" ~ "clackmannanshire",
    lca == "07" ~ "west dunbartonshire",
    lca == "08" ~ "dumfries and galloway",
    lca == "09" ~ "dundee city",
    lca == "10" ~ "east ayrshire",
    lca == "11" ~ "east dunbartonshire",
    lca == "12" ~ "east lothian",
    lca == "13" ~ "east renfrewshire",
    lca == "14" ~ "edinburgh city",
    lca == "15" ~ "falkirk",
    lca == "16" ~ "fife",
    lca == "17" ~ "glasgow_city",
    lca == "18" ~ "highland",
    lca == "19" ~ "inverclyde",
    lca == "20" ~ "midlothian",
    lca == "21" ~ "moray",
    lca == "22" ~ "north ayrshire",
    lca == "23" ~ "north lanarkshire",
    lca == "24" ~ "orkney islands",
    lca == "25" ~ "perth & kinross",
    lca == "26" ~ "renfrewshire",
    lca == "27" ~ "shetland islands",
    lca == "28" ~ "south ayrshire",
    lca == "29" ~ "south lanarkshire",
    lca == "30" ~ "stirling",
    lca == "31" ~ "west lothian",
    lca == "32" ~ "western isles"
  )))
return(return_df)}

# Small extracts for Tabstore
tabstore <- function(df, lcavariable, workbookname) {
  small <- dplyr::distinct(df, {{ lcavariable }}, .keep_all = TRUE)
  haven::write_sav(small, stringr::str_glue(workbookname, "_Small.sav"))
}
