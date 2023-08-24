data {
  int<lower=0> N_tot;          // Total number of observations
  int<lower=0> N_miss;        // Number of missing values
  int<lower=0> N_obs;        // Number of observed values
  array[N_obs] int<lower=1, upper=N_tot> ii_obs;  // Position of observed values in the column
  array [N_miss] int<lower=1, upper=N_tot> ii_mis; // Position of the missing values in the column
  vector[N_obs] y_obs;            // Observed values
  //int<lower=0> N_year;     // Number of years in the dataset
}


parameters {
  real mu;              // Population mean
  real<lower=0> sigma;     // Common standard deviation
  vector[N_miss] y_imputed;       // Imputed outcomes for missing data
}

transformed parameters {
  vector[N_tot] y;      // create the dataset to fit the likelihood
  y[ii_obs] = y_obs;        // assign observations to the positions with observations
  y[ii_mis] = y_imputed;    // assign parameters (y missing) to the positions without observations
}

model {
  // Priors
  mu ~ normal(0, 10);
  sigma ~ exponential(1);

  // Likelihood for observed and imputated data
  y ~ normal(mu, sigma);
}

generated quantities {
  vector[N_tot] y_pred;

  for (i in 1:N_tot) {
    y_pred[i] = normal_rng(mu, sigma);
  }
}
