#' Filter the SLF Extract based on the workbook data being created
#'
#' @param workbook_name See workbook_names for valid list
#' @param level The security level of the workbook. Valid options are formatted "levelx"
#'
#' @return Filtered dataframe
#' @export
#'
#' @importFrom dplyr filter
#'
#' @examples
#' workbook_name <- "LTC"
#' slfhelper::read_slf_individual("1819", from = 10000, to = 100000) %>% filter_the_slf(workbook_name, "level3")
filter_the_slf <- function(df, workbook_name, level) {
  check <- bluenile::workbook_names
  if (workbook_name %in% check[[level]])
  {if (workbook_name == "A&E"){df %>% dplyr::filter(recid == "AE2")}
  else if (workbook_name == "LTC") {
    df %>% dplyr::filter(recid %in% c("00B", "01B", "02B", "04B", "GLS", "AE2", "PIS")) %>%
    dplyr::filter(hbrescode != "" & ca2018 != "" & anon_chi != "" & gender != 0 & !is.na(age))}
  else if (workbook_name == "HRI") {df %>% dplyr::filter(gender != 0 & hri_lca != 9 & nsu != 1 & lca != "")}
  else if (workbook_name == "HEA") {df %>% dplyr::filter(ipdc == "I" | ipdc == "D") %>% dplyr::filter(recid != "02B" & location != "D101H")}
  else if (workbook_name == "HRILTC") {df %>% dplyr::filter(gender !="0" & hri_lca !="9" & nsu !="1")}
  else if (workbook_name == "HRIPathways") {df %>% dplyr::filter(gender != 0 & hri_scot != 9 & nsu != 1)}
  else if (workbook_name == "SourceOverview") {df %>% dplyr::filter(!(smrtype %in% c("NRS Deaths", "Comm-MH")) &
                                                      !(recid %in% c("CH", "DN", "OoH", "DD", "NSU")))}
    else {stop("This workbook does not have a defined filter function yet")}}
  else {stop("Not a valid workbook name")}
}


