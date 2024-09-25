data{
  int<lower=0> n;
  real<lower=0> log_phi_mu;
  vector[4] start_prop;
}
parameters {
  vector[4] logit_drift;
  real log_phi;
}
transformed parameters {
  real<lower=0> phi;
  phi = exp(log_phi);
}
model {
  logit_drift ~ std_normal();
  // phi ~ exponential(phi_rate);
  log_phi ~ normal(log_phi_mu, 1);

  vector[4] p;
  p = start_prop + softmax(logit_drift);
}
generated quantities{
  array[n] vector[4] d;

  vector[4] p;
  p = start_prop + softmax(logit_drift);

  for (i in 1:n) {
    d[i] = dirichlet_rng(p*phi);
  }
}
