#' Get a lookup of Locations and their Service Types
#'
#' @description The column `service_offered` contains a three-digit code,
#' with each binary digit representing Acute, Community, and Mental Health services.
#' Therefore a code of "101" would be Acute & Mnetal Health, but not Community.
#'
#' @return A [tibble][tibble::tibble-package] with three columns.
#' @export
#'
#' @examples x <- get_hospital_service_types()
get_hospital_service_types <- function() {
  hosp_services <- haven::read_sav("/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/02-PLICS/Hosp_Services.sav") %>%
    # Ensure variable names are in R-friendly format
    janitor::clean_names() %>%
    # Tidy up the variables for recoding later
    dplyr::mutate(dplyr::across(where(is.numeric), ~ as.character(.x))) %>%
    dplyr::mutate(service_offered = stringr::str_c(acute, community, mental_health)) %>%
    dplyr::select(-acute, -community, -mental_health)
  return(hosp_services)
}
