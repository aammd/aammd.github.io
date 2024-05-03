data {
  int<lower=0> n;
  real age_first_meas;
  vector[n-1] time_diff;
  vector[n] obs_size;
}
parameters {
  real<lower=0> Lstart;
  real<lower=0> Lmax;
  real rbar;
  real<lower=0> sd_r;
  real<lower=0> sigma;
  vector[n-1] rvec_log;
}
model {
  Lstart ~ normal(10, 2);
  Lmax ~ normal(120, 10);
  rvec_log ~ normal(rbar, sd_r);
  sigma ~ exponential(1);

  vector[n] true_size;
  // could add measurment error to age
  true_size[1] = Lstart * exp(-r*age_first_meas) + Lmax*(1 - exp(-r * age_first_meas));
  for (t in 2:n){
    true_size[t] = true_size[t-1] .* exp(-r*time_diff) + Lmax*(1 - exp(-r*time_diff));
  }
  obs_size ~ normal(true_size, sigma);

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
