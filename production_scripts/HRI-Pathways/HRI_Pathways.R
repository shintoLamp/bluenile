tic("Whole thing")
tic("Yearly Extracts")
yearly_extracts <- list(
  ex_1718 = pathways_wrangle("1718"),
  ex_1819 = pathways_wrangle("1819"),
  ex_1920 = pathways_wrangle("1920"),
  ex_2021 = pathways_wrangle("2021")
)
toc()

tic("Main Extract")
main_extract <-
  full_join(yearly_extracts[["ex_2021"]], yearly_extracts[["ex_1920"]], by = c("anon_chi", "age_group", "gender")) %>%
  full_join(., yearly_extracts[["ex_1819"]], by = c("anon_chi", "age_group", "gender")) %>%
  full_join(., yearly_extracts[["ex_1718"]], by = c("anon_chi", "age_group", "gender")) %>% 
  # We need a definitive death_date (if there is one) for each case
  mutate(death_date = case_when(
    !is.na(death_date_2021) ~ death_date_2021,
    !is.na(death_date_1920) ~ death_date_1920,
    !is.na(death_date_1819) ~ death_date_1819,
    !is.na(death_date_1718) ~ death_date_1718,
    TRUE ~ NA_Date_)) %>% 
  # Get rid of the death dates for individual years
  select(-contains("death_date_"))
toc()

# Remove list of yearly extracts as it is large
rm(yearly_extracts)

tic("lca_lookups")
# Generate chi-level lookups for each LCA
lca_lookups <- list(
  aberdeen_city = pathway_lookup_chi(main_extract, "01"),
  aberdeenshire = pathway_lookup_chi(main_extract, "02"),
  angus = pathway_lookup_chi(main_extract, "03"),
  argyll_and_bute = pathway_lookup_chi(main_extract, "04"),
  scottish_borders = pathway_lookup_chi(main_extract, "05"),
  clackmannanshire = pathway_lookup_chi(main_extract, "06"),
  west_dunbartonshire = pathway_lookup_chi(main_extract, "07"),
  dumfries_and_galloway = pathway_lookup_chi(main_extract, "08"),
  dundee_city = pathway_lookup_chi(main_extract, "09"),
  east_ayrshire = pathway_lookup_chi(main_extract, "10"),
  east_dunbartonshire = pathway_lookup_chi(main_extract, "11"),
  east_lothian = pathway_lookup_chi(main_extract, "12"),
  east_renfrewshire = pathway_lookup_chi(main_extract, "13"),
  city_of_edinburgh = pathway_lookup_chi(main_extract, "14"),
  falkirk = pathway_lookup_chi(main_extract, "15"),
  fife = pathway_lookup_chi(main_extract, "16"),
  glasgow_city = pathway_lookup_chi(main_extract, "17"),
  highland = pathway_lookup_chi(main_extract, "18"),
  inverclyde = pathway_lookup_chi(main_extract, "19"),
  midlothian = pathway_lookup_chi(main_extract, "20"),
  moray = pathway_lookup_chi(main_extract, "21"),
  north_ayrshire = pathway_lookup_chi(main_extract, "22"),
  north_lanarkshire = pathway_lookup_chi(main_extract, "23"),
  orkney_islands = pathway_lookup_chi(main_extract, "24"),
  perth_and_kinross = pathway_lookup_chi(main_extract, "25"),
  renfrewshire = pathway_lookup_chi(main_extract, "26"),
  shetland_islands = pathway_lookup_chi(main_extract, "27"),
  south_ayrshire = pathway_lookup_chi(main_extract, "28"),
  south_lanarkshire = pathway_lookup_chi(main_extract, "29"),
  stirling = pathway_lookup_chi(main_extract, "30"),
  west_lothian = pathway_lookup_chi(main_extract, "31"),
  western_isles = pathway_lookup_chi(main_extract, "32")
)
toc()

# Get the pathway aggregates with total, maximum, and minimum costs
tic("LCA Aggregates")
lca_aggregates <- purrr::map(lca_lookups, ~ lca_aggregate(.x))
toc()

# Transform all of the chi frames into lookups 
tic("CHI Lookups")
chi_lookups <- purrr::map(lca_lookups, ~ lca_chi_aggregate(.x))
toc()

tic("Summary")
summarised_lcas <- list(
  aberdeen_city = do_the_summary("aberdeen_city"),
  aberdeenshire = do_the_summary("aberdeenshire"),
  angus = do_the_summary("angus"),
  argyll_and_bute = do_the_summary("argyll_and_bute"),
  scottish_borders = do_the_summary("scottish_borders"),
  clackmannanshire = do_the_summary("clackmannanshire"),
  west_dunbartonshire = do_the_summary("west_dunbartonshire"),
  dumfries_and_galloway = do_the_summary("dumfries_and_galloway"),
  dundee_city = do_the_summary("dundee_city"),
  east_ayrshire = do_the_summary("east_ayrshire"),
  east_dunbartonshire = do_the_summary("east_dunbartonshire"),
  east_lothian = do_the_summary("east_lothian"),
  east_renfrewshire = do_the_summary("east_renfrewshire"),
  city_of_edinburgh = do_the_summary("city_of_edinburgh"),
  falkirk = do_the_summary("falkirk"),
  fife = do_the_summary("fife"),
  glasgow_city = do_the_summary("glasgow_city"),
  highland = do_the_summary("highland"),
  inverclyde = do_the_summary("inverclyde"),
  midlothian = do_the_summary("midlothian"),
  moray = do_the_summary("moray"),
  north_ayrshire = do_the_summary("north_ayrshire"),
  north_lanarkshire = do_the_summary("north_lanarkshire"),
  orkney_islands = do_the_summary("orkney_islands"),
  perth_and_kinross = do_the_summary("perth_and_kinross"),
  renfrewshire = do_the_summary("renfrewshire"),
  shetland_islands = do_the_summary("shetland_islands"),
  south_ayrshire = do_the_summary("south_ayrshire"),
  south_lanarkshire = do_the_summary("south_lanarkshire"),
  stirling = do_the_summary("stirling"),
  west_lothian = do_the_summary("west_lothian"),
  western_isles = do_the_summary("western_isles")
)
toc()

tic("Last things")
pathway_final <- bind_rows(lca_aggregates, .id = "lcaname") %>% ungroup() %>% mutate(link = "link")
summary_final <- bind_rows(summarised_lcas, .id = "lcaname") %>% ungroup()

# Add C&S, also add LCA codes for security filters
pathway_final <- bind_rows(pathway_final, 
                     pathway_final %>% 
                       filter(lcaname == "clackmannanshire" | lcaname == "stirling") %>% 
                       mutate(lcaname = "clackmannanshire_and_stirling", x = "32") %>% 
                       group_by(lcaname, x, gender, age_group, hri_group_1718, hri_group_1819, hri_group_1920, hri_group_2021, pathway_lkp, link) %>% 
                       summarise(across(contains("health"), sum, na.rm = TRUE),
                                 across(contains("min"), min, na.rm = TRUE),
                                 across(contains("max"), max, na.rm = TRUE),
                                 across("size", sum, na.rm = TRUE),
                                 .groups = "keep")) %>% 
  lcanames_and_codes(.)

summary_final <- bind_rows(summary_final, 
                           summary_final %>% 
                             filter(lcaname == "clackmannanshire" | lcaname == "stirling") %>% 
                             mutate(lcaname = "clackmannanshire_and_stirling", x = "32") %>% 
                             group_by(across(lcaname:hri_group_2021)) %>% 
                             summarise(across(health_net_cost:num_ind, sum, na.rm = TRUE),
                                       .groups = "keep")) %>% 
  lcanames_and_codes(.)
toc()

tic("Write out")
write_sav(pathway_final, "Data/Pathway-R-Test.sav")
write_sav(summary_final, "Data/Summary-R-Test.sav")

tabstore(pathway_final, "Data/Pathway-R")
tabstore(summary_final, "Data/Summary-R")
toc()
toc()

