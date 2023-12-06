library(targets)
library(stantargets)
library(tarchetypes)
# source(here::here("posts/2023-11-24-how-to-model-growth/functions.R"))
tar_option_set(packages = c("tidyverse","tidybayes"))

simulate_pop_growth <- function(
    a = 0,
    b,
    sigma = 1,
    tmax = 50,
    x0 = -8) {

  xvec <- numeric(tmax)

  xvec[1] <- x0

  ## process error
  eta <- rnorm(tmax, mean = 0, sd = sigma)

  for(time in 2:tmax){
    xvec[time] <- a + b*xvec[time-1] + eta[time]
  }

  return(xvec)
}

list(
  tar_target(
    one_time,
    command = simulate_pop_growth(b = 0.82)
  ),

  tar_quarto(post, here::here("posts/2023-11-24-how-to-model-growth/index.qmd")

  )
)
