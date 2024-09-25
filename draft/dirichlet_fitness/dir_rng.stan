data{
  int<lower=0> n;
  real<lower=0> sd_phi;
}
parameters {
  vector[4] a;
  real log_phi;
}
transformed parameters {
  vector[4] p;
  p = softmax(a);
  real<lower=0> phi;
  phi = exp(log_phi);
}
model {
  a ~ std_normal();
  // phi ~ exponential(phi_rate);
  log_phi ~ normal(0, sd_phi);
}
generated quantities{
  array[n] vector[4] d;

  for (i in 1:n) {
    d[i] = dirichlet_rng(p*phi);
  }
}
