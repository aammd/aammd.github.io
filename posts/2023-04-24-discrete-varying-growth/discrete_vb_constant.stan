data {
  int<lower=0> N;
  vector[N] measure;
}
parameters {
  real<lower=0> L0;
  real<lower=0> sigma_obs;
  real<lower=0> r;
  real<lower=0> Lmax;
}
model {
  r ~ exponential(1);
  Lmax ~ normal(250, 20);
  sigma_obs ~ exponential(1);
  L0 ~ std_normal();
  measure[2:N] ~ normal(measure[1:(N-1)] * exp(-r) + Lmax * (1 - exp(-r)), sigma_obs);

  // or, calculate on log scale
  // vector[N] ln_meas;
  // ln_meas = ln_Lmax + log1m_exp(-r * (time - t0))
  // could be very convenient to switch to lognormal later
  // measure ~ normal(exp(ln_meas), sigma_obs));
}

