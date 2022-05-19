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
