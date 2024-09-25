## brms / tidybayes error with nested random effects

library(tidybayes)
library(brms)
library(palmerpenguins)


# estimating ld50 for a hierarchial model

bf()

# two parameters in one of these curves

curve(plogis(-4*(log(x) - 5)), xlim = c(0, 300))

mean(rexp(1000, rate = 1))

logld50_mean <- 5
logb_mean <- 1.3
ngroup <- 41
logb_group <- rnorm(ngroup, mean = 0, sd = .2)
logld50_group <- rnorm(ngroup, mean = 0, sd = .5)

library(tidyverse)

exp(5)



expand_grid(x = seq(10, 300, length.out = 15),
            id = 1:45) |>
  mutate(pr_survive = plogis(-exp(logb_mean + logb_group[id]) * (log(x) - logld50_mean + logld50_group[id]))) |>
  ggplot(aes(x = x, y = pr_survive, group = id))  +
  geom_line()
