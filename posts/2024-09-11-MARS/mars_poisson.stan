data {
  int<lower=1> S;
  // number of timepoints NOT including the first week of setup
  int<lower=2> n_time;
  array[S*n_time] int<lower=0> abds;
  vector[S] starting;
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
  abds ~ poisson_log(to_vector(true_abd));
}
generated quantities{
  array[n_time, S] int sim_abds;

  for (i in 1:n_time){
    sim_abds[i,] = poisson_log_rng(true_abd[,i]);
  }
}
