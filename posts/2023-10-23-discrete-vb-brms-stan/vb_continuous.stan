data {
  int n;
  vector[n] time;
  vector[n] size_obs;
}
parameters {
  real<lower=0> Lstart;
  real<lower=0> Lmax;
  real<lower=0> r;
  real<lower=0> sigma;
}
model {
  vector[n] mu;
  mu = Lstart * exp(-r*time) + Lmax*(1 - exp(-r * time));

  size_obs ~ normal(mu, sigma);
}
