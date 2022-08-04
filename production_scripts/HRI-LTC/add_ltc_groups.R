
add_ltc_groups <- function(ltc_variable){
  
    case_when(
      ltc_variable == 0  ~ "0",
      ltc_variable == 1  ~ "1",
      ltc_variable == 2  ~ "2",
      ltc_variable == 3  ~ "3",
      ltc_variable == 4  ~ "4",
      ltc_variable > 4  ~ "5+"
    )
  
}