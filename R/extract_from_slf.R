#' Extract the correct variables for Source workbooks from the Source Linkage Files
#'
#' @description A wrapper around [slfhelper::read_slf_individual] and [slfhelper::read_slf_episode] that
#' defines the columns to be extracted based on pre-defined list within bluenile
#'
#' @param year The year or years to be extracted, in "XXYY" format
#' @param workbook_name A valid workbook name from [bluenile::workbook_names]
#' @param sub_name For HRI Pathways and HRI Main, specification of which part is being worked on
#'
#' @export
#'
#' @examples x <- utils::head(extract_from_slf(year = "1819", workbook_name = "HRI", sub_name = "main"), 1000)
extract_from_slf <- function(year, workbook_name, sub_name) {
  if (workbook_name %in% names(bluenile::variables_to_extract)) {
    if (workbook_name == "HRIPathways" | workbook_name == "HRI") {
      slfhelper::read_slf_individual(
        year = year,
        columns = bluenile::variables_to_extract[[{{ workbook_name }}]][[{{ sub_name }}]]
      )
    } else if (workbook_name == "HRILTC") {
      slfhelper::read_slf_individual(year = year, columns = bluenile::variables_to_extract[[{{ workbook_name }}]])
    } else {
      slfhelper::read_slf_episode(year = year, columns = bluenile::variables_to_extract[[{{ workbook_name }}]])
    }
  } else {
    stop("Not a valid workbook name. See bluenile::workbook_names for a list of valid options")
  }
}
