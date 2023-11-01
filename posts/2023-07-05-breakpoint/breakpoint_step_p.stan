data {
  int n;
  vector[n] speed_limit;
  vector[n] obs_speed;
  real max_avg;
  real max_sd;
}
parameters {
  real factory_speed;
  real<lower=0> sigma;
  real alpha;
}
transformed parameters {
  real max_speed;
  max_speed = factory_speed * inv_logit(alpha);
  vector[n] V2;
  for (i in 1:n){
    // step() is 0 if speed limit is over the maximum, 0 otherwise
    // in other words, it gives the slope
    V2[i] = step(max_speed - speed_limit[i]);
  }
}
model {
  vector[n] mu;
  mu = max_speed + (speed_limit - max_speed) .* V2;
  factory_speed ~ normal(max_avg, max_sd);
  obs_speed ~ normal(mu, sigma);
  alpha ~ normal(3, 2);
  sigma ~ exponential(1);
}
