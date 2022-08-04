lca_code <- function(hscp){
  
  case_when(
    
    hscp == "Scottish Borders" ~ "S12000026",
    hscp == "Fife" ~ "S12000015",
    hscp == "Orkney Islands" ~ "S12000023",
    hscp == "Na h-Eileanan Siar" ~ "S12000013",
    hscp == "Dumfries and Galloway" ~ "S12000006",
    hscp == "Shetland Islands" ~ "S12000027",
    hscp == "North Ayrshire" ~ "S12000021",
    hscp == "South Ayrshire" ~ "S12000028",
    hscp == "East Ayrshire" ~ "S12000008",
    hscp == "East Dunbartonshire" ~ "S12000045",
    hscp == "Glasgow City" ~ "S12000046",
    hscp == "East Renfrewshire" ~ "S12000011",
    hscp == "West Dunbartonshire" ~ "S12000039",
    hscp == "Renfrewshire" ~ "S12000038",
    hscp == "Inverclyde" ~ "S12000018",
    hscp == "Highland" ~ "S12000017",
    hscp == "Argyll and Bute" ~ "S12000035",
    hscp == "North Lanarkshire" ~ "S12000044",
    hscp == "South Lanarkshire" ~ "S12000029",
    hscp == "Aberdeen City" ~ "S12000033",
    hscp == "Aberdeenshire" ~ "S12000034",
    hscp == "Moray" ~ "S12000020",
    hscp == "East Lothian" ~ "S12000010",
    hscp == "West Lothian" ~ "S12000040",
    hscp == "Midlothian" ~ "S12000019",
    hscp == "City of Edinburgh" ~ "S12000036",
    hscp == "Perth and Kinross" ~ "S12000024",
    hscp == "Dundee City" ~ "S12000042",
    hscp == "Angus" ~ "S12000041",
    hscp == "Clackmannanshire" ~ "S12000005",
    hscp == "Falkirk" ~ "S12000014",
    hscp == "Stirling" ~ "S12000030"
    
  )
  
}
