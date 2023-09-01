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
  vector[3] mu_beta;
  vector[3] sigma_beta;
}
transformed parameters {
  vector[3] m = contr * mu_beta;
  vector[3] s = exp(contr * sigma_beta);
  vector[n] mu = m[group_id];
  vector[n] sigma = s[group_id];
}
model{
  mu_beta ~ std_normal();
  sigma_beta ~ std_normal();
  obs ~ normal(mu, sigma);
}
generated quantities {
  vector[3] yrep;
  for (k in 1:3){
    yrep[k] = normal_rng(m[k], s[k]);
  }
}
