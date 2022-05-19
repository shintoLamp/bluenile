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
#' @importFrom dplyr select
#' @importFrom glue glue
locality_lookup <- function(suffix, columns) {
  read_rds(glue("/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_{suffix}.rds")) %>%
    clean_names() %>%
    select(columns)
}
