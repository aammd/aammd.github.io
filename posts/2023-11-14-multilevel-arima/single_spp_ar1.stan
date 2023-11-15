data {
  int n;
  vector[n] pop;
  int<lower=0,upper=1> fit;
  // array[n] int<lower=1> y_id;
  // for predictions
  int nyear;
}
transformed data {
  vector[n] log_pop = log(pop);
}
parameters {
  real log_b0;
  real log_rho;
  real<lower=0> sigma;
}
model {
  log_b0 ~ normal(0, 0.1);
  log_rho ~ normal(0, 0.1);
  sigma ~ exponential(1);
  // likelihood
  if (fit == 1){
    log_pop[2:n] ~ normal(
      exp(log_b0) + exp(log_rho) * log_pop[1:(n-1)],
      sigma);
  }
}
generated quantities {
  vector[nyear] pred_pop_avg;
  array[nyear] real pred_pop_obs;

  pred_pop_avg[1] = 2.2;

  for (j in 2:nyear) {
    pred_pop_avg[j] = exp(log_b0) + exp(log_rho) * pred_pop_avg[j-1];

  }

  pred_pop_obs = normal_rng(pred_pop_avg, sigma);

}


