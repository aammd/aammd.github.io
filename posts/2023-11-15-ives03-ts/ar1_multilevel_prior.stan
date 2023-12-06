// modified from previous models with help from ChatGPT!
data {
  int nclone;
  int nrep;
}

parameters {
  vector[nclone] mu_log_a;
  vector[nclone] mu_logit_b;
  vector[nclone] mu_log_sigma;

  cholesky_factor_corr[3] L_corr;  // Cholesky factorization of the correlation matrix
  vector<lower=0>[3] sigma_params;  // Standard deviations for log_a, logit_b, log_sigma

  matrix[nclone, 3] z_params_raw;  // Unconstrained parameters
}

transformed parameters {
  matrix[nclone, 3] z_params = z_params_raw * diag_pre_multiply(sigma_params, L_corr);

  vector[nclone] log_a = mu_log_a + z_params[,1];
  vector[nclone] logit_b = mu_logit_b + z_params[,2];
  vector[nclone] log_sigma = mu_log_sigma + z_params[,3];

  vector[nclone] b = inv_logit(logit_b);
  vector[nclone] mu_max = exp(log_a - log1m_inv_logit(b));
  vector[nclone] sigma_max = exp(log_sigma) ./ sqrt(1 - square(b));
}

model {
  mu_log_a ~ normal(0.7, 0.2);
  mu_logit_b ~ normal(1.7, 0.2);
  mu_log_sigma ~ normal(-.7, 0.25);

  L_corr ~ lkj_corr_cholesky(4);  // Prior on the Cholesky factor for the correlation matrix

  sigma_params[1] ~ exponential(4);
  sigma_params[2] ~ exponential(4);
  sigma_params[3] ~ exponential(3.5);

  to_vector(z_params_raw) ~ std_normal();
}

generated quantities {
  array[nclone, nrep, 15] real x_pred;
  for (s in 1:nclone){
    for (r in 1:nrep){
      x_pred[s, r, 1] = 0;
    }
  }
  for (s in 1:nclone){
    for (r in 1:nrep){
      for (j in 1:14) {
        x_pred[s, r, j+1] = normal_rng(
          mu_max[s] .* (1 - pow(b[s], j)),
          sigma_max[s] .* sqrt(1 - pow(b[s]^2, j))
          );
      }
    }
  }
}