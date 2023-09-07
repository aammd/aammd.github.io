data {
  int n;
  vector[n] speed_limit;
  vector[n] obs_speed;
  real max_avg;
  real max_sd;
}
parameters {
  real max_speed;
  real<lower=0> sigma;
}
transformed parameters {
  vector[n] V2;
  for (i in 1:n){
    V2[i] = step(max_speed - speed_limit[i]);
  }
}
model {
  vector[n] mu;
  mu = max_speed + (speed_limit - max_speed) .* V2;
  max_speed ~ normal(max_avg, max_sd);
  obs_speed ~ normal(mu, sigma);
  sigma ~ exponential(1);
}
