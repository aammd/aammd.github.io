// HOF model with perfect detection
data {
  int<lower=0> n;
  // array[n] int<lower=0, upper=1> y;
  vector[n] jday;
  int<lower=0> nyear;
}
parameters {
  real s_avg;
  real<lower=0> s_sigma;
  real asym_avg;
  real<lower=0> asym_sigma;
  real d1;
  real d2;
}
model {
  s_avg ~ normal(-2, .5);
  s_sigma ~ exponential(2);
  asym_avg ~ normal(1, .2);
  asym_sigma ~ exponential(.5);
  d1 ~ normal(130, 7);
  d2 ~ normal(230, 7);
}
generated quantities {
  matrix[n, nyear] p;
  vector[nyear] s_total;
  vector[nyear] logit_asym;

  for (y in 1:nyear){
    s_total[y] = normal_rng(s_avg, s_sigma);
    logit_asym[y] = normal_rng(asym_avg, asym_sigma);
    for (j in 1:n){
      p[j,y] = exp(-(
        log1p_exp(
          -exp(s_total[y] +   log_inv_logit(logit_asym[y])) * (jday[j] - d1))
      + log1p_exp(
           exp(s_total[y] + log1m_inv_logit(logit_asym[y])) * (jday[j] - d2))
            ));
    }
  }
}
