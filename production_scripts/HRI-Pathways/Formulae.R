library(slfhelper)
library(dplyr)
library(haven)
library(stringr)
library(magrittr)
library(tidylog)
library(lubridate)
library(glue)
library(tictoc)
library(purrr)
library(readr)
library(data.table)
library(dtplyr)

# Define the names of the age groups
age_groups <- c("<18", "18-44", "45-64", "65-74", "75-84", "85+")
# Define the variables to extract from the SLF Individual file
extract_variables <- c(
  "anon_chi", "lca", "gender", "age", "hri_scot", "nsu", "death_date", "hri_lcap",
  "deceased", "health_net_cost"
)
# Define the variables we need for the full summary
summary_categoricals <- c("year", "anon_chi", "age", "gender", "death_date", "hri_scot", "nsu")
summary_measures <- c("health_net_cost", "acute_episodes", "acute_inpatient_beddays", "acute_cost", 
                      "mat_episodes", "mat_inpatient_beddays", "mat_cost", 
                      "mh_episodes", "mh_inpatient_beddays", "mh_cost", 
                      "gls_episodes", "gls_inpatient_beddays", "gls_cost", 
                      "op_newcons_attendances", "op_cost_attend", "ae_attendances", "ae_cost", 
                      "pis_dispensed_items", "pis_cost")
summary_others <- c("deceased_flag", "deceased_flag_in_year", 
                    "acute_ind", "mat_ind", "mh_ind", "gls_ind", "out_ind", "ae_ind", "pis_ind", "no_ltc")
ltc_names <- slfhelper::ltc_vars %>% discard(~ .x %in% c("congen", "bloodbfo", "endomet", "digestive"))
ltc_output_vars <- union(slfhelper::ltc_vars %>% keep(~ .x %in% c("arth", "cancer", "diabetes", "epilepsy")),
                         c("cardiovascular", "neurodegenerative", "respiratory", "other_organs", "no_ltc"))

# Names the HRI groups in English
hri_group_names <- function(df) {
  df %>% mutate(
    hri_group = case_when(
      df$hri_lcap < 50 ~ "High",
      df$hri_lcap >= 50 & hri_lcap < 65 ~ "High to Medium",
      df$hri_lcap >= 65 & hri_lcap < 80 ~ "Medium",
      df$hri_lcap >= 80 & hri_lcap < 95 ~ "Medium to Low",
      df$hri_lcap >= 95 ~ "Low"
    )
  )
}

# Repeatable function for each financial year, to save space
pathways_wrangle <- function(finyear) {
  # Read in the Source Individual File
  return_df <- read_slf_individual(finyear, columns = extract_variables) %>%
    # Remove undefined gender, missing hri_scot and non service users
    filter(gender != 0 & hri_scot != 9 & nsu != 1) %>%
    # Under advice from SLF team, if hri_lcap is NA then the user in question is a non-Scottish resident,
    # which we would like to exclude
    filter(!is.na(hri_lcap)) %>%
    # Assign names to HRI Groups
    hri_group_names() %>%
    # Do the same with the ages
    mutate(age_group = cut(age,
                           breaks = c(-1, 17, 44, 64, 74, 84, max(age)),
                           labels = age_groups
    )) %>%
    # Aggregate without dropping variables, we want the min and max healthcare cost
    # by the below break variables
    lazy_dt() %>% 
    group_by(age_group, gender, hri_group, lca) %>%
    mutate(
      cost_min = min(health_net_cost),
      cost_max = max(health_net_cost),
      individuals = n()
    ) %>%
    ungroup() %>%
    as_tibble() %>% 
    select(-age, -hri_scot, -nsu, -hri_lcap) %>%
    # Rename the non-matching variables with the financial year as a suffix
    rename_at(vars(-anon_chi, -age_group, -gender), paste0, str_c("_", finyear))
  return(return_df)
}

# Function to find the pathways for individuals in each partnership
pathway_lookup_chi <- function(df, la_code) {
  return_df <- 
    df %>%
    # First, create a column that only contains the 2-digit LCA code of the chosen partnership
    mutate(x = la_code) %>%
    # Create lcaflag, which is true when an individual has received treatment in the 
    # chosen partnership in any of the financial years
    mutate(lcaflag = case_when(
      lca_1718 == x ~ TRUE,
      lca_1819 == x ~ TRUE,
      lca_1920 == x ~ TRUE,
      lca_2021 == x ~ TRUE,
      TRUE ~ FALSE
    )) %>%
    # Filter the larger df down to only these cases
    filter(lcaflag == TRUE) %>%
    # The following case_when statement is repeated four times, one for each financial year.
    # We are recoding the hri_group_XXXX variable to reflect different scenarios
    # 1. When the LCA in the year is not the same as the one we defined, code as "Not in LA"
    # 2. When the individual died before the start of the financial year, code as "Died"
    # 3. When the hri_group variable is empty, code as "No Contact"
    mutate(
      hri_group_1718 = case_when(
        lca_1718 != x ~ "Not in LA",
        hri_group_1718 == "" ~ "No Contact",
        is.na(hri_group_1718) ~ "No Contact",
        TRUE ~ hri_group_1718
      ),
      hri_group_1819 = case_when(
        lca_1819 != x ~ "Not in LA",
        death_date < ymd(20180401) ~ "Died",
        hri_group_1819 == "" ~ "No Contact",
        is.na(hri_group_1819) ~ "No Contact",
        TRUE ~ hri_group_1819
      ),
      hri_group_1920 = case_when(
        lca_1920 != x ~ "Not in LA",
        death_date < ymd(20190401) ~ "Died",
        hri_group_1920 == "" ~ "No Contact",
        is.na(hri_group_1920) ~ "No Contact",
        TRUE ~ hri_group_1920
      ),
      hri_group_2021 = case_when(
        lca_2021 != x ~ "Not in LA",
        death_date < ymd(20200401) ~ "Died",
        death_date > ymd(20200401) & (hri_group_2021 == "" | is.na(hri_group_2021)) ~ "Died",
        hri_group_2021 == "" ~ "No Contact",
        is.na(hri_group_2021) ~ "No Contact",
        TRUE ~ hri_group_2021
      ),
      # Another recode to handle the situation where someone dies outside of the LCA
      hri_group_1819 = if_else(hri_group_1819 == "Died" & hri_group_1718 == "Not in LA", "Not in LA", hri_group_1819),
      hri_group_1920 = if_else(hri_group_1920 == "Died" & hri_group_1819 == "Not in LA", "Not in LA", hri_group_1920),
      hri_group_2021 = if_else(hri_group_2021 == "Died" & hri_group_1920 == "Not in LA", "Not in LA", hri_group_2021)) %>% 
    # We assign zero values to the health net cost of that year if the person has died or are not in the LCA  
    mutate(
      health_net_cost_1718 = if_else(hri_group_1718 == "Not in LA" | hri_group_1718 == "Died",
                                     0, health_net_cost_1718),
      health_net_cost_1819 = if_else(hri_group_1819 == "Not in LA" | hri_group_1819 == "Died",
                                     0, health_net_cost_1819),
      health_net_cost_1920 = if_else(hri_group_1920 == "Not in LA" | hri_group_1920 == "Died",
                                     0, health_net_cost_1920),
      health_net_cost_2021 = if_else(hri_group_2021 == "Not in LA" | hri_group_2021 == "Died",
                                     0, health_net_cost_2021)
    ) %>% 
    # Create a variable to describe the pathway of the group (could be done in Tableau, for review)
    mutate(pathway_lkp = str_c(hri_group_1718, hri_group_1819, hri_group_1920, hri_group_2021, sep = ", "),
           # Quick transformation to avoid Inf values if there is no min/max cost
           across(contains("cost_m"), ~replace_na(.x, 0)))
  return(return_df)
}

# This function aggregates the chi-level lookup to lca level
lca_aggregate <- function(df) {
  return_df <- df %>% 
    lazy_dt() %>% 
    # Aggregate by the following variables
    group_by(x, gender, age_group, hri_group_1718, hri_group_1819, hri_group_1920, hri_group_2021, pathway_lkp) %>% 
    # Take the sum of the net costs and minimum/maximum of those measures
    summarise(across(contains("health"), sum, na.rm = TRUE),
              across(contains("min"), min, na.rm = TRUE),
              across(contains("max"), max, na.rm = TRUE),
              size = n(),
              .groups = "keep") %>% 
    as_tibble()
  return(return_df)
}

# This function turns each chi-level frame into a lookup to be matched on for the summary
lca_chi_aggregate <- function(df) {
  return_df <- df %>% 
    lazy_dt() %>% 
    group_by(anon_chi, x, pathway_lkp, hri_group_1718, hri_group_1819, hri_group_1920, hri_group_2021) %>% 
    summarise(recs = n(), .groups = "keep") %>% 
    ungroup() %>% 
    as_tibble() %>% 
    select(-recs)
  return(return_df)
}

# Function to define, sum, and create variables for LTCs
sort_out_ltcs <- function(df) {
  return_df <- df %>% 
    mutate(no_ltc = !reduce(select(., cvd:ms), `|`), 
           num_ltc = rowSums(across(ltc_names))) %>% 
    mutate(cardiovascular = reduce(select(., c("atrialfib", "chd", "cvd", "hefailure")), `|`),
           neurodegenerative = reduce(select(., c("dementia", "ms", "parkinsons")), `|`),
           respiratory = reduce(select(., c("asthma", "copd")), `|`),
           other_organs = reduce(select(., c("liver", "refailure")), `|`)) %>% 
    mutate(num_ltc_char = case_when(
      num_ltc %in% c(0:5) ~ as.character(num_ltc),
      num_ltc >= 6 ~ "6+"
    ))
}

# Function that gets the SLF, wrangles it a bit, matches on the pathways, and aggregates to LCA level
summary_wrangle <- function(finyear, deathdate, matching_df) {
  printout <- paste0(finyear, matching_df, " - Done")
  hri_group_name <- paste0("hri_group_", finyear)
  # Read in the Source Individual File
  return_df <- read_slf_individual(finyear, columns = union_all(union_all(summary_categoricals, summary_measures), ltc_names)) %>%
    # Remove undefined gender, missing hri_scot and non service users
    filter(gender != 0 & hri_scot != 9 & nsu != 1) %>%
    # Remove cases where death occurred before the start of financial year
    mutate(flag = case_when(
      death_date < deathdate ~ TRUE,
      death_date == NA_Date_ ~ FALSE,
      TRUE ~ FALSE)) %>% 
    filter(flag == FALSE) %>% 
    # Add in age groups
    mutate(age_group = cut(age,
                           breaks = c(-1, 17, 44, 64, 74, 84, max(age)),
                           labels = age_groups),
           # Make number of individuals variables for different services
           acute_ind = acute_episodes >= 1,
           mat_ind = mat_episodes >= 1,
           mh_ind = mh_episodes >= 1,
           gls_ind = gls_episodes >= 1,
           out_ind = op_newcons_attendances >= 1,
           ae_ind = ae_attendances >= 1,
           pis_ind = pis_dispensed_items >= 1) %>% 
    # Drop unneeded variables
    select(-flag) %>% 
    # Join on the pathway lookup
    left_join(., matching_df, by = "anon_chi") %>%
    sort_out_ltcs() %>% 
    mutate(deceased_flag = case_when(
      death_date < deathdate ~ TRUE,
      death_date == NA_Date_ ~ FALSE,
      {{hri_group_name}} == "Not in LA" ~ FALSE,
      death_date >= deathdate & {{hri_group_name}} == "Died" ~ TRUE,
      TRUE ~ FALSE),
      deceased_flag_in_year = case_when(
        death_date >= deathdate & death_date <= (deathdate + years(1) - days(1)) ~ TRUE,
        death_date == NA_Date_ ~ FALSE,
        TRUE ~ FALSE
      )) %>% 
    # Aggregate the whole thing to lca level
    lazy_dt() %>% 
    group_by(x, year, gender, pathway_lkp, age_group, 
             num_ltc_char, hri_group_1718, hri_group_1819, hri_group_1920, hri_group_2021) %>% 
    summarise(across(union_all(union_all(summary_measures, summary_others), ltc_output_vars), 
                     sum, na.rm = TRUE),
              num_ind = n()) %>% 
    as_tibble()
  return(return_df)
  print(printout)
}

# Do the summary
do_the_summary <- function(lca_name) {
  return_df <- bind_rows(
  summary_wrangle("1718", ymd(20170401), chi_lookups[[lca_name]]),
  summary_wrangle("1819", ymd(20180401), chi_lookups[[lca_name]]),
  summary_wrangle("1920", ymd(20190401), chi_lookups[[lca_name]]),
  summary_wrangle("2021", ymd(20200401), chi_lookups[[lca_name]]))
  return(return_df)
}

# Get lookup and apply standard LCA names and codes for security filters
lcanames_and_codes <- function(df) {
  lookup <- read_rds("/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20220630.rds") %>% 
    distinct(ca2019name, ca2011) %>% 
    mutate(ca2019name = case_when(
      ca2019name == "Na h-Eileanan Siar" ~ "Western Isles",
      TRUE ~ ca2019name)) %>% 
    rename(la_code = ca2011) %>% 
    add_row(ca2019name = "Clackmannanshire and Stirling", la_code = "S12000005")
  return_df <- df %>% mutate(lcaname = str_to_title(str_replace_all(lcaname, "_", c("_" = " ")))) %>% 
    mutate(lcaname = str_replace_all(lcaname, c(" And " = " and ", " Of " = " of ")))
  return_df <- left_join(return_df, lookup, by = c("lcaname" = "ca2019name"))
  return(return_df)
}

# Make small extracts for use in Tabstore
tabstore <- function(dataset, workbookname) {
  small <- dplyr::distinct(dataset, lcaname, .keep_all = TRUE)
  haven::write_sav(small, stringr::str_glue(workbookname, "-Small.sav"))
}