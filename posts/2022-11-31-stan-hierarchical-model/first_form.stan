data {
  int<lower=0> N;              // num individuals
  int<lower=1> K;              // num ind predictors
  int<lower=1> J;              // num groups
  int<lower=1> L;              // num group predictors
  array[N] int<lower=1, upper=J> jj;  // group for individual
  matrix[N, K] x;              // individual predictors
  array[J] row_vector[L] u;    // group predictors
  vector[N] y;                 // outcomes
}
parameters {
  corr_matrix[K] Omega;        // prior correlation
  vector<lower=0>[K] tau;      // prior scale
  matrix[L, K] gamma;          // group coeffs
  array[J] vector[K] beta;     // indiv coeffs by group
  real<lower=0> sigma;         // prediction error scale
}
model {
  tau ~ cauchy(0, 2.5);
  Omega ~ lkj_corr(2);
  to_vector(gamma) ~ normal(0, 5);
  {
    array[J] row_vector[K] u_gamma;
    for (j in 1:J) {
      u_gamma[j] = u[j] * gamma;
    }
    beta ~ multi_normal(u_gamma, quad_form_diag(Omega, tau));
  }
  for (n in 1:N) {
    y[n] ~ normal(x[n] * beta[jj[n]], sigma);
  }
}
