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
#' @importFrom dplyr mutate case_when if_else
#' @importFrom  stringr str_detect str_sub
#'
#' @family Recoding
#'
#' @examples
#' lcaname_to_hb(bluenile::lca_names, lca, region = FALSE)
add_board_from_lcaname <- function(df, lcaname, region = FALSE) {
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
