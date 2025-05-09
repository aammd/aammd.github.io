data {
  int<lower=0> s;
  // x trait
  int<lower=0> n_x;
  vector[n_x] x_obs;
  array[n_x] int<lower=1,upper=s> sp_id_x;
  // y trait
  int<lower=0> n_y;
  vector[n_y] y_obs;
  array[n_y] int<lower=1,upper=s> sp_id_y;
  cov_matrix[s] phyvcv;
}
transformed data {
  vector[s] zero_vec = rep_vector(0, s);
}
parameters {
  real<offset=2,multiplier=2> b0_x;
  real<offset=.5,multiplier=.8> b0_y;
  real<offset=0.5, multiplier=0.5> b_xy;
  real<lower=0> sigma_x;
  real<lower=0> sigma_y;
  real<lower=0, upper=1> lambda_x;
  real<lower=0, upper=1> lambda_y;
  vector[s] x_avg;
  vector[s] y_avg;
  real<lower=0> sigma_x_obs;
  real<lower=0> sigma_y_obs;
}
model {
  b0_x ~ normal(2, 2);
  b0_y ~ normal(.5, .8);
  b_xy ~ normal(0, .2);
  sigma_x ~ exponential(1);
  sigma_y ~ exponential(1);
  lambda_x ~ beta(9, 1);
  lambda_y ~ beta(5, 5);

  matrix[s, s] vcv_x
    = sigma_x^2 * add_diag(lambda_x * phyvcv, 1 - lambda_x);
  matrix[s, s] vcv_y
    = sigma_y^2 * add_diag(lambda_y * phyvcv, 1 - lambda_y);

  sigma_x_obs ~ exponential(1);
  sigma_y_obs ~ exponential(1);
  // species averages
  x_avg ~ multi_normal(zero_vec, vcv_x);
  y_avg ~ multi_normal(b_xy * x_avg, vcv_y);
  // observations of these
  x_obs ~ normal(b0_x + x_avg[sp_id_x], sigma_x_obs);
  y_obs ~ normal(b0_y + y_avg[sp_id_y], sigma_y_obs);
}
