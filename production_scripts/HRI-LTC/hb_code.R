hb_code <- function(hb) {
  
  case_when(
    
    hb == "Ayrshire & Arran Region" ~ "S08000015",
    hb == "Borders Region" ~ "S08000016",
    hb == "Dumfries and Galloway Region" ~ "S08000017",
    hb == "FiFe Region" ~ "S08000029",
    hb == "Forth Valley Region" ~ "S08000019",
    hb == "Grampian Region" ~ "S08000020",
    hb == "Greater Glasgow & Clyde Region" ~ "S08000021",
    hb == "Highland Region" ~ "S08000022",
    hb == "Lanarkshire Region" ~ "S08000023",
    hb == "Lothian Region"~ "S08000024",
    hb == "Orkney Region" ~ "S08000025",
    hb == "Shetland Regions" ~ "S08000026",
    hb == "Tayside Region" ~ "S08000030",
    hb == "Western Isles Region" ~ "S08000028"
    
  )
  
}