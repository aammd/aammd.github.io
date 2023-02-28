data{
  int<lower=0> n;
  vector[n] time;
  vector[n] Lt;
  int<lower=0> n_new;
  vector[n_new] time_new;
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
generated quantities{
  vector[n_new] Lt_predicted;

  for (i in 1:n_new){
    Lt_predicted[i] = normal_rng(Lmax * (1 - exp(-r*time_new[i])), sigma_obs);
  }
}
