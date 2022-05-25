#' Read in most recent Geography team locality lookup file
#'
#' @param suffix A string in "YYYYMMDD" format correlating to most recent geography file
#' @param columns A character vector of columns
#'
#' @return A tibble with the selected columns to use as a lookup
#' @export
#'
#' @examples
#' x <- locality_lookup("20200825", c("datazone2011", "hscp_locality"))
#'
#' @importFrom readr read_rds
#' @importFrom magrittr %>%
#' @importFrom janitor clean_names
#' @importFrom dplyr select all_of
#' @importFrom glue glue
locality_lookup <- function(suffix, columns) {
  read_rds(glue("/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_{suffix}.rds")) %>%
    clean_names() %>%
    select(all_of(columns))
}

#' Read in a lookup file for Specialty codes
#'
#' @param columns A vector of columns to pass to dplyr::select.
#' Available columns are "speccode", "description", "grouping"
#'
#' @return A tibble to use as a lookup for specialty groupings
#' @export
#'
#' @examples
#' x <- specialty_lookup(c("speccode", "description"))
#'
#' @importFrom haven read_sav
#' @importFrom dplyr select all_of
#' @importFrom janitor clean_names
specialty_lookup <- function(columns) {
  haven::read_sav("/conf/linkage/output/lookups/Unicode/National Reference Files/Specialty_Groupings.sav") %>%
    janitor::clean_names() %>%
    dplyr::select(dplyr::all_of(columns))
}

#' Function to assign Health Board names based on 5-digit hospital location code
#'
#' @param df The data frame you want to change
#' @param locationcode The name of the location code variable in df
#' @param hbcode The name of the Health Board code in df
#'
#' @return df with one extra column, hosp_board
#' @export
#'
#' @examples
#' example_data <- base::data.frame(location = c("A0001", "B0002", "C0004"), hbres = c("", "", "S08000007"))
#' where_is_hospital(example_data, location, hbres)
where_is_hospital <- function(df, locationcode, hbcode) {
  df %>% dplyr::mutate(
    hosp_board = dplyr::case_when(
      stringr::str_sub({{ locationcode }}, end = 1) == "A" ~ "Ayrshire & Arran Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "B" ~ "Borders Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "Y" ~ "Dumfries & Galloway Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "F" ~ "Fife Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "V" ~ "Forth Valley Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "N" ~ "Grampian Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "G" ~ "Greater Glasgow & Clyde Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "D" ~ "Golden Jubilee",
      stringr::str_sub({{ locationcode }}, end = 1) == "H" ~ "Highland Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "L" ~ "Lanarkshire Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "S" ~ "Lothian Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "R" ~ "Orkney Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "Z" ~ "Shetland Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "T" ~ "Tayside Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "W" ~ "Western Isles Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S08000007" ~ "Greater Glasgow & Clyde Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S08000008" ~ "Highland Region",
      stringr::str_sub({{ locationcode }}, end = 1) == "C" & {{ hbcode }} == "S27000001" ~ "Private Care"
    )
  )
}

#' Assign 9-digit Health Board code based on two-digit LA code
#'
#' @param df The dataframe you wish to mutate
#' @param lcacodename The name of the two-digit LA code variable. Can be formatted as integer or character
#'
#' @return Mutated dataframe, with extra column 'hbres'
#' @export
#'
#' @examples
#' example_data <- base::data.frame(la = c(1, 3, 5, 7))
#' twodigitla_to_hb(example_data, la)
#'
#' example_data_2 <- base::data.frame(la = c("01", "03", "05", "13"))
#' twodigitla_to_hb(example_data_2, la)
twodigitla_to_hb <- function(df, lcacodename) {
  char_or_num <- df %>% is.factor({{lcacodename}}) | is.character({{lcacodename}})
  if (char_or_num == FALSE) {
    return_df <- df %>% dplyr::mutate(
      hbres = dplyr::case_when(
        {{ lcacodename }} == 1 ~ "S08000020",
        {{ lcacodename }} == 2 ~ "S08000020",
        {{ lcacodename }} == 3 ~ "S08000027",
        {{ lcacodename }} == 4 ~ "S08000022",
        {{ lcacodename }} == 5 ~ "S08000016",
        {{ lcacodename }} == 6 ~ "S08000019",
        {{ lcacodename }} == 7 ~ "S08000021",
        {{ lcacodename }} == 8 ~ "S08000017",
        {{ lcacodename }} == 9 ~ "S08000027",
        {{ lcacodename }} == 10 ~ "S08000015",
        {{ lcacodename }} == 11 ~ "S08000021",
        {{ lcacodename }} == 12 ~ "S08000024",
        {{ lcacodename }} == 13 ~ "S08000021",
        {{ lcacodename }} == 14 ~ "S08000024",
        {{ lcacodename }} == 15 ~ "S08000019",
        {{ lcacodename }} == 16 ~ "S08000018",
        {{ lcacodename }} == 17 ~ "S08000021",
        {{ lcacodename }} == 18 ~ "S08000022",
        {{ lcacodename }} == 19 ~ "S08000021",
        {{ lcacodename }} == 20 ~ "S08000024",
        {{ lcacodename }} == 21 ~ "S08000020",
        {{ lcacodename }} == 22 ~ "S08000015",
        {{ lcacodename }} == 23 ~ "S08000023",
        {{ lcacodename }} == 24 ~ "S08000025",
        {{ lcacodename }} == 25 ~ "S08000027",
        {{ lcacodename }} == 26 ~ "S08000021",
        {{ lcacodename }} == 27 ~ "S08000026",
        {{ lcacodename }} == 28 ~ "S08000015",
        {{ lcacodename }} == 29 ~ "S08000023",
        {{ lcacodename }} == 30 ~ "S08000019",
        {{ lcacodename }} == 31 ~ "S08000024",
        {{ lcacodename }} == 32 ~ "S08000028"
      )
    )
  } else {
    return_df <- df %>% dplyr::mutate(
      hbres = dplyr::case_when(
        {{ lcacodename }} == "1" ~ "S08000020",
        {{ lcacodename }} == "2" ~ "S08000020",
        {{ lcacodename }} == "3" ~ "S08000027",
        {{ lcacodename }} == "4" ~ "S08000022",
        {{ lcacodename }} == "5" ~ "S08000016",
        {{ lcacodename }} == "6" ~ "S08000019",
        {{ lcacodename }} == "7" ~ "S08000021",
        {{ lcacodename }} == "8" ~ "S08000017",
        {{ lcacodename }} == "9" ~ "S08000027",
        {{ lcacodename }} == "10" ~ "S08000015",
        {{ lcacodename }} == "11" ~ "S08000021",
        {{ lcacodename }} == "12" ~ "S08000024",
        {{ lcacodename }} == "13" ~ "S08000021",
        {{ lcacodename }} == "14" ~ "S08000024",
        {{ lcacodename }} == "15" ~ "S08000019",
        {{ lcacodename }} == "16" ~ "S08000018",
        {{ lcacodename }} == "17" ~ "S08000021",
        {{ lcacodename }} == "18" ~ "S08000022",
        {{ lcacodename }} == "19" ~ "S08000021",
        {{ lcacodename }} == "20" ~ "S08000024",
        {{ lcacodename }} == "21" ~ "S08000020",
        {{ lcacodename }} == "22" ~ "S08000015",
        {{ lcacodename }} == "23" ~ "S08000023",
        {{ lcacodename }} == "24" ~ "S08000025",
        {{ lcacodename }} == "25" ~ "S08000027",
        {{ lcacodename }} == "26" ~ "S08000021",
        {{ lcacodename }} == "27" ~ "S08000026",
        {{ lcacodename }} == "28" ~ "S08000015",
        {{ lcacodename }} == "29" ~ "S08000023",
        {{ lcacodename }} == "30" ~ "S08000019",
        {{ lcacodename }} == "31" ~ "S08000024",
        {{ lcacodename }} == "32" ~ "S08000028"
      )
    )
  }
  return(return_df)
}

#' Assign Health Board name based on Local Authority name
#'
#' @description This function should pick up all common variations in LCA name, such as 'City of Edinburgh'
#' vs 'Edinburgh City'. Any non-matching LCA names will return 'Other Non-Scottish Residents'
#'
#' @param df The dataframe you want to mutate
#' @param lcaname The name of the LCA variable
#' @param region If FALSE, returns Health Board in "NHS XXXXXX". If TRUE, returns "XXXXXX Region"
#'
#' @return Dataframe with an extra column named hb
#' @export
#'
#' @examples
#' lcaname_to_hb(bluenile::lca_names, lca, region = FALSE)
lcaname_to_hb <- function(df, lcaname, region = FALSE) {
    return_df <- df %>% dplyr::mutate(
      hb = dplyr::case_when(
        stringr::str_detect({{ lcaname }}, "(?i)Ayrshire") ~ "NHS Ayrshire & Arran",
        stringr::str_detect({{ lcaname }}, "(?i)Borders") ~ "NHS Borders",
        stringr::str_detect({{ lcaname }}, "(?i)Dumfries") ~ "NHS Dumfries & Galloway",
        stringr::str_detect({{ lcaname }}, "(?i)Fife") ~ "NHS Fife",
        stringr::str_detect({{ lcaname }}, "(?i)Clack") | stringr::str_detect({{ lcaname }}, "(?i)Falk") | stringr::str_detect({{ lcaname }}, "(?i)Stir") ~ "NHS Forth Valley",
        stringr::str_detect({{ lcaname }}, "(?i)Aber") | stringr::str_detect({{ lcaname }}, "(?i)Moray") | stringr::str_detect({{ lcaname }}, "(?i)Gramp") ~ "NHS Grampian",
        stringr::str_detect({{ lcaname }}, "(?i)Dunbar") | stringr::str_detect({{ lcaname }}, "(?i)Renfrew") | stringr::str_detect({{ lcaname }}, "(?i)Glasgow") |
          stringr::str_detect({{ lcaname }}, "(?i)Inver") ~ "NHS Greater Glasgow & Clyde",
        stringr::str_detect({{ lcaname }}, "(?i)Argyll") | stringr::str_detect({{ lcaname }}, "(?i)Highland") ~ "NHS Highland",
        stringr::str_detect({{ lcaname }}, "(?i)Lanark") ~ "NHS Lanarkshire",
        stringr::str_detect({{ lcaname }}, "(?i)Edinburgh") | stringr::str_detect({{ lcaname }}, "(?i)Lothian") ~ "NHS Lothian",
        stringr::str_detect({{ lcaname }}, "(?i)Ork") ~ "NHS Orkney",
        stringr::str_detect({{ lcaname }}, "(?i)Shet") ~ "NHS Shetland",
        stringr::str_detect({{ lcaname }}, "(?i)Ang") | stringr::str_detect({{ lcaname }}, "(?i)Dund") | stringr::str_detect({{ lcaname }}, "(?i)Perth") ~ "NHS Tayside",
        stringr::str_detect({{ lcaname }}, "(?i)Western") | stringr::str_detect({{ lcaname }}, "(?i)Siar") ~ "NHS Western Isles",
        TRUE ~ "Other Non Scottish Residents"
      )
    )
  if (region == TRUE) {
      return_df <- return_df %>% dplyr::mutate(hb = dplyr::if_else(hb != "Other Non Scottish Residents", base::paste0(stringr::str_sub(hb, 4, -1), " Region"), hb))
  }}

