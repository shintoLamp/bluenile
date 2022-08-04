chart_and_table <- function(finyear) {
  slf_extract <- read_slf_individual(finyear,
    columns = c("year", "gender", "lca", "age", "hri_lcap", "health_net_cost", "nsu", "hri_lca")
  ) %>%
    filter(gender != 0 & hri_lca != 9 & nsu != 1 & lca != "") %>%
    hri_group_names() %>%
    mutate(hri_group = factor(hri_group,
      levels = c("High", "High to Medium", "Medium", "Medium to Low", "Low"),
      ordered = TRUE
    ))

  slf_extract_all_ages <- slf_extract %>% mutate(ageband = "All")
  slf_extract_age_groups <- slf_extract %>% age_bands()

  overtable_output <- bind_rows(overtable(slf_extract_age_groups), overtable(slf_extract_all_ages))
  overchart_output <- bind_rows(overchart(slf_extract_age_groups), overchart(slf_extract_all_ages))

  return_df <- bind_rows(overtable_output, overchart_output, .id = "data") %>%
    mutate(data = if_else(data == 1, "Table", "Chart"))

  return(return_df)
}

output_df <- list(
  chart_and_table("1718"),
  chart_and_table("1819"),
  chart_and_table("1920"),
  chart_and_table("2021")
)

final <- bind_rows(output_df) %>% lca_to_lcaname(.)

write_sav(final, "Chart_R_Test.sav")
tabstore(final, lcaname, "Chart_R_Test")

