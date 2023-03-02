### fitting different versions of the functional response


library(cmdstanr)
library(tidyverse)
library(tidybayes)


simple_fr_advice <- cmdstan_model(here::here("ben_predators", "simple_type2.stan"),
                                  stanc_options = list("warn-pedantic" = TRUE))



holling_dens <- rep((2:20)^2, each = 8)

binom_attacks <- rbinom(length(holling_dens),
                        prob = .7/(1 + 0.029*.7*holling_dens),
                        size = holling_dens)

datlist <- list(attacks = binom_attacks,
                densities = holling_dens,
                N = length(holling_dens))



simple_samp_advice <- simple_fr_advice$sample(data = datlist, parallel_chains = 4)

simple_samp_advice$summary()


## plot it

post_predictions <- tibble(densities = unique(holling_dens)) |>
  bind_cols(simple_samp_advice |>
              spread_rvars(a, h)) |>
  mutate(prob = a/(1 + a * h * densities),
         expected = prob*densities)

post_epred_plot <- post_predictions |>
  ggplot(aes(x = densities, dist = expected)) +
  stat_dist_lineribbon()

post_epred_plot +
  geom_count(aes(x = densities, y = attacks), inherit.aes = FALSE, data = as_tibble(datlist[c("attacks","densities")]))


# posterior predictive with rvars

test <- post_predictions |>
  rowwise() |>
  mutate(postpred = posterior::rdo(rbinom(1, size = densities, prob = prob)))

test |>
  ggplot(aes(x = densities, dist = postpred)) + stat_dist_lineribbon() +
  scale_fill_brewer(palette = "Greens") +
  geom_count(aes(x = densities, y = attacks),
             inherit.aes = FALSE,
             data = as_tibble(datlist[c("attacks","densities")]), fill = "orange", pch = 21)

post_epred_plot +
  geom_count(aes(x = densities, y = attacks), inherit.aes = FALSE, data = as_tibble(datlist[c("attacks","densities")]))





# multiple species --------------------------------------------------------



# biomasses of three prey
B1 <- round(runif(30, 0, 50))
B2 <- round(runif(5, 0, 50))
B3 <- round(runif(5, 0, 50))

# consumpation rates for three prey
# bvec <- runif(3, min = 0, max = 1)

bvec <- c(.1, .8, .3)

handle_pred <- .2

library(tidyverse)

communities <- expand_grid(B1, B2, B3)



fake_rates <- communities |>
  rowwise() |>
  mutate(
    # two ways to calculate
    sum_of_all = bvec[1]*B1 + bvec[2]*B2 + bvec[3]*B3,
    # sum_of_all = (bvec %*% c(B1, B2, B3))[,],
    denom = 1 + handle_pred*sum_of_all,
    B1_attack_prob = bvec[1]/denom,
    B2_attack_prob = bvec[2]/denom,
    B3_attack_prob = bvec[3]/denom,
    B1_attacks = rbinom(1, size = B1, prob = B1_attack_prob),
    B2_attacks = rbinom(1, size = B2, prob = B2_attack_prob),
    B3_attacks = rbinom(1, size = B3, prob = B3_attack_prob),
    )



multiple_fr <- cmdstan_model(here::here("ben_predators", "multiple_type2.stan"),
                      stanc_options = list("warn-pedantic" = TRUE))

data_list <- list(N = nrow(fake_rates),
                  R = 3,
                  attacks = as.matrix(fake_rates[,c("B1_attacks", "B2_attacks", "B3_attacks")]),
                  densities = as.matrix(fake_rates[,c("B1", "B2", "B3")]))

multiple_demo <- multiple_fr$sample(data= data_list, parallel_chains = 4)

multiple_demo$summary()

bvec

library(tidybayes)

tidy_draws(multiple_demo)

spread_rvars(multiple_demo, a[spp]) |>
  ggplot(aes(y = spp, dist = a)) +
  stat_dist_halfeye()

# draw a curve



# multiple species optimized ----------------------------------------------
multiple_fr <- cmdstan_model(here::here("ben_predators", "multiple_type2_modified.stan"),
                      stanc_options = list("warn-pedantic" = TRUE))


multiple_demo <- multiple_fr$sample(data= data_list, parallel_chains = 4)

model_posterior <- spread_rvars(multiple_demo, a[spp], h) |>
  mutate(spp = paste0("spp", spp)) |>
  pivot_wider(names_from = spp, values_from = a)

library(modelr)

model_predictions <- fake_rates |>
  data_grid(#B1 = seq(from = 1, to = 1000, by = 50),
            B1 = seq_range(B1,by = 5),
            B2 = median(B2),
            B3 = median(B3)) |>
  bind_cols(model_posterior) |>
  mutate(p_predation = spp1/(1 + h * (spp1 * B1 + spp2 * B2 + spp3 * B3)))

model_predictions |>
  ggplot(aes(x = B1, dist = p_predation)) +
  stat_dist_lineribbon()

# response
model_predictions |>
  mutate(mean_binom = p_predation*B1) |>
  ggplot(aes(x = B1, dist = mean_binom)) +
  stat_dist_lineribbon() +
  geom_count(aes(x = B1, y = B1_attacks), data = fake_rates, inherit.aes = FALSE)

model_predictions |>
  mutate(post_pred = rbinom(1, size = B1, prob = p_predation))


fake_rates |>
  ggplot(aes(x = B1, y = B1_attacks)) + geom_count()


 # just observe the prediction on the real dataset

combined_cols <- fake_rates |>
  ungroup() |>
  bind_cols(model_posterior)

posterior_pred <- combined_cols |>
  mutate(denom = 1 + h * (spp1 * B1 + spp2 * B2 + spp3 * B3),
         B1_prob = spp1/denom,
         B2_prob = spp2/denom,
         B3_prob = spp3/denom)

B1_post_true <- posterior_pred |>
  ggplot(aes(x = B1_attack_prob, dist = B1_prob)) + stat_dist_pointinterval()

B1_post_true +
  geom_abline(slope = 1, intercept = 0, col = "green" )

posterior_pred |>
  ungroup() |>
  sample_n(20) |>
  mutate(B1_expect = B1_prob * B1) |>
  ggplot(aes(x = B1, dist = B1_expect)) + stat_dist_pointinterval() +
  geom_count(aes(y = B1_attacks), pch = 21, fill = "orange")

posterior_pred |>
  ungroup() |>
  mutate(B2_expect = B2_prob * B2) |>
  ggplot(aes(x = B2, dist = B2_expect)) + stat_dist_pointinterval() +
  geom_count(aes(y = B2_attacks),pch = 21, fill = "orange")




# outer product -----------------------------------------------------------

multiple_fr <- cmdstan_model(here::here("ben_predators", "multiple_outer_product.stan"),
                      stanc_options = list("warn-pedantic" = TRUE))



multiple_demo <- multiple_fr$sample(data= data_list, parallel_chains = 4)

multiple_demo$summary()

# single species -- biomass -----------------------------------------------





# multiple species biomass ------------------------------------------------







