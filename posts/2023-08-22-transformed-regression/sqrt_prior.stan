data{
  int n;
  vector[n] x;
}
parameters{
  real slope;
  real intercept;
  real<lower=0> sigma;
}
model {
  slope ~ std_normal();
  intercept ~ std_normal();
  sigma ~ exponential(1);
}
generated quantities {
  vector[n] yrep;
  for (i in 1:n){
    yrep[i] = square(normal_rng(slope * x[i] + intercept, sigma));
  }
}
