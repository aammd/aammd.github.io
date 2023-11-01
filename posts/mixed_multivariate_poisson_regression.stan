data {
  // num of sites in the dataset
  int<lower=0> Nsites;
  // num of site predictors
  int<lower=1> K;
  // num of species
  int<lower=1> S;
  // number of ID
  int<lower=0> ID;
  // ID vector
  vector[Nsites] r;
  // site-level predictors
  matrix[Nsites,K] X;
  // species response
  array[Nsites,S] int Y;
}
parameters {
  // Intercept
  vector<lower=0>[S] alpha;
  // Slope
  matrix[K,S] beta;
  // Random effect ID
  matrix[ID,S] rho;
}
model {
  // Likelihood
  for (s in 1:S) {
    Y[,s] ~ poisson(X * beta[,s] + alpha[s] + rho[ID,S]);
  }
}
