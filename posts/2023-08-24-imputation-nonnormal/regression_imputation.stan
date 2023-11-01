data {
  int<lower=0> N_tot;          // Total number of observations
  int<lower=0> N_miss;        // Number of missing values
  int<lower=0> N_obs;        // Number of observed values
  array[N_obs] int<lower=1, upper=N_tot> ii_obs;  // Position of observed values in the column
  array [N_miss] int<lower=1, upper=N_tot> ii_mis; // Position of the missing values in the column
  vector[N_obs] x_obs;            // Observed values
  vector[N_tot] y;
}


parameters {
  real x_mu;              // Population mean
  real<lower=0> x_sigma;     // Common standard deviation
  vector[N_miss] x_imputed;       // Imputed values for missing data
  real slope;
  real intercept;
  real<lower=0> y_sigma;
}

transformed parameters {
  vector[N_tot] x;      // create the dataset to fit the likelihood
  x[ii_obs] = x_obs;        // assign observations to the positions with observations
  x[ii_mis] = x_imputed;    // assign parameters (y missing) to the positions without observations
}

model {
  // Priors
  x_mu ~ normal(50, 10);
  x_sigma ~ exponential(.1);
  intercept ~ normal(10, 4);
  slope ~ std_normal();
  y_sigma ~ exponential(.1);

  // Likelihood for observed and imputated data (x)
  x ~ normal(x_mu, x_sigma);
  // LIkelihood for the response variable
  // y ~ normal(intercept + slope * (x - 50), y_sigma);
  y ~ normal(intercept + slope * (x - x_mu), y_sigma);
}

generated quantities {
  vector[N_tot] x_pred;

  for (i in 1:N_tot) {
    x_pred[i] = normal_rng(x_mu, x_sigma);
  }
}
