data{
  int<lower=0> n;
  vector[n] soil;
  vector[n] insects;
  vector[n] herbivory;
}
parameters{
  real avg_herb;
  vector[3] beta;
  real<lower=0> sigma;
}
model{
  sigma ~ exponential(.25);
  beta ~ std_normal();
  avg_herb ~ normal(30, 5);
  herbivory ~ normal(avg_herb + beta[1]* soil + beta[2]*insects + beta[3]*(soil .* insects), sigma);
}
