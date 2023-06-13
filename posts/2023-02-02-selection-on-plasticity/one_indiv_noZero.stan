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
  vector[nbirds] alpha = log_avgclutch + log_b_date * darrive;
  success ~ binomial_logit(clutch, logit_psuccess);
  logit_psuccess ~ normal(1, .2);
  log_avgclutch ~ normal(1, .2);
  log_b_date ~ normal(0, .2);
  clutch ~ poisson_log(alpha);
  // no zeros -- this normalizes the poisson density for a 0-truncated variable
  target += -log1m_exp(-exp(alpha));
}
