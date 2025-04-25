data{
  int n;
  int nclone;
  real time;
  // real N0;
  array[n] int abd;
  array[n] int clone_id;
}
parameters {
  real r_bar;
  real<lower=0,upper=1> m;
  real<lower=0> r_sd;
  vector[nclone] r_z;
}
transformed parameters {
  vector[nclone] r_i = r_bar + r_z*r_sd;
}
model {
  // priors
  m ~ beta(4,4);
  r_bar ~ normal(1.8, .2);
  r_sd ~ exponential(3);
  r_z ~ std_normal();

  for (i in 1:n) {
    if (abd[i] == 0) {
      target += log_sum_exp(
        [
          2*log(m),
          log(2)+log(m)+log1m(m)
          + poisson_log_lpmf(abd[i] | r_i[clone_id[i]]*time),
          2*log1m(m)
          + poisson_log_lpmf(abd[i] | log(2) + r_i[clone_id[i]]*time)
        ]
        );
    } else {
      target += log_sum_exp(
        log(2)+log(m)+log1m(m)
        + poisson_log_lpmf(abd[i] | r_i[clone_id[i]]*time),
        2*log1m(m)
        + poisson_log_lpmf(abd[i] | log(2) + r_i[clone_id[i]]*time)
        );
    }
  }
}
