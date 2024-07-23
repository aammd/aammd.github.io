data {
  int<lower=1> nobs_behav;
  int<lower=1> nobs_mass;
  int<lower=1> npop;
  // behaviour dataset
  array[nobs_behav] int behaviour;
  array[nobs_behav] int<lower=1,upper=npop> behav_pop_id;
  // mass dataset
  vector[nobs_mass] obs_mass;
  array[nobs_mass] int<lower=1,upper=npop> mass_pop_id;
}
parameters {
  real intercept;
  real slope;
  vector[npop] mass;
  real<lower=0> sigma_mass;
}
model {
  intercept ~ normal(1.3, .2);
  slope ~ normal(.5, .2);
  mass ~ std_normal();
  sigma_mass ~ exponential(.5);

  behaviour ~ poisson_log(intercept + slope*mass[behav_pop_id]);
  obs_mass ~ normal(mass[mass_pop_id], sigma_mass);
}
