// simple predator-prey functional response for a binomial density
data {
  int<lower=0> N;
  array[N] int<lower=0> attacks;
  array[N] int<lower=0> densities;
}
parameters {
  real<lower=0,upper=1> a;
  real<lower=0> h;
}
transformed parameters{
  vector<lower=0, upper = 1>[N] prob_attack;
  prob_attack = a * inv(1 + a * h * to_vector(densities));
}
model {
  a ~ beta(2,6);
  h ~ lognormal(0, 1);
  attacks ~ binomial(densities, prob_attack);
}

