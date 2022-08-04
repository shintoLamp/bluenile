# Dummy data for chart splits

test_data <- tibble(group = c("high", "high", "medium", "medium", "medium", "low"), 
                    percent = c(0.14169, 0.22111, 0.23148, 0.24559, 0.34778, 0.35692)) %>% 
  mutate(chr = as.character(round(percent, 1)),
         int = round(percent, 1))

test_2 <- sapply(test_data, function(x) mutate(if_else(test_data["group"] != lag(test_data["group"]), 
                                                       test_data["int"] + 0.1, test_data["int"])))

test_func <- function() {mutate(x = if_else(group != lag(group),
                                            int + 0.1, int))}


# Tests

# Get some total sums
x <- c(beddays = sum(hri_lca_level$beddays, na.rm = TRUE), cost = sum(hri_lca_level$total_cost, na.rm = TRUE),
       eps = sum(hri_lca_level$episodes_attendances, na.rm = TRUE))
