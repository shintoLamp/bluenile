############################################################
## Code name - SourceOverview.R                           ##
## Description - Creates data for Tableau dashboard       ##
## Written by: Bateman McBride                            ##
## First written: July 2021                               ##
## Updated:                                               ##
############################################################

##################################
#### SECTION 1 - HOUSEKEEPING ####
##################################

workbook_name <- "source_overview"

# Define financial years for extraction
finyear <- c("1617", "1718", "1819", "1920")

# Get lookup files for matching on names
dz <- get_dz_lookup("20200825", c("datazone2011", "hscp_locality"))
hosp <- get_hosp_lookup(c("Location", "Locname"))
spec <- get_spec_lookup(c("Speccode", "Description"))

# Extract Source Episode Files for four financial years with required variables
# Filter out services that have no monthly breakdowns
master <- read_slf_episode(finyear,
                           columns = c(
                             "year", "datazone2011", "ca2018", "recid", "smrtype", "gender", "location", "refsource",
                             "clinic_type", "age", "cij_ipdc", "cij_pattype", "ipdc", "spec",
                             "yearstay", "stay", "no_dispensed_items", "cost_total_net", "cost_total_net_incdnas",
                             "apr_beddays", "may_beddays", "jun_beddays", "jul_beddays", "aug_beddays", "sep_beddays",
                             "oct_beddays", "nov_beddays", "dec_beddays", "jan_beddays", "feb_beddays", "mar_beddays",
                             "apr_cost", "may_cost", "jun_cost", "jul_cost", "aug_cost", "sep_cost",
                             "oct_cost", "nov_cost", "dec_cost", "jan_cost", "feb_cost", "mar_cost"
                           )
) %>%
  filter(!(smrtype %in% c("NRS Deaths", "Comm-MH")) &
           !(recid %in% c("CH", "DN", "OoH", "DD", "NSU")))

## Section for matching area codes
# Get the most recent datazone lookup and match to get Localities
overview <- master %>% managed_lookup(dz, matchby = "datazone2011")
# Match hospital location codes to get location names
overview %<>% managed_lookup(hosp, matchby = c("location" = "Location"))
# Match specialty codes to get their descriptions
overview %<>% managed_lookup(spec, matchby = c("spec" = "Speccode")) %>%
  # Use phsmethods::match_area() to get LCA names
  mutate(lcaname = match_area(ca2018)) %>%
  # Fill unknown LCA names with "Non LCA"
  mutate(lcaname = if_else(is.na(lcaname), "Non LCA", lcaname))

## Section for some wrangling
overview %<>%
  # Apply standard age groups
  standard_age_groups(age) %>%
  # Recode so that Community Health (0) comes under Outpatient Referral (E)
  mutate(refsource = if_else(refsource == "0", "E", refsource)) %>%
  # Recode Gender into string format
  mutate(gender = if_else(gender == "1", "Male", if_else(gender == "2", "Female", "Unknown"))) %>%
  # Recode year into financial year format
  mutate(year = str_c("20", str_sub(year, start = 1, end = 2), "/", str_sub(year, start = 3, end = 4)))

##################################
#### SECTION 2 - AGGREGATION  ####
##################################

## Assumes that only when there are costs in a month was there an episode, so sets eps = 1 when cost > 0
## for each individual month
overview %<>% mutate(
  jan_episodes = if_else(jan_cost > 0, 1, 0),
  feb_episodes = if_else(feb_cost > 0, 1, 0),
  mar_episodes = if_else(mar_cost > 0, 1, 0),
  apr_episodes = if_else(apr_cost > 0, 1, 0),
  may_episodes = if_else(may_cost > 0, 1, 0),
  jun_episodes = if_else(jun_cost > 0, 1, 0),
  jul_episodes = if_else(jul_cost > 0, 1, 0),
  aug_episodes = if_else(aug_cost > 0, 1, 0),
  sep_episodes = if_else(sep_cost > 0, 1, 0),
  oct_episodes = if_else(oct_cost > 0, 1, 0),
  nov_episodes = if_else(nov_cost > 0, 1, 0),
  dec_episodes = if_else(dec_cost > 0, 1, 0),
  ## Sets episodes (counting all months) to one
  episodes = 1
)

# Create Clackmannanshire & Stirling data by selecting the two LCAs seperately,
# giving them both the LA Code for Stirling, and aggregating. Then adding that to source_overview
cs <- overview %>%
  filter(lcaname %in% c("Clackmannanshire", "Stirling")) %>%
  mutate(lcaname = "Clackmannanshire & Stirling")
overview <- bind_rows(overview, cs)

# Aggregate all measures by the key variables, summarise + across allows for multiple sums across different columns
source_overview <- overview %>%
  group_by(
    year, ca2018, lcaname, hscp_locality, location, Locname,
    recid, smrtype, gender, Description, ipdc, spec,
    refsource, clinic_type, age_grp, cij_ipdc, cij_pattype
  ) %>%
  summarise(across(yearstay:episodes, sum, na.rm = TRUE)) %>%
  ungroup()

## Here we use the first character of the location code to determine the Health Board the location is within
source_overview <- source_overview %>% 
  location_to_hb(locationcode = location) %>% 
  # Use the match_area() from phsmethods to get Health Board names
  mutate(hosp_hb_name = match_area(hosp_hb_code))

## Write out final dataset
write_sav(source_overview, str_glue("SourceOverviewTest_{Sys.Date()}.sav"))

# Create small dataset for use in Tabstore
small <- tabstore(source_overview, lcaname, workbook_name)
