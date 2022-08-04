### 1 - Setup environment and load functions ----
source(here::here("code", "00_setup-environment.R"))

#Read in age group population lookup data, modify sex and lca variables to match main file
pop_lookup <- read_sav("/conf/linkage/output/lookups/Unicode/Populations/Estimates/CA2019_pop_est_1981_2020.sav") %>%
  clean_names() %>%
  # Filter out financial years of interest
  filter(year %in% population_years) %>%
  # Compute LCA codes for matching with A&E basefiles, use ca2011 as this is still used when security filters are applied
  mutate(
    lca = case_when(
      ca2011 == "S12000005" ~ "06",
      ca2011 == "S12000006" ~ "08",
      ca2011 == "S12000008" ~ "10",
      ca2011 == "S12000010" ~ "12",
      ca2011 == "S12000011" ~ "13",
      ca2011 == "S12000013" ~ "32",
      ca2011 == "S12000014" ~ "15",
      ca2011 == "S12000015" ~ "16",
      ca2011 == "S12000017" ~ "18",
      ca2011 == "S12000018" ~ "19",
      ca2011 == "S12000019" ~ "20",
      ca2011 == "S12000020" ~ "21",
      ca2011 == "S12000021" ~ "22",
      ca2011 == "S12000023" ~ "24",
      ca2011 == "S12000024" ~ "25",
      ca2011 == "S12000026" ~ "05",
      ca2011 == "S12000027" ~ "27",
      ca2011 == "S12000028" ~ "28",
      ca2011 == "S12000029" ~ "29",
      ca2011 == "S12000030" ~ "30",
      ca2011 == "S12000033" ~ "01",
      ca2011 == "S12000034" ~ "02",
      ca2011 == "S12000035" ~ "04",
      ca2011 == "S12000036" ~ "14",
      ca2011 == "S12000038" ~ "26",
      ca2011 == "S12000039" ~ "07",
      ca2011 == "S12000040" ~ "31",
      ca2011 == "S12000041" ~ "03",
      ca2011 == "S12000042" ~ "09",
      ca2011 == "S12000044" ~ "23",
      ca2011 == "S12000045" ~ "11",
      ca2011 == "S12000046" ~ "17"
    ),
    # Create standard age groups
    agegroup = case_when(
      age <= 17 ~ "0-17",
      between(age, 18, 44) ~ "18-44",
      between(age, 45, 64) ~ "45-64",
      between(age, 65, 74) ~ "65-74",
      between(age, 75, 84) ~ "75-84",
      age >= 85 ~ "85+"
    )
  ) %>% 
  group_by(year, ca2011, lca, sex, agegroup) %>%
  summarise(population = sum(pop)) %>%
  ungroup()   

#Compute 'All' age group and gender and add to main file
all_agegroup <- pop_lookup %>% 
  mutate(agegroup = "All")%>% 
  group_by(year, ca2011, lca, sex, agegroup) %>%
  summarise(population = sum(population)) %>%
  ungroup()         

pop <- bind_rows(all_agegroup, pop_lookup)

all_gender <- pop %>% 
  mutate(sex = 3) %>% 
  group_by(year, ca2011, sex, lca, agegroup) %>%
  summarise(population = sum(population)) %>%
  ungroup() 

pop <- bind_rows(all_gender, pop) %>% 
  #Compute Scotland population figures
  group_by(year, sex, agegroup) %>%
  mutate(scot_population = sum(population)) %>%
  ungroup() 

#Create health board of residence based on LCA codes created above
pop <- pop %>% mutate(
      hbres = case_when(
      lca == "10" | lca == "22" | lca == "28" ~ "S08000015",
      lca == "05" ~ "S08000016",
      lca == "08" ~ "S08000017",
      lca == "16" ~ "S08000029",
      lca == "06" | lca == "15" | lca == "30" ~ "S08000019",
      lca == "01" | lca == "02" | lca == "21" ~ "S08000020",
      lca == "17" | lca == "19" | lca == "11" | lca == "13" | lca == "26" | lca == "07" ~ "S08000021",
      lca == "04" | lca == "18" ~ "S08000022",
      lca == "23" | lca == "29" ~ "S08000023",
      lca == "12" | lca == "14" | lca == "20" | lca == "31" ~ "S08000024",
      lca == "24" ~ "S08000025",
      lca == "27" ~ "S08000026",
      lca == "03" | lca == "09" | lca == "25" ~ "S08000030",
      lca == "32" ~ "S08000028"
    )) %>% 
  #Compute health board populations
  group_by(year, hbres, sex, agegroup) %>%
  mutate(hbres_population = sum(population)) %>%
  ungroup() %>% 
  arrange(pop, year, lca, sex, agegroup) %>% 
  #Format year variable into financial year format
  mutate(year = str_c(year, str_sub(as.character(as.integer(year) + 1), 3, 4)),
         lca = as.character(lca)) %>% 
  select(-hbres)

#Save final outfile (If necessary)
# write_sav(Pop, here("output", glue("agegroups201718_to_202021.sav")), compress = TRUE)