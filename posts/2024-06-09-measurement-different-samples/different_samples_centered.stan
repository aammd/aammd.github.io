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
transformed data{
  real obs_mass_mean = mean(obs_mass);
  vector[nobs_mass] obs_mass_c;
  obs_mass_c = obs_mass - obs_mass_mean;
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
  mass_c ~ std_normal();
  sigma_mass ~ exponential(.5);

  behaviour ~ poisson_log(intercept + slope*mass_c[behav_pop_id]);
  obs_mass ~ normal(mass_c[mass_pop_id], sigma_mass);
}
generated quantities{
  vector[nobs_mass] mass;
  mass = mass_c + obs_mass_mean
}
