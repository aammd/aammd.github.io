data{
  int n;
  real time;
  // real N0;
  array[n] int abd;
}
parameters {
  real r;
  real<lower=0,upper=1> m;
}
model {
  m ~ beta(3,3);
  r ~ normal(1.8, .2);

  for (i in 1:n) {
    if (abd[i] == 0) {
      target += log_sum_exp(
        [
          2*log(m),
          log(2)+log(m)+log1m(m)
          + poisson_log_lpmf(abd[i] | r*time),
          2*log1m(m)
          + poisson_log_lpmf(abd[i] | log(2) + r*time)
        ]
        );
    } else {
      target += log_sum_exp(
        log(2)+log(m)+log1m(m)
        + poisson_log_lpmf(abd[i] | r*time),
        2*log1m(m)
        + poisson_log_lpmf(abd[i] | log(2) + r*time)
        );
    }
  }
}
