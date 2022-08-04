# Read in the Source Individual File and wrangle
slf_extract <- read_slf_individual(c("1718", "1819", "1920", "2021")) %>%
  filter(gender != 0 & nsu != 1 & lca != "") %>%
  # Recode 'age' into groups
  age_bands() %>% 
  # Create flags for different HRI thresholds at lca, health board, and
  # Scotland levels
  hri_percentage_flags() %>% 
  # Label the main HRI groups at LCA level in English
  hri_group_names()

# We need to split up the main extract by service type: Acute, Mental Health, Geriatric Long
# Stay, Maternity, Outpatient, Accident & Emergency, Prescribing, and All Service Types
hri_service_list <- list(
  
  # Acute 
  acute_list =
    list(
      acute_50 = filter(slf_extract, lca_flag_50 == TRUE & acute_episodes >= 1),
      acute_65 = filter(slf_extract, lca_flag_65 == TRUE & acute_episodes >= 1),
      acute_80 = filter(slf_extract, lca_flag_80 == TRUE & acute_episodes >= 1),
      acute_95 = filter(slf_extract, lca_flag_95 == TRUE & acute_episodes >= 1),
      acute_all = filter(slf_extract, acute_episodes >= 1)
    ),
  
  # Mental Health
  mh_list =
    list(
      mh_50 = filter(slf_extract, lca_flag_50 == TRUE & mh_episodes >= 1),
      mh_65 = filter(slf_extract, lca_flag_65 == TRUE & mh_episodes >= 1),
      mh_80 = filter(slf_extract, lca_flag_80 == TRUE & mh_episodes >= 1),
      mh_95 = filter(slf_extract, lca_flag_95 == TRUE & mh_episodes >= 1),
      mh_all = filter(slf_extract, mh_episodes >= 1)
    ),
  
  # Geriatric Long Stay
  gls_list =
    list(
      gls_50 = filter(slf_extract, lca_flag_50 == TRUE & gls_episodes >= 1),
      gls_65 = filter(slf_extract, lca_flag_65 == TRUE & gls_episodes >= 1),
      gls_80 = filter(slf_extract, lca_flag_80 == TRUE & gls_episodes >= 1),
      gls_95 = filter(slf_extract, lca_flag_95 == TRUE & gls_episodes >= 1),
      gls_all = filter(slf_extract, gls_episodes >= 1)
    ),
  
  # Maternity
  mat_list =
    list(
      mat_50 = filter(slf_extract, lca_flag_50 == TRUE & mat_episodes >= 1),
      mat_65 = filter(slf_extract, lca_flag_65 == TRUE & mat_episodes >= 1),
      mat_80 = filter(slf_extract, lca_flag_80 == TRUE & mat_episodes >= 1),
      mat_95 = filter(slf_extract, lca_flag_95 == TRUE & mat_episodes >= 1),
      mat_all = filter(slf_extract, mat_episodes >= 1)
    ),
  
  #Outpatient
  op_list =
    list(
      op_50 = filter(slf_extract, lca_flag_50 == TRUE & op_newcons_attendances >= 1),
      op_65 = filter(slf_extract, lca_flag_65 == TRUE & op_newcons_attendances >= 1),
      op_80 = filter(slf_extract, lca_flag_80 == TRUE & op_newcons_attendances >= 1),
      op_95 = filter(slf_extract, lca_flag_95 == TRUE & op_newcons_attendances >= 1),
      op_all = filter(slf_extract, op_newcons_attendances >= 1)
    ),
  
  # Accident & Emergency
  ae_list =
    list(
      ae_50 = filter(slf_extract, lca_flag_50 == TRUE & ae_attendances >= 1),
      ae_65 = filter(slf_extract, lca_flag_65 == TRUE & ae_attendances >= 1),
      ae_80 = filter(slf_extract, lca_flag_80 == TRUE & ae_attendances >= 1),
      ae_95 = filter(slf_extract, lca_flag_95 == TRUE & ae_attendances >= 1),
      ae_all = filter(slf_extract, ae_attendances >= 1)
    ),
  
  # Prescribing
  pis_list =
    list(
      pis_50 = filter(slf_extract, lca_flag_50 == TRUE & pis_dispensed_items >= 1),
      pis_65 = filter(slf_extract, lca_flag_65 == TRUE & pis_dispensed_items >= 1),
      pis_80 = filter(slf_extract, lca_flag_80 == TRUE & pis_dispensed_items >= 1),
      pis_95 = filter(slf_extract, lca_flag_95 == TRUE & pis_dispensed_items >= 1),
      pis_all = filter(slf_extract, pis_dispensed_items >= 1)
    ),
  
  # All Service Types. Here we add the episodes from each service type and the beddays from 
  # the relevant service types to get totals
  all_list = list(
    all_50 = slf_extract %>%
      filter(lca_flag_50 == TRUE) %>%
      all_group_sum(),
    all_65 = slf_extract %>%
      filter(lca_flag_65 == TRUE) %>%
      all_group_sum(),
    all_80 = slf_extract %>%
      filter(lca_flag_80 == TRUE) %>%
      all_group_sum(),
    all_95 = slf_extract %>%
      filter(lca_flag_95 == TRUE) %>%
      all_group_sum(),
    all_all = slf_extract %>%
      all_group_sum()
  )
)

# rm(slf_extract)

# Perform aggregates to lca/gender/age band level for each service type.
# This is done inside a list as each service type has different variables to total for
# our main four measures (total_cost, episodes_attendances, beddays, number_patients)
hri_service_aggregated_list <- list(
  
  # Acute
  acute_agg =
    hri_service_list[["acute_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(acute_cost),
            episodes_attendances = sum(acute_episodes),
            beddays = sum(acute_inpatient_beddays),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # Mental Health
  mh_agg =
    hri_service_list[["mh_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(mh_cost),
            episodes_attendances = sum(mh_episodes),
            beddays = sum(mh_inpatient_beddays),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # Geriatric Long Stay
  gls_agg =
    hri_service_list[["gls_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(gls_cost),
            episodes_attendances = sum(gls_episodes),
            beddays = sum(gls_inpatient_beddays),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # Maternity
  mat_agg =
    hri_service_list[["mat_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(mat_cost),
            episodes_attendances = sum(mat_episodes),
            beddays = sum(mat_inpatient_beddays),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # Outpatients (no beddays)
  op_agg =
    hri_service_list[["op_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(op_cost_attend),
            episodes_attendances = sum(op_newcons_attendances),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # Accident and Emergency (no beddays)
  ae_agg =
    hri_service_list[["ae_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(ae_cost),
            episodes_attendances = sum(ae_attendances),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # Prescribing (no beddays)
  pis_agg =
    hri_service_list[["pis_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(pis_cost),
            episodes_attendances = sum(pis_dispensed_items),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      ),
  
  # All services
  all_agg =
    hri_service_list[["all_list"]] %>%
      purrr::map_dfr(
        ~ group_by(.x, year, hbrescode, ca2018, gender, ageband) %>%
          summarise(
            total_cost = sum(health_net_cost),
            episodes_attendances = sum(episodes_attendances),
            beddays = sum(beddays),
            number_patients = n(),
            .groups = "keep"
          ),
        .id = "type"
      )
)

# After aggregating, we want to re-flag the HRI thresholds and make the 
# Service Type more legible
hri_service_aggregated_list <- hri_service_aggregated_list %>%
  purrr::map( ~ assign_thresholds(.x))

# We need to create totals for the other service users, which is done by joining the totals
# for the individual service types and All Service users, then taking the difference between
# them. 

# Get the all user group
all_users <- bind_rows(hri_service_aggregated_list) %>% 
  filter(all_patient_flag == TRUE) %>% 
  select(year:number_patients, service_type) %>% 
  rename(bigcost = total_cost, 
         bigeps = episodes_attendances,
         bigbds = beddays,
         bigpats = number_patients)

# Get all the other groups
not_all_users <- bind_rows(hri_service_aggregated_list) %>% 
  filter(all_patient_flag == FALSE) %>% 
  select(-user_type) %>% 
  rename(littlecost = total_cost, 
         littleeps = episodes_attendances,
         littlebds = beddays,
         littlepats = number_patients)

# Take the difference in measures
other_users <- left_join(not_all_users, all_users, 
                         by = c("year", "hbrescode", "ca2018", "gender", "service_type", "ageband")) %>% 
  mutate(total_cost = bigcost - littlecost,
         beddays = bigbds - littlebds,
         episodes_attendances = bigeps - littleeps,
         number_patients = bigpats - littlepats,
         user_type = "Other Service users") %>% 
  select(-starts_with(c("little", "big")))

rm(all_users, not_all_users)

hri_lca_level <- bind_rows(hri_service_aggregated_list) %>% 
  bind_rows(., other_users) %>% 
  left_join(., lacode_lookup) %>% 
  left_join(., hbcode_lookup)

rm(other_users)
                  
# Create totals at datazone level
# We don't split the datazone information by service type, so just use the 'all' group
hri_dz_level <- hri_service_list[["all_list"]] %>%
  purrr::map_dfr(
    ~ group_by(.x, datazone2011, ca2018, ageband, gender) %>%
      summarise(
        total_cost = sum(health_net_cost),
        episodes_attendances = sum(episodes_attendances),
        beddays = sum(beddays),
        number_patients = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>% 
  assign_thresholds()

# Create totals at locality level
# We don't split the locality information by service type, so just use the 'all' group
hri_locality_level <- hri_service_list[["all_list"]] %>%
  purrr::map_dfr(
    ~ group_by(.x, locality, ca2018, ageband, gender) %>%
      summarise(
        total_cost = sum(health_net_cost),
        episodes_attendances = sum(episodes_attendances),
        beddays = sum(beddays),
        number_patients = n(),
        .groups = "keep"
      ),
    .id = "type"
  ) %>% 
  assign_thresholds()

hri_main_final <- bind_rows(hri_lca_level, hri_locality_level, hri_dz_level, .id = "data") %>% 
  mutate(data = case_when(
    data == 1 ~ "LCA Level",
    data == 2 ~ "Locality Level",
    data == 3 ~ "Datazone Level"
  )) %>% 
  mutate(lcaname = phsmethods::match_area(ca2018))

hri_suppressed <- hri_lca_level %>% 
  ungroup() %>% 
  left_join(., lacode_lookup) %>% 
  left_join(., hbcode_lookup) %>% 
  select(-ca2018, -hbrescode)

write_sav(hri_main_final, "Main_R_Test.sav")
write_sav(hri_suppressed, "Suppressed_R_Test.sav")

#tabstore(hri_main_final, ca2018, "Main_R_Test")
#tabstore(hri_suppressed, la_tab_code, "Suppressed_R_Test")
