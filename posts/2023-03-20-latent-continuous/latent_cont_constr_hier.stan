
data {
  int<lower=0> N;
  matrix[N, 5] y;
}
parameters {
  row_vector[5] beta;
  real<lower=0> sigma;
  vector[N] alpha;
  real<lower=0> s_alpha;
}
transformed parameters {
  row_vector[5] betatrans;
  betatrans[1] = exp(beta[1]);
  betatrans[2] = -exp(beta[2]);
  betatrans[3] = exp(beta[3]);
  betatrans[4] = exp(beta[4]);
  betatrans[5] = -exp(beta[5]);
}
model {
  // take the outer product: alpha multiplied by each beta in turn
  matrix[N, 5] mu = alpha * betatrans;
  for (i in 1:N){
    y[i] ~ normal(mu[i], sigma);
  }
  beta ~ std_normal();
  sigma ~ exponential(1);
  alpha ~ normal(0, s_alpha);
  s_alpha ~ exponential(.1);
}
