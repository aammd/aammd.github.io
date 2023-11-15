data {
  int n;
  int S;
  int Y;
  vector[n] pop;
  array[n] int<lower=1, upper=S> Sp;
  array[n] int<lower=1, upper=Y> Yr;
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
  vector<lower=0>[S] sigma;
  real mu_rho;
  real<lower=0> sigma_rho;
  real<lower=0> sigma_rho_yr;
  vector[S] z_rho;
  row_vector[S] z_rho_yr;
}
model {
  log_b0 ~ normal(0, 0.1);
  z_rho ~ std_normal();
  mu_rho ~ normal(0, 0.2);
  sigma_rho ~ exponential(2);
  sigma ~ cauchy(0, 2);
  z_rho_yr ~ std_normal();
  sigma_rho_yr ~ cauchy(0, 3);

  matrix[S,Y] log_rho = mu_rho
  .+ rep_vector(z_rho * sigma_rho, Y)
  .+ rep_row_vector(z_rho_yr*sigma_rho_yr, S);

  if (fit == 1) {
    log_pop[time] ~ normal(
      exp(log_b0[Sp[time]])
      + exp(log_rho[Yr[time][Sp[time]]) .* log_pop[time_m1],
      sigma[Sp[time]]);
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
    pred_pop_obs[s,] = normal_rng(
      pred_pop_avg[s],
      sigma[s]);
  }
}
