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
  b2 ~ normal(1, 1);
  sigma ~ exponential(1);
}
generated quantities {
  vector[n] y;
  for( i in 1:n){
    if (x[i] < B) {
      y[i] = normal_rng(x[i]*b2, sigma);
    } else {
      y[i] = normal_rng(B*b2, sigma);
    }
  }
}
