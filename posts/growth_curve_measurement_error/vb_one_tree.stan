data{
  int<lower=0> n;
  vector[n] time;
  vector[n] Lt;
}
parameters{
  real<lower=0> r;
  real<lower=0> Lmax;
  real<lower=0> sigma_obs;
}
model{
  Lt ~ normal(Lmax * (1 - exp(-r*time)), sigma_obs);
  r ~ lognormal(-3, 1);
  Lmax ~ normal(200, 20);
  sigma_obs ~ exponential(1);
}
