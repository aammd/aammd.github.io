data {
  int n;
  int S;
  vector[n] pop;
  array[n] int<lower=1, upper=S> Sp;
  int<lower=0, upper=1> fit;
  // for predictions
  int nyear;
}
transformed data {
  vector[n] log_pop = log(pop);
  array[n - S] int time;
  array[n - S] int time_m1;
  for (i in 2:n) {
    if (Sp[i] == Sp[i-1]) {
      time[i - Sp[i]] = i;
      time_m1[i - Sp[i]] = i - 1;
    }
  }
}
parameters {
  vector[S] log_b0;
  vector[S] log_rho;
  real<lower=0> sigma;
}
model {
  log_b0 ~ normal(0, 0.1);
  log_rho ~ normal(0, 0.1);
  sigma ~ cauchy(0, 2);

  if (fit == 1) {
    log_pop[time] ~ normal(
      exp(log_b0[Sp[time]])
      + exp(log_rho[Sp[time]]) .* log_pop[time_m1],
      sigma);
  }
}
generated quantities {
  array[S] vector[nyear] pred_pop_avg;
  array[S,nyear] real pred_pop_obs;

  for (s in 1:S){
    pred_pop_avg[s][1] = 2.2;
  }

  for (s in 1:S){
    for (j in 2:nyear){
      pred_pop_avg[s][j] = exp(log_b0[s])
       + exp(log_rho[s]) .* pred_pop_avg[s][j-1];
    }
  }

  for (s in 1:S){
    pred_pop_obs[s,] = normal_rng(pred_pop_avg[s], sigma);
  }
}
