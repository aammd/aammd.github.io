data{
  int n;
  int nclone;
  real time;
  // real N0;
  array[n] int abd;
  array[n] int clone_id;
}
parameters {
  // real r_bar;
  real<lower=0,upper=1> m;
  // real<lower=0> r_sd;
  vector[nclone] r_i;
}
// transformed parameters {
//   vector[nclone] r_i = r_bar + r_z*r_sd;
// }
model {
  // priors
  // m ~ beta(4,4);
  // r_bar ~ normal(1.8, .2);
  // r_sd ~ exponential(3);
  // r_z ~ std_normal();
  r_i ~ normal(1.8, .3);

  for (i in 1:n) {
      target +=  poisson_log_lpmf(abd[i] | log(2) + r_i[clone_id[i]]*time);
    }
}
