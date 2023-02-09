data {
  int<lower=0> N;
  array[N] int<lower=0, upper=1> y;
  vector[N] sample_size;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real<lower=0, upper=1> p;
  real<lower=0, upper=1> d;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  p ~ beta(2, 4);
  d ~ beta(3, 3);
  y ~ bernoulli((1 - (1 - d)^sample_size)*p);
}

