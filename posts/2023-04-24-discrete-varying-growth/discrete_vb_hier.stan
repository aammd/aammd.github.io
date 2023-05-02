// this doesnt work -- need to switch to the for-loop version when I come back here
data {
  int<lower=0> N;
  vector[N] measure;
  int<lower=0> Nindiv;
  array[N] int<lower=1,upper=Nindiv> indiv_id;
}
parameters {
  real<lower=0> L0;
  real<lower=0> sigma_obs;
  real<lower=0> r;
  real<lower=0> Lmax;
}
model {
  vector[N] rlog;
  rlog = rlog_bar + r_indiv[indiv_id];

  r ~ exponential(1);
  Lmax ~ normal(250, 20);
  sigma_obs ~ exponential(1);
  L0 ~ std_normal();
  measure[2:N] ~ normal(measure[1:(N-1)] * exp(-r) + Lmax * (1 - exp(-r)), sigma_obs);
}

