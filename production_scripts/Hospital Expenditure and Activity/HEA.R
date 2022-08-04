############################################################
## Code name - HEA.R                                      ##
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
                               columns = c("year","recid","gender","dob","age", 
                                           "gpprac","cluster","hbpraccode","postcode","datazone2011", 
                                           "hbrescode","lca","hbtreatcode","locality","ca2018",
                                           "location","ipdc","spec","sigfac", 
                                           "smr01_cis_marker","cij_pattype","cij_marker","cij_admtype", 
                                           "cost_total_net","yearstay")) %>% 
  # We only want inpatients and day cases
  filter(ipdc == "I" | ipdc == "D") %>% 
  # Filter out Maternity cases and the State Hospital
  filter(recid != "02B" & location != "D101H") %>% 
  # Recode ages into standard groups for analysis
  standard_age_groups(age) %>% 
  # Replace empty localities with 'Unknown'
  mutate(locality = if_else(locality == "", "Unknown", locality),
         # Replace empty patient types with 'Other'
         cij_pattype = if_else(cij_pattype == "", "Other", cij_pattype),
         # Create an episodes variable to count later
         episodes = TRUE,
         # Determine whether treatment was received within or outwith Board of residence
         treated_board = case_when(hbrescode == hbtreatcode ~ TRUE,
                                   hbrescode != hbtreatcode ~ FALSE))

# Use the specialty lookup to match the specialty code to its description
hea_master <- left_join(hea_master, get_spec_lookup(c("Speccode", "Description")), 
                        by = c("spec" = "Speccode")) %>% 
  # Rename 'Description' to 'specname'
  rename(specname = Description) %>% 
  # Create the 'specialty_grp' field and recode specname into it
  # Any specialties not in a group will retain their name in this field
  mutate(specialty_grp = case_when(
    spec == "C1" | spec == "C11" ~ "General Surgery (excludes Vascular) - Grp",
    spec == "C4" | spec == "C41" ~ "Cardiac Surgery - Grp",
    spec == "D3" | spec == "D4" ~ "Oral Surgery & Medicine - Grp",
    spec == "C5" | spec == "C51" ~  "Ear, Nose & Throat - Grp",
    spec == "A1" | spec == "A11" ~ "General Medicine - Grp",
    spec == "C3" | spec == "C31" ~ "Anaesthetics - Grp",
    spec == "D1" | spec == "D5" | spec == "D6" | spec == "D8" ~ "Dental - Grp",
    spec == "G1" | spec == "G3" ~  "General Psychiatry - Grp",
    spec == "G2" | spec == "G21" | spec == "G22" ~ "Child & Adolescent Psychiatry - Grp",
    spec == "F3" | spec == "F31" | spec == "F32" | spec == "T2" | spec == "T21" ~ "Obstetrics Specialist - Grp",
    spec == "A8" | spec == "A81" | spec == "A82" | spec == "AA" | spec == "AC" |
      spec == "AW" | spec == "H1" | spec == "J5" ~ "Other medical specialties - Grp",
    str_sub(spec, 1, 1) == "C" | spec == "F2" ~ "Surgical Specialties & Anaesthetics - Grp",
    TRUE ~ specname
  ))

# Use the match_area function from phsmethods to get the Board names
test <- hea_master %>% mutate(hbresname = match_area(hbrescode)) %>% 
  # Recode any categories that aren't the main Boards to 'Other Non-Scottish Residents'
  mutate(hbresname = if_else(!(hbresname %in% health_boards), "Other Non-Scottish Residents", 
                             # Replace 'and' with ampersand
                             str_replace(hbresname, " and ", " & "))) %>%
  # Add 'NHS' in front of Board names
  mutate(hbresname = if_else(hbresname %in% health_boards, str_c("NHS ", hbresname), hbresname)) %>% 
  
  # Similar to above, but we want Board names in 'X Region' format too
  mutate(hb_region_format = match_area(hbrescode)) %>% 
  mutate(hb_region_format = if_else(!(hb_region_format %in% health_boards), "Other Non-Scottish Residents", 
                             str_replace(hb_region_format, " and ", " & "))) %>% 
  mutate(hb_region_format = if_else(hb_region_format %in% health_boards, 
                                    str_c(hb_region_format, " Region"), hb_region_format)) %>% 
  
  # Get LCA names
  mutate(lcaname = match_area(ca2018))
