data {
  int n;
  vector[n] leg;
  vector[n] time_since_capture;
  real age_at_capture;
}
parameters {
  real<lower=0,upper=1> r;
  real Lmax;
  real<lower=0> sigma_meas;
}
model {
  r ~ beta(.3*5, (1-.3)*5);
  Lmax ~ normal(50, 10);
  sigma_meas ~ exponential(1);

  leg ~ normal(Lmax * (1 - exp(-r * (time_since_capture + age_at_capture))), sigma_meas);
}
generated quantities {
  vector[n] pred_leg;
  for (i in 1:n){
    pred_leg[i] = normal_rng(Lmax * (1 - exp(-r * (time_since_capture[i] + age_at_capture))), sigma_meas);
  }
}
