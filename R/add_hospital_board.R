#' Assign Health Board names based on Hospital Location codes
#'
#' @param df The data frame to be mutated
#' @param locationcode The name of the location code variable
#' @param hbcode The name of the existing Health Board code variable
#' @param region When TRUE, returns "XXXX Region", when FALSE returns "NHS XXXX" (default FALSE)
#'
#' @return Data frame
#' @export
#'
#' @family Recoding
#'
#' @examples
#' example_data <- base::data.frame(location = c("A0001", "B0002", "C0004"), hbres = c("", "", "S08000007"))
#' example_data_2 <- add_hospital_board(example_data, location, hbres, region = TRUE)
add_hospital_board <- function(df, locationcode, hbcode, region = FALSE) {
  return <- df %>% dplyr::mutate(
    hosp_board = dplyr::case_when(
      stringr::str_sub({{ locationcode }}, end = 1) == "A" ~ "Ayrshire & Arran",
      stringr::str_sub({{ locationcode }}, end = 1) == "B" ~ "Borders",
      stringr::str_sub({{ locationcode }}, end = 1) == "Y" ~ "Dumfries & Galloway",
      stringr::str_sub({{ locationcode }}, end = 1) == "F" ~ "Fife",
      stringr::str_sub({{ locationcode }}, end = 1) == "V" ~ "Forth Valley",
      stringr::str_sub({{ locationcode }}, end = 1) == "N" ~ "Grampian",
      stringr::str_sub({{ locationcode }}, end = 1) == "G" ~ "Greater Glasgow & Clyde",
      stringr::str_sub({{ locationcode }}, end = 1) == "D" ~ "Golden Jubilee",
      stringr::str_sub({{ locationcode }}, end = 1) == "H" ~ "Highland",
      stringr::str_sub({{ locationcode }}, end = 1) == "L" ~ "Lanarkshire",
      stringr::str_sub({{ locationcode }}, end = 1) == "S" ~ "Lothian",
      stringr::str_sub({{ locationcode }}, end = 1) == "R" ~ "Orkney",
      stringr::str_sub({{ locationcode }}, end = 1) == "Z" ~ "Shetland",
      stringr::str_sub({{ locationcode }}, end = 1) == "T" ~ "Tayside",
      stringr::str_sub({{ locationcode }}, end = 1) == "W" ~ "Western Isles",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S08000007" ~ "Greater Glasgow & Clyde",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S08000008" ~ "Highland",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S27000001" ~ "Private Care"
    )
  )
  if (region == FALSE) {
    return <- return %>% mutate(hosp_board = dplyr::case_when(
      hosp_board != "Private Care" | hosp_board != "Golden Jubilee" ~ stringr::str_c("NHS ", hosp_board),
      TRUE ~ hosp_board
    ))
    return(return)
  } else {
    return <- return %>% mutate(hosp_board = dplyr::case_when(
      hosp_board != "Private Care" | hosp_board != "Golden Jubilee" ~ stringr::str_c(hosp_board, " Region"),
      TRUE ~ hosp_board
    ))
  }
}
