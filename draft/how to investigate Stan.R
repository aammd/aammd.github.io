library(cmdstanr)

matrix_indexing <- cmdstan_model("posts/2024-09-11-MARS/matrix_indexing.stan")

matrix_indexing$sample(
  data = list(N = 3, J = 4, M = matrix(40:51, nrow = 3, ncol = 4), n_obs = 12, vec_idx = 1:12),
  fixed_param = TRUE, chains = 1, iter_warmup = 1, iter_sampling = 1)


# BONUS this will work if one observation was made twice -- e.g. if there were
# different observers or repeated measures of one timepoint
matrix_indexing$sample(
  data = list(N = 3, J = 4, M = matrix(40:51, nrow = 3, ncol = 4),
              n_obs = 10, vec_idx = c(1,2,3,4,4,7,8,9,10,12)),
  fixed_param = TRUE, chains = 1, iter_warmup = 1, iter_sampling = 1)

