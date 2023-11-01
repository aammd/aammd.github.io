
data {
  int<lower=0> N;
  matrix[N, 5] y;
}
parameters {
  row_vector[5] beta;
  real<lower=0> sigma;
  vector[N] alpha;
}
model {
  // take the outer product: alpha multiplied by each beta in turn
  matrix[N, 5] mu = alpha * beta;
  for (i in 1:N){
    y[i] ~ normal(mu[i], sigma);
  }
  beta ~ std_normal();
  sigma ~ exponential(1);
  alpha ~ std_normal();
}
