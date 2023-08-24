data{
  int n;
  vector[n] x;
  vector[n] y;
}
transformed data{
  vector[n] ylog = log(y);
}
parameters{
  real slope;
  real intercept;
  real sigma;
}
model{
  ylog ~ normal(intercept + slope*x, sigma);
}
generated quantities{
  vector[n] ybar = exp(intercept + slope*x);
  vector[n] yrep;
  for(i in 1:n){
    yrep[i] = exp(normal_rng(intercept + slope*x[i], sigma));
  }
}
