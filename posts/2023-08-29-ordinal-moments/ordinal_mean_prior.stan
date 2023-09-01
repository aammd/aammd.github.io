data {
  int n_each;
}
transformed data {
  int n_observations = n_each * 3;
  matrix[3, 3] contr = [
    [1, -0.707106781186548, 0.408248290463863],
    [1, -7.85046229341888e-17, -0.816496580927726],
    [1, 0.707106781186547, 0.408248290463863]
    ];
}
parameters {
  vector[3] betas;
  real<lower=0> sigma;
  vector[n_observations] obs;
}
transformed parameters {
  vector[3] m = contr * betas;
  vector[n_observations] mu;
  for (i in 1:n_each){
    mu[i] = m[1];
    mu[i + n_each] = m[2];
    mu[i + 2*n_each] = m[3];
  }
}
model{
  betas ~ std_normal();
  sigma ~ exponential(1);
  obs ~ normal(mu, sigma);
}
