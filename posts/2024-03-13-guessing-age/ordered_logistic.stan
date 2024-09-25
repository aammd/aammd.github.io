data {
  int<lower=2> n_cat;
  int<lower=0> N;
  int<lower=1> n_x;
  array[N] row_vector[n_x] x;
}
parameters {
  vector[n_x] beta;
  ordered[n_cat - 1] cutpoints;
}
model {
  beta ~ normal(0, .3);
  cutpoints ~ normal(0, 1);
}
generated quantities {
  array[N] int<lower=1, upper=n_cat> y;

  for (n in 1:N) {
    y[n] = ordered_logistic_rng(x[n] * beta, cutpoints);
  }

}
