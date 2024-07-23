data {
  int<lower=1> nobs;
  int<lower=1> npop;
  array[nobs] int behaviour;
  array[nobs] int<lower=1,upper=npop> pop_id;
  vector[npop] mass;
}
parameters {
  real intercept;
  real slope;
}
model {
  intercept ~ normal(1.3, .2);
  slope ~ normal(.5, .2);
  behaviour ~ poisson_log(intercept + slope*mass[pop_id]);
}
