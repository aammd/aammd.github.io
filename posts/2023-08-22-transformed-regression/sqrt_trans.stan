data{
  int n;
  vector[n] x;
  vector[n] y;
}
transformed data{
  vector[n] ytrans = sqrt(y);
}
parameters{
  real slope;
  real intercept;
  real sigma;
}
model{
  ytrans ~ normal(intercept + slope*x, sigma);
}
generated quantities{
  vector[n] ybar = square(intercept + slope*x);
  vector[n] yrep;
  for(i in 1:n){
    yrep[i] = square(normal_rng(intercept + slope*x[i], sigma));
  }
}
