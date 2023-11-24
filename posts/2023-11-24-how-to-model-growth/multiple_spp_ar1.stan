data {
  int n;
  int nclone;
  vector[n] x;
  array[n] int<lower=1, upper=nclone> clone_id;
  // for predictions
  int<lower=0, upper=1> fit;
  int nyear;
}
transformed data {
  array[n - nclone] int time;
  array[n - nclone] int time_m1;
  for (i in 2:n) {
    if (clone_id[i] == clone_id[i-1]) {
      time[i - clone_id[i]] = i;
      time_m1[i - clone_id[i]] = i - 1;
    }
  }
}
parameters {
  real<lower=0> a;
  real<lower=0,upper=1> b;
  real<lower=0> sigma;
}
model {

  a ~ normal(2, .5);
  b ~ beta(5,2);
  sigma ~ exponential(5);

  if (fit == 1) {

    x[time] ~ normal(
      a + b * x[time_m1],
      sigma);
  }
}
generated quantities {
  vector[nyear] x_pred;

  x_pred[1] = 0;

  for (j in 2:nyear){
    x_pred[j] =  a + b * x_pred[j-1] + normal_rng(0, sigma);
  }
}
