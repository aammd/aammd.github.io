// HOF model with perfect detection
data {
  int<lower=0> n;
  // array[n] int<lower=0, upper=1> y;
  vector[n] jday;
}
parameters {
  real s1;
  real s2;
  real d1;
  real d2;
}
model {
  s1 ~ normal(-2,   .5);
  s2 ~ normal(-2.5, .5);
  d1 ~ normal(130, 7);
  d2 ~ normal(230, 7);
}
generated quantities {
  vector[n] p =
  -(log1p_exp(-exp(s1) * (jday - d1)) + log1p_exp( exp(s2) * (jday - d2)));
}
