data {
  int n;
  int nroo;
  vector[n] leg;
  vector[n] time_since_capture;
  array[n] int<lower=1, upper=nroo> roo_id;
  int n_known_age;
  int n_unk_age;
  vector[n_known_age] age_at_capture;
  array[n_unk_age] int<lower=1, upper=nroo> ii_unobs;
  array[n_known_age] int<lower=1, upper=nroo> ii_known;
}
parameters {
  vector<lower=2>[n_unk_age] t0_param;
  vector<lower=0,upper=1>[nroo] r;
  real Lmax;
  real<lower=0> sigma_meas;
}
transformed parameters {
  vector[nroo] t0;
  t0[ii_known] = age_at_capture;
  t0[ii_unobs] = t0_param;
}
model {
  sigma_meas ~ exponential(1);
  Lmax ~ normal(500, 50);
  r ~ beta(.3*5, (1-.3)*5);
  t0_param ~ uniform(2,10);
  leg ~ normal(Lmax * (1 - exp(-r[roo_id] .* (time_since_capture + t0[roo_id]))), sigma_meas);
}
