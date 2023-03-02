
data {
  int<lower=0> N;                     // replicates
  int<lower=0> R;                     // number of prey
  array[N, R] int<lower=0> attacks;
  array[N, R] int<lower=0> densities;
}
transformed data{
  array[N, R] real<lower=0> realdens;
  for(n in 1:N){
    for(r in 1:R){
      realdens[n, r] = densities[n, r]*1.0;
    }
  }
}
parameters {
  array[R] real<lower=0,upper=1> a; // attack rate for each prey
  real<lower=0> h; // a constant handling time
}
transformed parameters{
  array[N, R] real<lower=0, upper=1> prob_attack;
  for (n in 1:N) {
    real denom;
    denom = 1 + h * dot_product(a , realdens[n]);
    for (r in 1:R) {
      prob_attack[n, r] = a[r] / denom;
    }
  }
}
model {
  a ~ beta(2,6); // works on all elements at the same time!
  h ~ lognormal(0, 1);
  for (n in 1:N){
      attacks[n] ~ binomial(densities[n], prob_attack[n]);
  }
}
