library(cmdstanr)

p_success <- .49
sample_size <- .5
hist(rbeta(2000,
           p_success*sample_size,
           ( 1 - p_success)*sample_size),
     xlim = c(0, 1) )

dir_rng <- cmdstan_model("draft/dirichlet_fitness/dir_rng.stan")

dir_samp <- dir_rng$sample(data = list(n = 1, sd_phi = .05))

lake_names <- c("strange", "lucky", "twisted", "dank")

library(tidybayes)
library(tidyverse)


dir_samp |>
  gather_rvars(a[lake]) |>
  mutate(lake = paste(lake_names, "lake")) |>
  ggplot(aes(dist = .value, y = lake)) +
  stat_slabinterval()

dir_samp |>
  gather_rvars(d[n,lake]) |>
  mutate(lake = paste(lake_names[lake], "lake")) |>
  ggplot(aes(dist = .value, y = lake)) +
  stat_slabinterval()



dir_drift_rng <- cmdstan_model("draft/dirichlet_fitness/dir_drift_rng.stan")


dir_drift_rng_samp <- dir_drift_rng$sample(data = list(n = 1, log_phi_mu = 6, start_prop = c(.1, .5, .2, .2)))

dir_drift_rng_samp |>
  gather_rvars(d[n,lake]) |>
  mutate(lake = paste(lake_names[lake], "lake")) |>
  ggplot(aes(dist = .value, y = lake)) +
  stat_slabinterval()


#' What info would we need to run this model on real fish
#'
#' Population ID would be the same as origin lake ID -- boht would add  the
#' same random effect to the model
#'
#' Each population has a random effect that captures its variation in fitness, growth rate etc
#' these will be the same random effects that will index the effect of differnt niche breathds.
#' AND the are are the same that will index the lake starting compositions
#'
#' there may eventually be a need for an interaction, such that origin populations do differently in different lakes, even after the data
#'
#' squared differnces could be calculated in the transformed data block! useful for afterwards
#'
#' gq, make the reaction norm of each species
#'


ss <- rnorm(20000)

hist(exp(rnorm(2000)))

#' I think the right thing to do here is to work on this as a [sparse data structure](https://mc-stan.org/docs/stan-users-guide/sparse-ragged.html#sparse-data-structures)

#' we have 9 populations to start with, but not every population is in every stocked lake
#'


#' what if the data are read in as a matrix of population (rows) by individuals (columns)?
#' No, the manual says that arrays are more efficient

# Simulating one sample of many fish:

dir_one_samp_rng <- cmdstan_model("draft/dirichlet_fitness/dir_one_samp_rng.stan")







## Simulating many fish


dir_one_samp_rng_samp <- dir_one_samp_rng$sample(data = list(
  n_fish = 100,
  n_pop = 5,
  log_phi_mu = 1.6,
  sd_pop = 1,
  start_prop = c(.1,
                 .4,
                 .2,
                 .2,
                 .1)*5))


dir_one_samp_rng_samp |>
  gather_draws(d[fish_id, pop_id], ndraws = 12) |>
  # group_by(fish_id, .draw) |>
  # mutate(gene = cumsum(.value),
  #        n = n()) |>
  ggplot(aes(x = pop_id, y = .value, group = fish_id)) +
  geom_line() +
  facet_wrap(~.draw)

#' right away I see a curious thing.. why are the different populations coming out so random?
#'

extraDistr::rdirichlet(29, c(.1,
                 .4,
                 .2,
                 .2,
                 .1)*200) |> t() |>
  matplot(type = "l")

