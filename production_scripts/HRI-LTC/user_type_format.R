
user_type_format <- function(user_name){
  
  case_when(
    
    user_name == "lca-hri_50" ~ "HRI 50%",
    user_name == "lca-hri_65" ~ "HRI 65%",
    user_name == "lca-hri_80" ~ "HRI 80%",
    user_name == "lca-hri_95" ~ "HRI 95%",
    user_name == "Other Service Users" ~ "Other Service Users"
  )
  
}