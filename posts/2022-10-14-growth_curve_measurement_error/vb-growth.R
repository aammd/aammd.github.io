sim_vb_one_tree <- function(
    time = seq(from = 10, to = 200, by = 5),
    Lo = .01,
    Lmax = 150,
    r = .03,
    sd = 5){
  tibble::tibble(time,
                 Lt = Lmax - (Lmax - Lo) * exp(-r*time),
                 Lt_obs  = rnorm(length(Lt),
                                 mean = Lt,
                                 sd = 5))
}


sim_vb_one_tree_and_new <- function(
    time = seq(from = 0, to = 200, by = 5),
    Lo = 15,
    Lmax = 150,
    r = .03,
    sd = 5){


  Lt_bar = Lmax - (Lmax - Lo) * exp(-r*time)
  Lt  = rnorm(length(Lt_bar),
              mean = Lt_bar,
              sd = sd)

  list(n = length(time),
       time = time,
       Lt = Lt,
       t = 6,
       L1new = rnorm(1, mean = 31, sd = sd),
       timenew = c(0, 5, 10, 60, 120, 200)
  )
}
