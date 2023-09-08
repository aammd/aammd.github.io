data {
  int n;
  vector[n] x;
  real B;
}
parameters {
 vector<lower=0>[n] y;
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
  vector[n] beta = mu/square(sigma);
  y ~ gamma(mu .* beta, beta);
  sigma ~ exponential(1);
}
