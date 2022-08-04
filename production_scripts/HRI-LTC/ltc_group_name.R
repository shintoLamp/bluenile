
ltc_grp_name <- function(ltc_name){
  
    case_when(
      ltc_name %in% c("dementia", "ms", "parkinsons")  ~ "Neurodegenerative - Grp",
      ltc_name %in% c("atrialfib", "chd", "cvd", "hefailure") ~ "Cardio - Grp",
      ltc_name %in% c("asthma", "copd")  ~ "Respiratory - Grp",
      ltc_name %in% c("liver", "refailure")  ~ "Other Organ - Grp"
    )
  
}