data{
  int n;
  real time;
  real N0;
  array[n] int abd;
}
parameters {
  real r;
  real<lower=0> sigma;
  vector[n] obs_z;
}
transformed parameters {
  vector[n] obs_i = obs_z*sigma;
}
model {
  obs_z ~ std_normal();
  sigma ~ exponential(3);
  r ~ normal(1.7, .2);
  abd ~ poisson_log(log(N0) + r*time + obs_i);
}
