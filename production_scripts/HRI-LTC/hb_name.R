hb_name <- function(hscp) {
  
  case_when(
    
    hscp %in% c("North Ayrshire", "South Ayrshire", "East Ayrshire") ~ "Ayrshire & Arran Region",
    hscp %in% c("Scottish Borders") ~ "Borders Region",
    hscp %in% c("Dumfries and Galloway") ~ "Dumfries and Galloway Region",
    hscp %in% c("Fife") ~ "FiFe Region",
    hscp %in% c("Stirling", "Falkirk", "Clackmannanshire", "Clackmannanshire & Stirling") ~ "Forth Valley Region",
    hscp %in% c("Aberdeen City", "Aberdeenshire", "Moray") ~ "Grampian Region",
    hscp %in% c("Glasgow City", "East Dunbartonshire", "Renfrewshire", "East Renfrewshire", "West Dunbartonshire", "Inverclyde", "Renfrewshire") ~ "Greater Glasgow & Clyde Region",
    hscp %in% c("Argyll and Bute", "Highland") ~ "Highland Region",
    hscp %in% c("South Lanarkshire", "North Lanarkshire") ~ "Lanarkshire Region",
    hscp %in% c("City of Edinburgh", "East Lothian", "Midlothian", "West Lothian") ~ "Lothian Region",
    hscp %in% c("Orkney Islands") ~ "Orkney Region",
    hscp %in% c("Shetland Islands") ~ "Shetland Regions",
    hscp %in% c("Angus", "Perth and Kinross", "Dundee City") ~ "Tayside Region",
    hscp %in% c("Na h-Eileanan Siar") ~ "Western Isles Region" 
    
  )
  
}
