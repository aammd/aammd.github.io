data{
  int nbirds;
  vector[nbirds] darrive;
  array[nbirds] int clutch;
  array[nbirds] int success;
}
parameters {
  real logit_psuccess;
  real log_avgclutch;
  real log_b_date;
}
model {
  success ~ binomial_logit(clutch, logit_psuccess);
  clutch ~ poisson_log(log_avgclutch + log_b_date * darrive);
  logit_psuccess ~ normal(1, .2);
  log_avgclutch ~ normal(1, .2);
  log_b_date ~ normal(0, .2);
}
