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
  real logit_pfail;
}
model {
  logit_pfail ~ normal(-1, .5);
  logit_psuccess ~ normal(1, .2);
  log_avgclutch ~ normal(1, .2);
  log_b_date ~ normal(0, .2);

  // Eggs laid -- at least one
  vector[nbirds] alpha = log_avgclutch + log_b_date * darrive;
  clutch ~ poisson(exp(alpha)) T[1,];

  // nestling success
  for (n in 1:nbirds) {
    if (success[n] == 0) {
      target += log_sum_exp(
        log_inv_logit(logit_pfail),
        log1m_inv_logit(logit_pfail) + binomial_logit_lpmf(0 | clutch[n], logit_psuccess)
        );
    } else {
      target += log1m_inv_logit(logit_pfail) + binomial_logit_lpmf(success[n] | clutch[n], logit_psuccess);
    }
  }

}
