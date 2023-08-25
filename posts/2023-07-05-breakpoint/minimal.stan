data {
  int n;
  vector[n] x;
  real B;
}
// transformed data {
//   real M = max(x);
// }
parameters {
 real b2;
 real<lower=0> sigma;
}
model {
  vector[n] y;
  vector[n] mu = x*b2;
  b2 ~ normal(1, 1);
  sigma ~ exponential(.2);
  y ~ normal(mu, sigma);
}

