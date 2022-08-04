#' Read in most recent Geography team locality lookup file
#'
#' @description Read in the most recent locality-level lookup file from the Geographies team with specified columns
#'
#'
#' @param suffix A string in "YYYYMMDD" format correlating to most recent geography file
#' @param columns A character vector of columns
#' @param aggregate Should the lookup be aggregated? (default FALSE)
#' @param matching_variable The level to which the lookup should be aggregated
#' @param new_variables The variable(s) you wish to match on to your dataset
#'
#' @return A tibble with the selected columns to use as a lookup
#' @export
#'
#' @examples
#' x <- locality_lookup("20200825", c("datazone2011", "hscp_locality"))
#' y <- x <- get_locality_lookup("20200825", c("ca2019name", "ca2011"), aggregate = TRUE, ca2019name, ca2011)
#'
#' @family Lookups
get_locality_lookup <- function(columns,
                                aggregate = FALSE,
                                matching_variable = NULL,
                                new_variables = NULL) {
  return <- readr::read_rds(
    find_latest_file(directory = "/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/",
                     regexp = "HSCP Localities_DZ11_Lookup_\\d+?\\.rds")
    ) %>%
    dplyr::select(dplyr::all_of(columns))
  if (aggregate == TRUE) {
    return <- return %>%
      dplyr::group_by({{ matching_variable }}) %>%
      dplyr::summarise(dplyr::across({{ new_variables }}, dplyr::first))
    return(return)
  } else {
    return(return)
  }
}
