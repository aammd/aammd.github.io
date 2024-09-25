library(patchwork)
library(tidyverse)


trans_competition <- function(vcomp){
  - exp(vcomp)
}

trans_consumption <- function(vprey, vpred){
  -(1 - plogis(vprey))/plogis(vpred)
}

trans_food_eaten <- function(vprey){
  1 - plogis(vprey)
}

trans_dens_depend <- function(vdens){
  plogis(vdens)
}

fill_competition <- function(mat,
                             res,
                             comp_vec){
  # browser()
  g <- tidyr::expand_grid(r1 = res, r2 = res) |>
    filter(r1 != r2)

  mat[as.matrix(g)] <- comp_vec

  return(mat)

}
# predation effects

fill_predation <- function(mat, res, con, pred_effect_vec){
  mat[as.matrix(expand.grid(res, con))] <- pred_effect_vec
  return(mat)
}

fill_food <- function(mat, res, con, food_effect_vec){
  mat[as.matrix(expand.grid(con, res))] <- food_effect_vec
  return(mat)

}

fill_dens_dep <- function(mat, res, con, dd_vec){
  stopifnot(
    (length(res) + length(con)) == length(diag(mat))
    )
  diag(mat) <- dd_vec
  return(mat)
}

simulate_interaction <- function(){
n_r <- 6
n_c <- 1
res <- 1:n_r
con <- (n_r+1):(n_r + n_c)

# competition
B_mat <- matrix(0, n_r + n_c, n_r + n_c)

comp_r <- rnorm(n_r^2 - n_r, mean = -2, sd = .3)
pred_r <- rnorm(n_r * n_c, mean = 0, sd = 1)
food_r <- rnorm(n_r * n_c, mean = 2, sd = 1)
dens_r <- rnorm(n_r + n_c, mean = -2, sd = .5)

B_mat_fill <- B_mat |>
  fill_competition(res = res,
                   comp_vec = comp_r |>
                     trans_competition()) |>
  fill_predation(res = res,
                 con = con,
                 pred_effect_vec =
                   trans_consumption(vprey = food_r,
                                     vpred = pred_r)) |>
  fill_food(res = res,
            con = con,
            food_effect_vec = food_r |>
              trans_food_eaten()) |>
  fill_dens_dep(res, con,
                dd_vec = dens_r |>
                  trans_dens_depend())



S <- n_r + n_c

# B <- matrix(rnorm(S*S, mean = 0, sd = .2), ncol=S, nrow=S)
# diag(B) <- rbeta(S, .6*7, .4*7)
A <- c(exp(rnorm(n = n_r, 1.5, .5)),
       -exp(rnorm(n = n_c, -1, .2)))
nsteps <- 20
pop_sizes <- matrix(0, nrow = S, ncol = nsteps)
start <- c(rep(log(20), times = S - n_c), rep(0, n_c))
pop_sizes[,1] <- start

introd_time <- 10

for (i in 2:nsteps){
  pop_sizes[,i] <- A + B_mat_fill %*% pop_sizes[,i-1]
  if(i < introd_time) {
    pop_sizes[con,i] = 0
  } else if(i == introd_time) {
    pop_sizes[con,i] = log(20)
  }
}

pop_sizes_long <- pop_sizes |>
  as.data.frame() |>
  rownames_to_column(var = "sp") |>
  pivot_longer(-sp, names_to = "time", values_to = "abd") |>
  mutate(time = parse_number(time))|>
  mutate(is_pred = sp %in% con)

# browser()
logplot <- pop_sizes_long |>
  ggplot(aes(x = time, y = abd,
             group = sp, col = is_pred)) + geom_line() +
  # facet_wrap(~sp, ncol = 1) +
  NULL


abdplot <- pop_sizes_long |>
  ggplot(aes(x = time, y = exp(abd), group = sp,
             col = is_pred)) + geom_line() +
  # facet_wrap(~sp, ncol = 1) +
  NULL
#
print(A)
print(B_mat_fill)
logplot + abdplot

}

simulate_interaction()

