data {
  int<lower=0> n;
  int<lower=0> s;
  vector[n] x;
  vector[n] y;
  matrix[s, s] phyvcv;
}
transformed data {
  vector[n] zero_vec = rep_vector(0, n);
}
parameters {
  real b0;
  real<offset=0.5, multiplier=0.5> b1;
  real sigma_x;
  real sigma_y;
  real<offset=3, multiplier=0.2> logit_lambda_x;
  real<multiplier=0.2> logit_lambda_y;
}
transformed parameters {
  real<lower=0, upper=1> lambda_x = inv_logit(logit_lambda_x);
  real<lower=0, upper=1> lambda_y = inv_logit(logit_lambda_y);
}
model {
  matrix[s, s] vcv_x
    = sigma_x^2 * add_diag(lambda_x * phyvcv, 1 - lambda_x);
  matrix[s, s] vcv_y
    = sigma_y^2 * add_diag(lambda_y * phyvcv, 1 - lambda_y);

  b0 ~ std_normal();
  b1 ~ std_normal();
  sigma_x ~ exponential(1);
  sigma_y ~ exponential(1);
  logit_lambda_x ~ std_normal();
  logit_lambda_y ~ std_normal();
  x ~ multi_normal(zero_vec, vcv_x);
  y ~ multi_normal(b0 + b1 * x, vcv_y);
}
