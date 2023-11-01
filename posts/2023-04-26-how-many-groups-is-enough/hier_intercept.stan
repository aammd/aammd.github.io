data {
  int N;
  int Ngroup;
  vector[N] measurements;
  array[N] int<lower=0,upper=Ngroup> group_id;
}
parameters {
  real<lower=0> sigma_group;
  real<lower=0> sigma_obs;
  real grand_mean;
  vector[Ngroup] z;
}
transformed parameters {
  vector[Ngroup] mean_group;
  mean_group = grand_mean + z*sigma_group;
}
model {
  measurements ~ normal(mean_group[group_id], sigma_obs);
  z ~ std_normal();
  sigma_obs ~ exponential(1);
  sigma_group ~ exponential(10);
}
