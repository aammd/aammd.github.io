data {
  int n;
  array[n] vector[5] P;
  vector[n] chl;
}
parameters {
  real intercept;
  real slope;
  real<lower=0> sd_chl;
  real<lower=0> sd_P;
  vector[n] true_P;
}
model {
  intercept ~ normal(60, 5);
  slope ~ normal(5, 2);
  sd_chl ~ exponential(.5);
  sd_chl ~ exponential(1);
  for (i in 1:n){
    P[i] ~ normal(true_P[i], sd_P);
  }
  chl ~ normal(true_P, sd_chl);
}
