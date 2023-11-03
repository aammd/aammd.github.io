data {
  int<lower=0> npred;
  vector[npred] new_soil;
  vector[npred] new_insect;
}
// copied from the previous model!
parameters{
  real avg_herb;
  vector[3] beta;
  real<lower=0> sigma;
}
generated quantities {
  vector[npred] pred_herbivory;
  for (i in 1:npred){
    pred_herbivory[i] = normal_rng(avg_herb + beta[1]* new_soil[i] + beta[2]*new_insect[i] + beta[3]*(new_soil[i] * new_insect[i]), sigma);
  }
}
