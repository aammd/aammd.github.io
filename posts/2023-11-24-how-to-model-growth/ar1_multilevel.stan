// modified from previous models with help from ChatGPT!
data {
  int n;
  int nclone;
  vector[n] time;
  vector[n] x;
  array[n] int<lower=1, upper=nclone> clone_id;
}
transformed data{
  vector[n] twotime = 2 * time;
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
  // note from jan 2024, does this z_params_raw need to go on the OTHER side of diag_pre_multiply
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

  x ~ normal(
    mu_max[clone_id] .* (1 - pow(b[clone_id], time)),
    sigma_max[clone_id] .* sqrt(1 - pow(b[clone_id], twotime))
  );
}

generated quantities {
  matrix[15, nclone] x_pred;
  x_pred[1,] = rep_row_vector(0, nclone);
  for (s in 1:nclone){
    for (j in 1:14) {
      x_pred[j+1,s] = normal_rng(
        mu_max[s] .* (1 - pow(b[s], j)),
        sigma_max[s] .* sqrt(1 - pow(b[s]^2, j))
      );
    }
  }
}
