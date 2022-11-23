data{
  int<lower=0> n;
  vector[n] time;
  vector[n] Lt;
  int<lower=0> t;
  real<lower=0> L1new;
  vector[t] timenew;
}
parameters{
  real<lower=0> r;
  real<lower=0> Lmax;
  real<lower=0> sigma_obs;
  real<lower=0> Lo;
  real<lower=0> Lo_new;
  vector[t-1] L_future;
}
transformed parameters{
  vector[t] Lnew;
  Lnew[1] = L1new;
  Lnew[2:t] = L_future;
}
model{

  Lt ~ normal(Lo * exp(-r*time) + Lmax * (1 - exp(-r*time)),sigma_obs);
  r ~ lognormal(-3, 1);
  Lmax ~ normal(200, 20);
  sigma_obs ~ exponential(1);
  Lo ~ normal(20, 20);

  // model unobserved values too
  Lnew ~ normal(
    Lo_new * exp(-r*timenew) + Lmax * (1 - exp(-r*timenew)),
    sigma_obs
    );
}
