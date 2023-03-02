
data {
  int<lower=0> N;                     // replicates
  int<lower=0> R;                     // number of prey
  int<lower=0> F;                     // number of posterior reps
  array[N, R] int<lower=0> attacks;
  array[N, R] int<lower=0> densities;
  array[F, R] int<lower=0> for_predict;
}
parameters {
  vector<lower=0,upper=1>[R] a; // attack rate for each prey
  real<lower=0> h; // a constant handling time
}
model {

  array[N] vector[R] prob_attack;
  for (n in 1:N) {
    real denom;
    denom = 1 + h * dot_product(a , to_vector(densities[n]));
    prob_attack[n] = a * inv(denom); // vector of length R
  }


  a ~ beta(2,6); // works on all elements at the same time!
  h ~ lognormal(0, 1);
  for (n in 1:N){
    attacks[n] ~ binomial(densities[n], prob_attack[n]);
  }
}
generated quantities {

}
