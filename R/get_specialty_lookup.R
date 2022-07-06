#' Read in the Specialty Grouping lookup file from National Reference Files
#'
#' @param var_grouping When FALSE, removes the variable 'grouping' (default FALSE)
#'
#' @return A data frame containing specialty codes and the names of the specialties
#' @export
#'
get_specialty_lookup <- function(var_grouping = FALSE) {
  return <- haven::read_sav(fs::path(get_nrf_dir(), "Specialty_Groupings.sav")) %>%
    janitor::clean_names()
  if (var_grouping == FALSE) {
    return <- return %>% select(-grouping)
    return(return)
  } else {return(return)}
}
