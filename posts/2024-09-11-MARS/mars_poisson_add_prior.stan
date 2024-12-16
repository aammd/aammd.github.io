// this version of the model also includes flexibility for various additions over time

data {
  // NOTES on some of the data validation:
  // sometimes I set max = n_time; this is because I think its safe to assume
  // that in many of these models there are more observation timepoints than species.
  int<lower=1> S;
  // number of timepoints NOT including the first week of setup
  // time = 1 is the first week of observations
  int<lower=2> n_time;

  // number of additions -- every species is added at least once!
  int<lower=S> n_add;
  vector[n_add] added;
  array[n_add, 2] int<lower=1,upper=max([S, n_time])> add_idx;
  // array[n_add] int<lower=1,upper=S> sp_add;
  // array[n_add] int<lower=1,upper=n_time> when_add

  // Absences
  // how many times do we KNOW that a species is at 0 abundance?
  int<lower=0> n_abs;
  array[n_abs, 2] int<lower=1,upper=max([S,n_time])> abs_idx;

  // Observations of species abundances
  int<lower=S> n_obs; // every species is observed at least once!
  array[n_obs] int<lower=0> abd;
  array[n_obs, 2] int<lower=1,upper=n_time> abd_idx;
}
transformed data{
  matrix[S,n_time] additions = rep_matrix(0, S, n_time);

  additions[add_idx] = added;
}
parameters {
  vector[S*(S-1)] offdiag_B;
  vector<lower=0,upper=1>[S] diag_B;
  vector[S] A;
  matrix[S, n_time] error;
  real<lower=0> sigma_error;
}
transformed parameters {
  // make the B matrix
  matrix[S, S] B;

  for (s in 1:S){
    B[s, s] = diag_B[s];
  }

  {
    int idx; // index for going into the off-diag vector
    idx = 1;

    // Fill the upper diagonal
    for (i in 1:(S-1)) {
      for (j in (i+1):S) {
        B[i, j] = offdiag_B[idx];
        idx += 1;
      }
    }

    // Fill the lower diagonal
    for (i in 2:S) {
      for (j in 1:(i-1)) {
        B[i, j] = offdiag_B[idx];
        idx += 1;
      }
    }
  }

  // make the true abds
  matrix[S, n_time] true_abd;
  true_abd[,1] = A + B * starting + error[,1];
  for (t in 2:n_time){
    true_abd[,t] = A + B * true_abd[,t-1] + error[,t];
  }
}
model {

  offdiag_B ~ normal(0, .05);
  diag_B ~ beta(.3*6, (1-.3)*6);
  A ~ normal(.2, .2);
  to_vector(error) ~ normal(0, sigma_error);
  sigma_error ~ exponential(10);

  // likelihood
  // abds ~ poisson_log(to_vector(true_abd));
}
generated quantities{
  array[n_time, S] int sim_abds;

  for (i in 1:n_time){
    sim_abds[i,] = poisson_log_rng(true_abd[,i]);
  }
}
