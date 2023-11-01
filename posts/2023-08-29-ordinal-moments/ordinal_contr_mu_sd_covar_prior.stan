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
  // matrix[3,2] betas;
  vector[2] contrast_avgs;
  vector<lower=0>[2] tau;
  corr_matrix[2] Omega;        // prior correlation
}
transformed parameters {
  vector[3] m = contr * betas[,1];
  vector[3] s = exp(contr * betas[,2]);
  vector[n] mu = m[group_id];
  vector[n] sigma = s[group_id];
}
model{
  tau ~ exponential(1);
  Omega ~ lkj_corr(2);
  contrast_avgs ~ std_normal();
  {
    array[3] row_vector[2] contrast_avgs
  }
  betas ~ multi_normal(contrast_avgs, quad_form_diag(Omega, tau));
  obs ~ normal(mu, sigma);
}
generated quantities {
  vector[3] yrep;
  for (k in 1:3){
    yrep[k] = normal_rng(m[k], s[k]);
  }
}
