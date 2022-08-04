# To create Scotland totals, we need to re-split the slf_extract df from 
# Main.R, but by hri_scotp instead of hri_lcap

# We need to split up the main extract by service type: Acute, Mental Health, Geriatric Long
# Stay, Maternity, Outpatient, Accident & Emergency, Prescribing, and All Service Types
hri_scot_list <- list(
  
  # Acute 
  acute_list =
    list(
      acute_50 = filter(slf_extract, scot_flag_50 == TRUE & acute_episodes >= 1),
      acute_65 = filter(slf_extract, scot_flag_65 == TRUE & acute_episodes >= 1),
      acute_80 = filter(slf_extract, scot_flag_80 == TRUE & acute_episodes >= 1),
      acute_95 = filter(slf_extract, scot_flag_95 == TRUE & acute_episodes >= 1),
      acute_all = filter(slf_extract, acute_episodes >= 1)
    ),
  
  # Mental Health
  mh_list =
    list(
      mh_50 = filter(slf_extract, scot_flag_50 == TRUE & mh_episodes >= 1),
      mh_65 = filter(slf_extract, scot_flag_65 == TRUE & mh_episodes >= 1),
      mh_80 = filter(slf_extract, scot_flag_80 == TRUE & mh_episodes >= 1),
      mh_95 = filter(slf_extract, scot_flag_95 == TRUE & mh_episodes >= 1),
      mh_all = filter(slf_extract, mh_episodes >= 1)
    ),
  
  # Geriatric Long Stay
  gls_list =
    list(
      gls_50 = filter(slf_extract, scot_flag_50 == TRUE & gls_episodes >= 1),
      gls_65 = filter(slf_extract, scot_flag_65 == TRUE & gls_episodes >= 1),
      gls_80 = filter(slf_extract, scot_flag_80 == TRUE & gls_episodes >= 1),
      gls_95 = filter(slf_extract, scot_flag_95 == TRUE & gls_episodes >= 1),
      gls_all = filter(slf_extract, gls_episodes >= 1)
    ),
  
  # Maternity
  mat_list =
    list(
      mat_50 = filter(slf_extract, scot_flag_50 == TRUE & mat_episodes >= 1),
      mat_65 = filter(slf_extract, scot_flag_65 == TRUE & mat_episodes >= 1),
      mat_80 = filter(slf_extract, scot_flag_80 == TRUE & mat_episodes >= 1),
      mat_95 = filter(slf_extract, scot_flag_95 == TRUE & mat_episodes >= 1),
      mat_all = filter(slf_extract, mat_episodes >= 1)
    ),
  
  #Outpatient
  op_list =
    list(
      op_50 = filter(slf_extract, scot_flag_50 == TRUE & op_newcons_attendances >= 1),
      op_65 = filter(slf_extract, scot_flag_65 == TRUE & op_newcons_attendances >= 1),
      op_80 = filter(slf_extract, scot_flag_80 == TRUE & op_newcons_attendances >= 1),
      op_95 = filter(slf_extract, scot_flag_95 == TRUE & op_newcons_attendances >= 1),
      op_all = filter(slf_extract, op_newcons_attendances >= 1)
    ),
  
  # Accident & Emergency
  ae_list =
    list(
      ae_50 = filter(slf_extract, scot_flag_50 == TRUE & ae_attendances >= 1),
      ae_65 = filter(slf_extract, scot_flag_65 == TRUE & ae_attendances >= 1),
      ae_80 = filter(slf_extract, scot_flag_80 == TRUE & ae_attendances >= 1),
      ae_95 = filter(slf_extract, scot_flag_95 == TRUE & ae_attendances >= 1),
      ae_all = filter(slf_extract, ae_attendances >= 1)
    ),
  
  # Prescribing
  pis_list =
    list(
      pis_50 = filter(slf_extract, scot_flag_50 == TRUE & pis_dispensed_items >= 1),
      pis_65 = filter(slf_extract, scot_flag_65 == TRUE & pis_dispensed_items >= 1),
      pis_80 = filter(slf_extract, scot_flag_80 == TRUE & pis_dispensed_items >= 1),
      pis_95 = filter(slf_extract, scot_flag_95 == TRUE & pis_dispensed_items >= 1),
      pis_all = filter(slf_extract, pis_dispensed_items >= 1)
    ),
  
  # All Service Types. Here we add the episodes from each service type and the beddays from 
  # the relevant service types to get totals
  all_list = list(
    all_50 = slf_extract %>%
      filter(scot_flag_50 == TRUE) %>%
      all_group_sum(),
    all_65 = slf_extract %>%
      filter(scot_flag_65 == TRUE) %>%
      all_group_sum(),
    all_80 = slf_extract %>%
      filter(scot_flag_80 == TRUE) %>%
      all_group_sum(),
    all_95 = slf_extract %>%
      filter(scot_flag_95 == TRUE) %>%
      all_group_sum(),
    all_all = slf_extract %>%
      all_group_sum()
  )
)

hri_scotland_aggregated_list <- list(
  
  # Acute
  acute_agg =
    hri_scot_list[["acute_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["mh_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["gls_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["mat_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["op_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["ae_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["pis_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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
    hri_scot_list[["all_list"]] %>%
    purrr::map_dfr(
      ~ group_by(.x, gender, ageband) %>%
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

hri_scotland_level <- bind_rows(hri_scotland_aggregated_list)

write_sav(hri_scotland_level, "Scotland_R_Test.sav")
