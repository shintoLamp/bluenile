carehome <- readxl::read_xlsx("Outputs/CareHome202021.xlsx") %>% 
  janitor::clean_names() %>% 
  select(datazone, council_area_name, service_name, service_type, subtype, service_postcode, registered_places, simd2020_decile) %>% 
  mutate(simd = cut(simd2020_decile, breaks = c(-1, 2, 4, 6, 8, 10), labels = c("1", "2", "3", "4", "5"))) %>%
  select(-simd2020_decile) %>% 
  filter(subtype %in% c("Alcohol & Drug Misuse",
                        "Blood Borne Virus",
                        "Children & Young People",
                        "Learning Disabilities",
                        "Mental Health Problems",
                        "Older People",
                        "Physical and Sensory Impairment",
                        "Respite Care and Short Breaks")) %>% 
  filter(council_area_name %in% valid_council_names) %>% 
  rename(datazone2011 = datazone,
         partnership = council_area_name,
         postcode = service_postcode)

no_postcodes <- carehome %>% filter(is.na(postcode))

carehome <- carehome %>% bind_rows(., carehome %>%
  filter(council_area_name == "Clackmannanshire" | council_area_name == "Stirling") %>%
  group_by(service_name) %>%
  mutate(
    council_area_name = "Clackmannanshire and Stirling"
  ))


