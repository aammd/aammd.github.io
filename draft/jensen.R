# a power law

a <- 2.3
b <- 0.128

curve(a*x^b, xlim = c(0, 42))

ngroups <- 7
mu_g <- rnorm(ngroups, 35, 15)
sd_g <- rexp(ngroups, rate = .12)

n_indiv_g <- 37

library(tidyverse)
sim_data <- tibble(mu = mu_g,
             sd = sd_g,
             group_id = 1:ngroups) |>
  rowwise() |>
  mutate(xs = list(rgamma(n_indiv_g, mu^2/sd^2, mu/sd^2)),
         f_mu_x = a*mu^b) |>
  unnest(cols = c(xs)) |>
  group_by(group_id) |>
  mutate(
    ys = a*xs^b,
    mu_y = mean(ys)) |>
  ungroup()


curve(dgamma(x, 5^2/1, 5), xlim = c(0, 10))

base_plot <- tibble(x = c(0, 42),
       y = a*x^b) |>
  ggplot(aes(x = x)) +
  stat_function(fun = \(x) a*x^b)

base_plot +
  geom_point(aes(x = xs, y = ys, col = as.factor(group_id)), data = sim_data)

base_plot +
  geom_point(aes(x = xs, y = mu_y, col = as.factor(group_id)), data = sim_data)


base_plot +
  geom_point(aes(x = xs, y = mu_y, col = as.factor(group_id)), data = sim_data) +
  geom_point(aes(x = mu, y = a*mu^b, fill = as.factor(group_id)), pch = 21, data = sim_data)



## if you can measure x and y on each individual

