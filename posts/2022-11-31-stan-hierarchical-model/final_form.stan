data {
  int<lower=0> N;              // num individuals
  int<lower=1> K;              // num ind predictors
  int<lower=1> J;              // num groups
  int<lower=1> L;              // num group predictors
  array[N] int<lower=1, upper=J> jj;  // group for individual
  matrix[N, K] x;              // individual predictors
  matrix[L, J] u;              // group predictors transposed
  vector[N] y;                 // outcomes
}
parameters {
  matrix[K, J] z;
  cholesky_factor_corr[K] L_Omega;
  vector<lower=0, upper=pi() / 2>[K] tau_unif;  // prior scale
  matrix[K, L] gamma;                        // group coeffs
  real<lower=0> sigma;                       // prediction error scale
}
transformed parameters {
  vector<lower=0>[K] tau = 2.5 * tan(tau_unif);
  matrix[K, J] beta = gamma * u + diag_pre_multiply(tau, L_Omega) * z;
}
model {
  vector[N] mu;
  for(n in 1:N) {
    mu[n] = x[n, ] * beta[, jj[n]];
  }
  to_vector(z) ~ std_normal();
  L_Omega ~ lkj_corr_cholesky(2);
  to_vector(gamma) ~ normal(0, 5);
  y ~ normal(mu, sigma);
}
