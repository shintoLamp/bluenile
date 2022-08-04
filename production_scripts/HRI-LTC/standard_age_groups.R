
standard_age_groups <- function(age_variable){
  
    case_when(
      age_variable %in% 0:17 ~ "<18",
      age_variable %in% 18:44 ~ "18-44",
      age_variable %in% 45:64 ~ "45-64",
      age_variable %in% 65:74 ~ "65-74",
      age_variable %in% 75:84 ~ "75-84",
      age_variable >= 85 ~ "85+",
      TRUE ~ "Missing"
    )
  
}