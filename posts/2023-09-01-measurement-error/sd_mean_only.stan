data {
  int n;
  // array[n] vector[5] P;
  vector[n] P_sds;
  vector[n] P_means;
  vector[n] chl;
}
parameters {
  real intercept;
  real slope;
  real<lower=0> sd_chl;
  vector[n] true_P;
}
model {
  intercept ~ normal(60, 5);
  slope ~ normal(5, 2);
  sd_chl ~ exponential(1);
  true_P ~ normal(P_means, P_sds);
  chl ~ normal(true_P, sd_chl);
}
