data {
  int n;
  int nindiv;
  array[nindiv] int<lower=1, upper=3> group_id;
  array[n] int<lower=1, upper=nindiv> indiv_id;
  vector[n] x_variable;
}
transformed data {
  matrix[3, 3] contr = [
    [1, -0.707106781186548,     0.408248290463863],
    [1, -7.85046229341888e-17, -0.816496580927726],
    [1,  0.707106781186547,     0.408248290463863]
    ];
}
parameters {
  vector[n] obs;
  matrix[3, 2] betas;
  real intercept;
  vector[nindiv] slope;
  real<lower=0> sigma_obs;
}
transformed parameters {
  matrix[3, 2] m = contr * betas;
  vector[nindiv] mu = m[group_id,1];
  vector[nindiv] sigma = exp(m[group_id,2]);
}
model{
  to_vector(betas) ~ std_normal();
  intercept ~ normal(15, 2);
  slope ~ normal(mu, sigma);
  sigma_obs ~ exponential(1);
  obs ~ normal(x_variable .* slope[indiv_id] + intercept, sigma_obs);
}
generated quantities {
  vector[3] yrep;
  for (k in 1:3) {
    yrep[k] = normal_rng(m[k,1], exp(m[k,2]));
  }
}
