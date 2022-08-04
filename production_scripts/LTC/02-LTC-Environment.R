############################################################
## Code name - LTC_environment.R                          ##
## Description - Defines functions for LTC workbook       ##
## Written by: Bateman McBride                            ##
## First written: August 2021                             ##
## Updated:                                               ##
############################################################

## Function for adding 'all' groups, modified for this workbook
add_all_ltc <- function(df, var) {
  # Sorts variables into character type and numerical type, assigns to vector
  categorical_vars <- map_lgl(df, ~is.character(.x) | is.factor(.x))
  # Fills vector with the names of the categorical variables
  categorical_vars <- names(categorical_vars)[categorical_vars]
  
  # Create new data frame
  df_all <- df
  # Put a variable as the value 'All'
  df_all[[var]] <- "All"
  
  df_all %>% 
    # Group by all of the categorical variables
    group_by(across(all_of(categorical_vars))) %>% 
    # Summarise only the numeric variables
    summarise(across(all_of(ltc_names), max, na.rm = TRUE), 
              across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE))
}

# Function to select when the given {ltcname} is 1, and aggregate that data frame
ltc_groupings <- function(df, ltcname, colnumber){
  returndf <- df %>% 
    # This is a workaround but it puts the column name at the appropriate position
    # into the 'type' variable
    mutate(type = colnames(df)[{{colnumber}}]) %>% 
    # Select when chosen LTC is 1
    filter({{ltcname}} == 1) %>%
    # Aggregate
    group_by(year, hbrescode, lca, gender, age_grp, patient_type, recid, type) %>% 
    summarise(across(all_of(ltc_names), sum, na.rm = TRUE),
              across(c("cost_total_net", "yearstay"), sum, na.rm = TRUE),
              count = sum({{ltcname}}))
  return(returndf)
}