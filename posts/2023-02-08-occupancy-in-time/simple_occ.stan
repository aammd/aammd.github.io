data {
  int<lower=0> N;
  array[N] int<lower=0, upper=1> y;
  array[N] real<lower=0> sample_size;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real alpha;
  real beta;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  y ~ normal(mu, sigma);
}

