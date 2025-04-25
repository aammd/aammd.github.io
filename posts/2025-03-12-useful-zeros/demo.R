
library(tidyverse)
library(rstan)
library(brms)

ngenotypes <- 300

rep_per_geno <- 3

r_bar <- 1.3

r_sd <- .3

r_geno <- rnorm(n = ngenotypes, mean = r_bar, sd = r_sd)

curve(1*exp(r_bar*x), xlim = c(0,2.5), lwd = 2)
walk(r_geno, ~curve(exp(.*x), add = TRUE, lwd = .5))

## project the growth of each original female
aphid_clone_data <- expand_grid(
  rep_id = 1:rep_per_geno,
  clone_id = 1:ngenotypes,
  first_aphid = 1:2,
  ) |>
 mutate(
   clone_r = r_geno[clone_id],
   expect_aphids = 1*exp(clone_r*2),
   obs_aphids = rpois(n = length(expect_aphids), lambda = expect_aphids)
   )

# add in mortality and combine aphids
aphid_clone_mort_dat <- aphid_clone_data |>
  mutate(surv = rbinom(length(obs_aphids), size = 1, prob = .8),
         obs_aphids_alive = obs_aphids * surv)

aphid_clone_mort_sum <- aphid_clone_mort_dat |>
  group_by(clone_id, rep_id) |>
  summarize(tot_aphids = sum(obs_aphids_alive))

# visualize:

aphid_clone_mort_sum |>
  ggplot(aes(x = tot_aphids)) +
  geom_histogram()

# try it with brms
poisson_mix_mortality <- custom_family(
  "poisson_mix_mortality",
  dpars = c("mu", "m"),
  links = c("identity", "identity"),
  lb = c(NA, 0), ub = c(NA,1),
  type = "int",
  #vars = "vint1[n]"
  loop = TRUE
)


poisson_mix_mortality_fns <- "
real poisson_mix_mortality_lpmf(int abd_i, real mu, real m) {
    real ll;
    if (abd_i == 0) {
      ll = log_sum_exp(
        [
          2 * log(m),
          log(2) + log(m) + log1m(m) + poisson_log_lpmf(abd_i | mu),
          2 * log1m(m) + poisson_log_lpmf(abd_i | log(2) + mu)
        ]
      );
    } else {
      ll = log_sum_exp(
        log(2) + log(m) + log1m(m) + poisson_log_lpmf(abd_i | mu),
        2 * log1m(m) + poisson_log_lpmf(abd_i | log(2) + mu)
      );
    }
    return ll;
  }
int poisson_mix_mortality_rng(real mu, real m) {
 real p1 = square(m);  // Pr[0] component: both die
 real p2 = 2 * m * (1 - m);  // One dies, one lives
 real p3 = square(1 - m);    // Both live

    // Normalize to ensure valid probabilities
 real total = p1 + p2 + p3;
 p1 /= total;
 p2 /= total;
 p3 /= total;

    // Sample which mortality path to take
    real u = uniform_rng(0, 1);
    int n;
    if (u < p1) {
      n = 0;  // both dead
    } else if (u < p1 + p2) {
      n = poisson_log_rng(mu);  // one survives
    } else {
      n = poisson_log_rng(log(2) + mu);  // both survive
    }

    return n;
  }
"

stanvars <- stanvar(scode = poisson_mix_mortality_fns,
                    block = "functions")


# fit the model! NOTE that this is the "wrong" model because there actually ARE
# differences between clones, and this model ignores them. To test it properly,
# run the simulation above but use sd = 0 or a very small number
poisson_mix_brm <- brm(
  tot_aphids ~ 0 + time,
  data = aphid_clone_mort_sum |>
    mutate(time = 2),
  family = poisson_mix_mortality,
  stanvars = stanvars,
  chains = 1
)


poisson_mix_bf <- bf(
  tot_aphids ~ 0 + time + (0 + time | clone_id),
  family = poisson_mix_mortality)

get_prior(poisson_mix_bf,
          data = aphid_clone_mort_sum |>
    mutate(time = 2))

pois_mix_prior <- c(
  prior(normal(1.5, 2), class = "b", coef = "time"),
  prior(beta(7*.3, 7*(1-.3)), class = "m", lb = 0, ub = 1),
  prior(exponential(3), class="sd")
)

hier_poisson_mix_brm <- brm(
  tot_aphids ~ 0 + time + (0 + time | clone_id),
  data = aphid_clone_mort_sum |>
    mutate(time = 2),
  family = poisson_mix_mortality,
  stanvars = stanvars,
  prior = pois_mix_prior,
  chains = 4, cores = 4
)


