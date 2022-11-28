## functions to make models and so on
simulate_many_moms <- function(pop_average_dponte = 138,
                               pop_average_csize = 4,
                               mom_quality_max = 4,
                               quality_on_dponte = 2,
                               quality_on_csize = .2,
                               n_females = 42,
                               lifespan = 5,
                               temp_range  = c(2, 12)) {

  general_temp <- runif(lifespan, temp_range[1], max = temp_range[2])

  general_temp_c <- general_temp - mean(general_temp)

  mom_qualities <- runif(n_females, min = 0, max = 4)

  many_moms_temperature <- expand_grid(year = 1:lifespan,
                                       idF1 = 1:n_females) |>
    mutate(mom_quality = mom_qualities[idF1],
           general_temp = general_temp[year],
           general_temp_c = general_temp_c[year],
           ## adding the biology
           ## Effect of temperature -- does it depend on quality? let's say that it DOES (for now)
           effet_temp_dponte_qual = -.7*mom_quality,
           effet_temp_csize_qual = .1*log(mom_quality),
           # csize
           mom_avg_csize = log(pop_average_csize) +  quality_on_csize*log(mom_quality),
           temp_avg_csize = exp(mom_avg_csize + effet_temp_csize_qual*general_temp_c),
           # dponte
           mom_avg_dponte = pop_average_dponte + quality_on_dponte*mom_quality,
           temp_avg_dponte = mom_avg_dponte + effet_temp_dponte_qual*general_temp_c,
           ## observations
           obs_csize = rpois(n = length(year), lambda = temp_avg_csize),
           obs_dponte = rnorm(n = length(year), mean = temp_avg_dponte, sd = 3) |> round()
    )
  return(many_moms_temperature)
}


brms_dponte_csize <- function(many_moms_temperature) {
  ## define formulae
  csize_model_bf <- bf(obs_csize ~ 1 + general_temp_c + (1 + general_temp_c|f|idF1),
                       family = poisson())

  dponte_model_bf <- bf(obs_dponte ~ 1 + general_temp_c + (1 + general_temp_c|f|idF1),
                        family = gaussian())


  ## set priors

  ## run full model
  full_model <- brm(csize_model_bf + dponte_model_bf,
                    data = many_moms_temperature,
                    cores = 2, chains = 2)
}
