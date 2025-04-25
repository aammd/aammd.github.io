data{
  int n;
  real time;
  vector[n] N0;
  array[n] int abd;
}
parameters {
  real<lower=0> r;
}
model {
  abd ~ poisson_log(log(N0) + r*time);
}
