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
  Lmax ~ normal(420, 10);
  r ~ exponential(1);
  sigma ~ exponential(1);

  vector[n] true_size;
  // could add measurment error to age
  true_size[1] = Lstart * exp(-r*age_first_meas) + Lmax*(1 - exp(-r * age_first_meas));
  for (t in 2:n){
    true_size[t] = true_size[t-1] * exp(-r*time_diff[t-1]) + Lmax*(1 - exp(-r*time_diff[t-1]));
    // print(true_size[t])
  }
  obs_size ~ normal(true_size, sigma);

}
generated quantities {
  vector[10] mu;
  vector[10] obs;
  mu[1] = Lstart;

  for (i in 2:10){
    mu[i] = mu[i-1] .* exp(-r) + Lmax*(1 - exp(-r));
  }

  for( j in 1:10){
    obs[j] = normal_rng(mu[j], sigma);
  }

}
