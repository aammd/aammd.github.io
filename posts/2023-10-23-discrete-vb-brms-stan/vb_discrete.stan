data {
  int<lower=0> n;
  real age_first_meas;
  vector[n-1] time_diff;
  vector[n] obs_size;
}
parameters {
  real<lower=0> Lstart;
  real<lower=0> Lmax;
  real<lower=0> r;
  real<lower=0> sigma;
}
model {
  Lstart ~ normal(10, 2);
  Lmax ~ normal(120, 10);
  r ~ exponential(1);
  sigma ~ exponential(1);

  {
  vector[n] true_size;
  // could add measurment error to age
  obs_size[1] ~ normal(Lstart * exp(-r*age_first_meas) + Lmax*(1 - exp(-r * age_first_meas)), sigma);
  obs_size[2:n] ~ normal(obs_size[1:(n-1)] .* exp(-r*time_diff) + Lmax*(1 - exp(-r*time_diff)), sigma);
  }
}
generated quantities {
  vector[5] mu;
  vector[5] obs;
  mu[1] = Lstart;

  for (i in 2:5){
    mu[i] = mu[i-1] .* exp(-r*5) + Lmax*(1 - exp(-r*5));
  }

  for( j in 1:5){
    obs[j] = normal_rng(mu[j], sigma);
  }

}
