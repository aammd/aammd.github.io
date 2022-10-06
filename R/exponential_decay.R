# exponential decay

make_decay_data_additive <- function(M0 = 40,
                                     r_mean = .2,
                                     time = seq(0, 20, by = 2),
                                     n_group  = 15, sd_group = .2) {

  group_offsets <- rnorm(n_group, mean = 0, sd = sd_group)

  # make the group
  expand_grid(time,
              group_id = 1:n_group) |>
    mutate(r_group = group_offsets[group_id] + r_mean,
           mass = M0 * exp(-r_group*time))
}

make_decay_data_multiplicative <- function(M0 = 40,
                                           log_r_mean = -1.5,
                                           time = seq(0, 20, by = 2),
                                           n_group  = 15,
                                           sd_group = .2) {

  group_offsets <- rnorm(n_group, mean = 0, sd = sd_group)

  expand_grid(time,
            group_id = 1:n_group) |>
  mutate(r_group = exp(group_offsets[group_id] + log_r_mean),
         mass = M0 * exp(-r_group*time))
}

plot_group_df <- function(df){

  M0 <- max(df$mass)

  df |>
    ggplot(aes(x = time, y = mass, group = group_id)) +
    geom_line() +
    ylim(0, M0 + 15)
}



