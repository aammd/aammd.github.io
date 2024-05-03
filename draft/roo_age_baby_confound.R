## roos reproduce randomly
## live for 9 years after maturity (so total of 12 years)

## how to simulate death?

simulate_surviving_roos <- function(n_born = 75,
                                    p_mort = .2) {

  n_born <- 75

  ids <- 1:n_born

  p_mort <- .2


  survivors <- vector(length = 15, mode = "list")

  survivors[[1]] <- ids

  for (i in 2:15) {
    survives <- sample(c(FALSE, TRUE),
                       size = length(survivors[[i-1]]),
                       prob = c(p_mort, 1-p_mort),
                       replace = TRUE)

    survivors[[i]] <- survivors[[i-1]][which(survives)]
  }
  return(survivors)
}
library(tidyverse)

simulate_surviving_roos() |>
  map_dbl(length) |>
  plot()

# roos reproduce randomly throughout their life

simulate_repro_df <- function(surv_list, prob_baby = .4){
  roo_babies <- tibble(roo_id = surv_list) |>
    mutate(year_id = seq_along(roo_id)) |>
    unnest(roo_id) |>
    mutate(age = year_id - 1,
           reproduced = rbinom(length(age),
                               size = 1,
                               prob = prob_baby),
           ## 0 for reproduction if you are juvenile
           repro = if_else(age <3, true = 0, false = reproduced))
  return(roo_babies)
}

## how long do you live, how many babies
simulate_surviving_roos() |>
  simulate_repro_df() |>
  group_by(roo_id) |>
  summarize(longevity = max(age),
            fecundity = sum(repro),
            ) |>
  ggplot(aes(x = longevity, y = fecundity)) +
  geom_count()

calc_earlylate_longev <- function(repro_df, min_lifespan_dataset = 8){
  life_fec_df <- repro_df |>
    group_by(roo_id) |>
    summarize(longevity = max(age),
              fecundity = sum(repro), .groups = "drop")


  # add up the number of babies from both early and late life, per roo
  rep_stage_long <- repro_df |>
    mutate(is_early = if_else( age <= 5, "early", "late")) |>
    group_by(roo_id, is_early) |>
    summarize(stage_repro = sum(repro), .groups = "drop")

  rep_stage_long |>
    pivot_wider(values_from = stage_repro, names_from = is_early) |>
    ## join back information about the total lifespan
    left_join(life_fec_df, by = join_by(roo_id)) |>
    filter(longevity  >= min_lifespan_dataset)

}

df_roo <- simulate_surviving_roos() |>
  simulate_repro_df()
calc_earlylate_longev(df_roo) |>
  ggplot(aes(x = early , y = late)) + geom_count()+
  stat_smooth(method = "lm")



## wrap in function
map(1:100, ~ simulate_surviving_roos() |>
      simulate_repro_df() |>
      calc_earlylate_longev()) |>
  map(~ lm(late ~ early, data = .)) |>
  map_df(broom::tidy) |>
  filter(term == "early") |>
  ggplot(aes(x = estimate)) +
  geom_histogram()






