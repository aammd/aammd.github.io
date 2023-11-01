data {
  int n;
  vector[n] x;
}
transformed data {
  real M = max(x);
}
parameters {
 real<lower=0> b2;
 real<lower=0,upper=1> p;
 real<lower=0> sigma;
}
model {
  b2 ~ normal(1, .5);
  p ~ beta(7, 7);
  sigma ~ exponential(1);
}
generated quantities {
  vector[n] y;
  for( i in 1:n){
    if (x[i] < M*p) {
      y[i] = normal_rng(x[i]*b2, sigma);
    } else {
      y[i] = normal_rng(p*M*b2, sigma);
    }
  }
}
