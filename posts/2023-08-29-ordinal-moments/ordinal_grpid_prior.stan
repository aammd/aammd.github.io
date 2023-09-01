data {
  int n;
  array[n] int<lower=1, upper=3> group_id;
}
transformed data {
  matrix[3, 3] contr = [
    [1, -0.707106781186548, 0.408248290463863],
    [1, -7.85046229341888e-17, -0.816496580927726],
    [1, 0.707106781186547, 0.408248290463863]
    ];
}
parameters {
  vector[3] betas;
  real<lower=0> sigma;
  vector[n] obs;
}
transformed parameters {
  vector[3] m = contr * betas;
  vector[n] mu = m[group_id];
}
model{
  betas ~ std_normal();
  sigma ~ exponential(1);
  obs ~ normal(mu, sigma);
}
