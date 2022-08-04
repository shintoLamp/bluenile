############################################################
## Code name - HEA - The Wrangling.R                      ##
## Description - Part of the code for the Hospital        ##
## Expenditure and Activity workbook                      ##
## Written by: Bateman McBride                            ##
## First written: October 2021                            ##
## Updated:                                               ##
############################################################

###########################################
# Section 1 - Get SLF data and wrangle    #
###########################################

# Enter the financial years for analysis here
finyears <- c("1920")

# Read in a master file from the SLFs
hea_master <- read_slf_episode(finyears,
  columns = c(
    "year", "recid", "gender", "dob", "age",
    "gpprac", "cluster", "hbpraccode", "postcode", "datazone2011",
    "hbrescode", "lca", "hbtreatcode", "locality", "ca2018",
    "location", "ipdc", "spec", "sigfac",
    "smr01_cis_marker", "cij_pattype", "cij_marker", "cij_admtype",
    "cost_total_net", "yearstay"
  )
) %>%
  # We only want inpatients and day cases
  filter(ipdc == "I" | ipdc == "D") %>%
  # Filter out Maternity cases and the State Hospital
  filter(recid != "02B" & location != "D101H") %>%
  # Recode ages into standard groups for analysis
  standard_age_groups(age) %>%
  # Replace empty localities with 'Unknown'
  mutate(
    locality = if_else(locality == "" | is.na(locality), "Unknown", locality),
    # Replace empty patient types with 'Other'
    cij_pattype = if_else(cij_pattype == "" | is.na(cij_pattype), "Other", cij_pattype),
    # Create an episodes variable to count later
    episodes = TRUE,
    # Determine whether treatment was received within or outwith Board of residence
    treated_board = hbrescode == hbtreatcode 
  ) %>% 
  replace_na(list(locality = "Unknown", cij_pattype = "Other"))

# Use the specialty lookup to match the specialty code to its description
hea_master <- left_join(hea_master, get_spec_lookup(c("Speccode", "Description")),
  by = c("spec" = "Speccode")
) %>%
  # Rename 'Description' to 'specname'
  rename(specname = Description) %>%
  # Create the 'specialty_grp' field and recode specname into it
  # Any specialties not in a group will retain their name in this field
  mutate(specialty_grp = case_when(
    spec == "C1" | spec == "C11" ~ "General Surgery (excludes Vascular) - Grp",
    spec == "C4" | spec == "C41" ~ "Cardiac Surgery - Grp",
    spec == "D3" | spec == "D4" ~ "Oral Surgery & Medicine - Grp",
    spec == "C5" | spec == "C51" ~ "Ear, Nose & Throat - Grp",
    spec == "A1" | spec == "A11" ~ "General Medicine - Grp",
    spec == "C3" | spec == "C31" ~ "Anaesthetics - Grp",
    spec == "D1" | spec == "D5" | spec == "D6" | spec == "D8" ~ "Dental - Grp",
    spec == "G1" | spec == "G3" ~ "General Psychiatry - Grp",
    spec == "G2" | spec == "G21" | spec == "G22" ~ "Child & Adolescent Psychiatry - Grp",
    spec == "F3" | spec == "F31" | spec == "F32" | spec == "T2" | spec == "T21" ~ "Obstetrics Specialist - Grp",
    spec == "A8" | spec == "A81" | spec == "A82" | spec == "AA" | spec == "AC" |
      spec == "AW" | spec == "H1" | spec == "J5" ~ "Other medical specialties - Grp",
    str_sub(spec, 1, 1) == "C" | spec == "F2" ~ "Surgical Specialties & Anaesthetics - Grp",
    TRUE ~ specname
  )) %>% 

# Use the match_area function from phsmethods to get the Board names
  mutate(hbresname = match_area(hbrescode)) %>%
  # Recode any categories that aren't the main Boards to 'Other Non-Scottish Residents'
  mutate(hbresname = if_else(!(hbresname %in% hea_constants[["health_boards"]]), "Other Non-Scottish Residents",
    # Replace 'and' with ampersand
    str_replace(hbresname, " and ", " & ")
  )) %>%
  # Add 'NHS' in front of Board names
  mutate(hbresname = if_else(hbresname %in% hea_constants[["health_boards"]], str_c("NHS ", hbresname), hbresname)) %>%
  # Similar to above, but we want Board names in 'X Region' format too
  mutate(hb_region_format = match_area(hbrescode)) %>%
  mutate(hb_region_format = if_else(!(hb_region_format %in% hea_constants[["health_boards"]]), "Other Non-Scottish Residents",
    str_replace(hb_region_format, " and ", " & ")
  )) %>%
  mutate(hb_region_format = if_else(hb_region_format %in% hea_constants[["health_boards"]],
    str_c(hb_region_format, " Region"), hb_region_format
  )) %>%
  # Get LCA names
  mutate(lcaname = match_area(ca2018)) %>%
  mutate(lcaname = case_when(
    lcaname == "Na h-Eileanan Siar" ~ "Western Isles",
    str_detect(lcaname, " and ") == TRUE ~ str_replace(lcaname, " and ", " & "),
    TRUE ~ lcaname
  )) %>%
  # Replace any missing lca names with 'Non LCA'
  mutate(lcaname = replace_na(lcaname, "Non LCA")) %>%
  # If any Boards have LCAs assigned to them that aren't actually in their region, 
  # assign them 'Non LCA'
  mutate(lcaname = case_when
  (
    hb_region_format == "Ayrshire & Arran Region" & (lcaname != "East Ayrshire" & lcaname != "North Ayrshire" & lcaname != "South Ayrshire") ~ "Non LCA",
    hb_region_format == "Borders Region" & lcaname != "Scottish Borders" ~ "Non LCA",
    hb_region_format == "Fife Region" & (lcaname != "Fife") ~ "Non LCA",
    hb_region_format == "Greater Glasgow & Clyde Region" & (lcaname != "East Dunbartonshire" & lcaname != "East Renfrewshire" & lcaname != "Glasgow City" & lcaname != "Inverclyde" &
      lcaname != "Renfrewshire" & lcaname != "West Dunbartonshire" & lcaname != "North Lanarkshire" & lcaname != "South Lanarkshire") ~ "Non LCA",
    hb_region_format == "Highland Region" & (lcaname != "Argyll & Bute" & lcaname != "Highland") ~ "Non LCA",
    hb_region_format == "Lanarkshire Region" & (lcaname != "North Lanarkshire" & lcaname != "South Lanarkshire") ~ "Non LCA",
    hb_region_format == "Grampian Region" & (lcaname != "Aberdeen City" & lcaname != "Aberdeenshire" & lcaname != "Moray") ~ "Non LCA",
    hb_region_format == "Orkney Region" & lcaname != "Orkney Islands" ~ "Non LCA",
    hb_region_format == "Shetland Region" & lcaname != "Shetland Islands" ~ "Non LCA",
    hb_region_format == "Lothian Region" & (lcaname != "City of Edinburgh" & lcaname != "East Lothian" & lcaname != "Midlothian" & lcaname != "West Lothian") ~ "Non LCA",
    hb_region_format == "Tayside Region" & (lcaname != "Angus" & lcaname != "Dundee City" & lcaname != "Perth & Kinross") ~ "Non LCA",
    hb_region_format == "Forth Valley Region" & (lcaname != "Falkirk" & lcaname != "Clackmannanshire" & lcaname != "Stirling") ~ "Non LCA",
    hb_region_format == "Western Isles Region" & lcaname != "Western Isles" ~ "Non LCA",
    hb_region_format == "Dumfries & Galloway Region" & lcaname != "Dumfries & Galloway" ~ "Non LCA",
    TRUE ~ lcaname
  )) %>% 
  # Use record ID and Inpatient/Day case marker to find out whether an individual was elective or non-elective
  # This needs to be done due to the cost mapping process splitting these across 
  # different mapping codes than the SLFs do
  mutate(mapcode = case_when(
    recid == "01B" & ipdc == "I" & cij_pattype == "Non-Elective" ~ "01A",
    recid == "01B" & ipdc == "I" & cij_pattype == "Elective" ~ "01B",
    recid == "01B" & ipdc == "I" & (cij_pattype != "Elective" | cij_pattype != "Non-Elective") ~ "01C",
    recid == "01B" & ipdc == "D" ~ "02",
    recid == "04B" & ipdc == "I" & cij_pattype == "Non-Elective" ~ "03A",
    recid == "04B" & ipdc == "I" & cij_pattype == "Elective" ~ "03B",
    recid == "04B" & ipdc == "I" & (cij_pattype != "Elective" | cij_pattype != "Non-Elective") ~ "03D",
    recid == "50B" & cij_pattype == "Non-Elective" ~ "04A",
    recid == "50B" & cij_pattype == "Elective" ~ "04B",
    recid == "50B" & (cij_pattype != "Elective" | cij_pattype != "Non-Elective") ~ "04C",
    recid == "02B" & ipdc == "I" ~ "05",
    recid == "02B" & ipdc == "D" ~ "06",
    TRUE ~ "99"
  )) %>% 
  # Make C&S into an lca
  mutate(temp_lca = if_else(lcaname == "Clackmannanshire" | lcaname == "Stirling",
                                  "Clackmannanshire & Stirling",
                                  NA_character_
  )) %>%
  pivot_longer(cols = c(lcaname, temp_lca), values_to = "lcaname", values_drop_na = TRUE) %>%
  select(-name)
