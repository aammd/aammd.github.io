data {
  int n;
  vector[n] x;
  vector[n] y;
}
parameters {
  real B;
  real<lower=0> sigma;
}
transformed parameters {
  vector[n] x2;
  for (i in 1:n){
    x2[i] = step(B - x[i]);
  }
}
model {
  vector[n] mu;
  mu = B + (x - B) .* x2;
  y ~ normal(mu, sigma);
  sigma ~ exponential(1);
}
