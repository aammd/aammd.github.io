
data {
  int<lower=0> N;                     // replicates
  int<lower=0> R;                     // number of prey
  array[N, R] int<lower=0> attacks;
  array[N, R] int<lower=0> densities;
}
parameters {
  vector<lower=0,upper=1>[R] a; // attack rate for each prey
  real<lower=0> h; // a constant handling time
}
model {

  matrix[N, R] prob_attack;
  vector[N] denom;

  // make a vector for denom
  denom = 1 / (1 * (to_matrix(densities) * a))

  prob_attack = denom * to_row_vector(a);

  a ~ beta(2,6); // works on all elements at the same time!
  h ~ lognormal(0, 1);
  for (n in 1:N){
    attacks[n] ~ binomial(densities[n], prob_attack[n]);
  }
}
generated quantities {

}
