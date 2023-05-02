data {
  int<lower=0> N;
  vector[N] measure;
  vector[N] time;
}
parameters {
  real<lower=0> t0;
  real<lower=0> sigma_obs;
  real<lower=0> r;
  real<lower=0> Lmax;
}
model {
  measure ~ normal(Lmax * (1 - exp(-r * (time - t0))), sigma_obs);
  // or, calculate on log scale
  // vector[N] ln_meas;
  // ln_meas = ln_Lmax + log1m_exp(-r * (time - t0))
  // could be very convenient to switch to lognormal later
  // measure ~ normal(exp(ln_meas), sigma_obs));
}

