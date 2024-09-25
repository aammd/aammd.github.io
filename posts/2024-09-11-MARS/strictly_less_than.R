x <- runif(35, -2, 2)
y <- exp(x)

props <- plogis(runif(35, -2, 2), log.p = TRUE)

library(tidyverse)
tibble(x, y, y2 = exp(x + props)) |>
  ggplot(aes(x = x, y = y)) + geom_point() +
  geom_point(aes(y = y2), col = "red")

tibble(x, y, y2 = exp(x + props)) |>
  ggplot(aes(x = y, y = y2)) + geom_point() +
  geom_abline(slope= 1, intercept = 0)


## BUT we want one of these to always be less than 1 but more than 0..
n <- 10000
l_g <- rnorm(n = n)
l_q <- rnorm(n = n)

pred_percap <- -(1 - plogis(l_q))/plogis(l_g)
prey_percap <- 1 - plogis(l_q)

tibble(pred_percap, prey_percap) |>
  ggplot(aes(x = pred_percap, y = prey_percap)) +
  geom_point(alpha = .4) +
  geom_abline(intercept = 0, slope = -1) +
  coord_fixed(x = c(-5, 0))


## BUT we want one of these to always be less than 1 but more than 0..
plot_constrained_prior <- function(
    n = 10000,
    l_g = rnorm(n = n, mean = 0, sd = .8),
    l_q = rnorm(n = n, mean = 0, sd = 1.5)
    ) {
  # pred_percap <- -(1 - plogis(l_q))/plogis(l_g)
  pred_percap <- -(plogis(l_q)*(1 + exp(l_g)))
  # prey_percap <- plogis(l_q)
  prey_percap <- plogis(l_q)

  tibble(pred_percap, prey_percap) |>
    ggplot(aes(x = pred_percap, y = prey_percap)) +
    geom_point(alpha = .4) +
    geom_abline(intercept = 0, slope = -1) +
    coord_cartesian(ylim = c(0, 1)) +
    # coord_fixed(x = c(-5, 0)) +
    NULL
}

plot_constrained_prior(l_g = rnorm(n = n, mean = 0, sd = .6),
                       l_q = rnorm(n = n, mean = 0, sd = 1))

