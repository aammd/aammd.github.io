functions {
  real poisson_mix_mortality(int abd_i, real mu, real m) {
    real ll;
    if (abd_i == 0) {
      ll = log_sum_exp(
        [
          2 * log(m),
          log(2) + log(m) + log1m(m) + poisson_log_lpmf(abd_i | mu),
          2 * log1m(m) + poisson_log_lpmf(abd_i | log(2) + mu)
        ]
      );
    } else {
      ll = log_sum_exp(
        log(2) + log(m) + log1m(m) + poisson_log_lpmf(abd_i | mu),
        2 * log1m(m) + poisson_log_lpmf(abd_i | log(2) + mu)
      );
    }
    return ll;
  }
}
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
  real mu = r*time;
  for (i in 1:n) {
    target += poisson_mix_mortality(abd[i], mu, m);
  }
}
