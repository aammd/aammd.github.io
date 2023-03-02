
tar_option_set(packages = c("cmdstanr",
               "ggplot2", "tidybayes", 
               "stantargets"))

generate_one_spp_type_too <- function(){
  true_a <- stats::rbeta(n = 1, 8, 4)
  true_h <- stats::rlnorm(n = 1, -2, .5)
  densities <- seq(from = 5, to = 100, by =5)
  prob <- true_a/(1 + true_a * true_h * densities)
  attacks <- rbinom(n = length(densities), size = densities, prob = prob)
  list(
    N = length(attacks),
    true_a = true_a,
    true_h = true_h,
    densities = densities,
    attacks = attacks, 
    prob = prob
    )
}

