data {
  int n;
  array[n] int<lower=1, upper=3> group_id;
}
transformed data {
  matrix[3, 3] contr = [
    [1, -0.707106781186548,     0.408248290463863],
    [1, -7.85046229341888e-17, -0.816496580927726],
    [1,  0.707106781186547,     0.408248290463863]
    ];
}
parameters {
  vector[n] obs;
  matrix[3, 2] betas;
}
transformed parameters {
  matrix[3, 2] m = contr * betas;
  vector[n] mu = m[group_id,1];
  vector[n] sigma = exp(m[group_id,2]);
}
model{
  to_vector(betas) ~ std_normal();
  obs ~ normal(mu, sigma);
}
generated quantities {
  vector[3] yrep;
  for (k in 1:3){
    yrep[k] = normal_rng(m[k,1], exp(m[k,2]));
  }
}
