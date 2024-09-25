data{
  int<lower=0> n_fish; // number of fish per sample from each lake
  int <lower=0> n_pop; // number of stocking populations
  vector[n_pop] start_prop; // starting proportions of

  real<lower=0> sd_pop;
  real<lower=0> log_phi_mu;
}
parameters {
  vector[n_pop] logit_change;
  real log_phi;
}
transformed parameters {
  real<lower=0> phi;
  phi = exp(log_phi);
}
model {
  logit_change ~ normal(0, sd_pop);
  // phi ~ exponential(phi_rate);
  log_phi ~ normal(log_phi_mu, 1);

  vector[n_pop] p;
  p = start_prop + softmax(logit_change);
}
generated quantities{
  array[n_fish] vector[n_pop] d;

  vector[n_pop] p;
  p = start_prop + softmax(logit_change);

  for (i in 1:n_fish) {
    d[i] = dirichlet_rng(p*phi);
  }
}
