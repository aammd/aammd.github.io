data{
  int n;
  real time;
  real N0;
  array[n] int abd;
}
parameters {
  real r;
}
model {
  r ~ normal(1.5, 2);
  abd ~ poisson_log(log(N0) + r*time);

}
