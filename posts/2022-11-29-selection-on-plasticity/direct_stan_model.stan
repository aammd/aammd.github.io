//
// stan program to model selection on plasticity
data{
  int<lower=0> N; // number of observations
  int<lower=0> n_env; // number of environmental variables
  int<lower=0> n_f; // number of females
  int<lower=0> n_f_characters; // number of female characters measured: mass, age
  array[N] int<lower=1, upper=n_f> f_id; // female id
  matrix[N, n_env] x_env; // environmental predictors
  matrix[N, n_f_characters] x_f;
  vector[N] dponte;
  array[N] int<lower=0> csize;
  array[N] int<lower=0> fledglings;
}
parameters {
  matrix[n_f, n_env] z;
  cholesky_factor_corr[n_f] L_Omega;
  vector<lower=0, upper=pi() / 2>[K] tau_unif;  // prior scale
  matrix[n_f, L] gamma;                        // group coeffs
  real<lower=0> sigma;                       // prediction error scale
}
transformed parameters {
  vector<lower=0>[n_f] tau = 2.5 * tan(tau_unif);
  matrix[K, J] beta = gamma * u + diag_pre_multiply(tau, L_Omega) * z;
  matrix[]
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
