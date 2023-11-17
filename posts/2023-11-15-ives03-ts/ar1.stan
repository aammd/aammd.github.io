data{
  int n;
  vector[n] time;
  vector[n] x;
}
// transformed data {
//   vector[n] x = log(pop);
// }
parameters {
  real a;
  real<lower=0,upper=1> b;
  real<lower=0> sigma;
}
transformed parameters {
  real mu_max = a / (1 - b);
  real sigma_max = sigma /sqrt(1 - b^2);
}
model {
  a ~ normal(2, .5);
  b ~ beta(5,2);
  sigma ~ exponential(5);
  x ~ normal(
    mu_max .* (1 - pow(b, time)),
    sigma_max .* sqrt(1 - pow(b^2, time))
    );
}
generated quantities {
  vector[15] x_pred;
  x_pred[1] = 0;
  for (j in 1:14) {
    x_pred[j+1] = normal_rng(
      mu_max * (1 - pow(b, j)),
      sigma_max * sqrt(1 - pow(b^2, j))
      );
  }
}
