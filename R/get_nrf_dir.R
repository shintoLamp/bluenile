#' Source lookup directory - National Reference Files
#'
#' @description File path for the general PHS directory for National References Files
#'
#' @return The path to the NRFs as an [fs::path]
#' @export
#'
#' @family Directories
get_nrf_dir <- function() {
  nrf_dir <- fs::path("/conf/linkage/output/lookups/Unicode/National Reference Files")

  return(nrf_dir)
}
