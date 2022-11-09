sim_vb_one_tree <- function(time = seq(from = 10, to = 200, by = 5),
                            Lo = .01,
                            Lmax = 150,
                            r = .03,
                            sd = 5){
  tibble::tibble(time,
         Lt = Lmax - (Lmax - Lo) * exp(-r*time),
         Lt_obs  = rnorm(length(Lt), mean = Lt, sd = 5))
}
