library(rstan)

mixture_growth_post <- mixture_growth_hier$sample(
  data = list(n = nrow(aphid_clone_mort_sum),
              time = 2,
              abd = aphid_clone_mort_sum$tot_aphids,
              nclone = max(aphid_clone_mort_sum$clone_id),
              clone_id = aphid_clone_mort_sum$clone_id),
  refresh = 0, parallel_chains = 4)

mixture_growth_post$summary()

mixture_growth_hier_post <- rstan::stan(
  file = here::here("posts/2025-03-12-useful-zeros/mixture_growth_hier.stan"),
  data = list(n = nrow(aphid_clone_mort_sum),
              time = 2,
              abd = aphid_clone_mort_sum$tot_aphids,
              nclone = max(aphid_clone_mort_sum$clone_id),
              clone_id = aphid_clone_mort_sum$clone_id
            ), chains = 4, cores = 4)

