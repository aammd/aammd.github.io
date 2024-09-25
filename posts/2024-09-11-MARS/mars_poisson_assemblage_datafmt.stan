data {
  int<lower=1> S;
  // how many assemblages and their data
  int<lower=1> n_assemblage;
  array[n_assemblage] int<lower=1> S_each;
  array[n_assemblage] int<lower=1> n_time_each;
  array[n_assemblage] int<lower=1,upper=S> n_shared;
  array[n_assemblage] int<lower=1,upper=S> n_introd;
  array[to_int(dot_product(to_vector(S_each), to_vector(n_time_each)))] int obs;
  // starting density for each species (assumption is that it is the same across the whole experiment for a species)
  vector[S] starting;
  // which species is introduced when? assumption here is that species are introduced only once.
  array[sum(n_introd)] int<lower=1,upper=S> introd_seq;
  array[sum(n_shared)] int<lower=1,upper=S> shared_grp;
}
parameters {
  vector[S*(S-1)] offdiag_B;
  vector<lower=0,upper=1>[S] diag_B;
  vector[S] A;
  vector[to_int(dot_product(to_vector(S_each), to_vector(n_time_each)))] error;
  real<lower=0> sigma_error;
}
transformed parameters {
//   // make the B matrix
//   matrix[S, S] B;
//
//   for (s in 1:S){
//     B[s, s] = diag_B[s];
//   }
//
//   {
//     int idx; // index for going into the off-diag vector
//     idx = 1;
//
//     // Fill the upper diagonal
//     for (i in 1:(S-1)) {
//       for (j in (i+1):S) {
//         B[i, j] = offdiag_B[idx];
//         idx += 1;
//       }
//     }
//
//     // Fill the lower diagonal
//     for (i in 2:S) {
//       for (j in 1:(i-1)) {
//         B[i, j] = offdiag_B[idx];
//         idx += 1;
//       }
//     }
//   }
//
//   // make the true abds
//   matrix[S, n_time] true_abd;
//   true_abd[,1] = A + B * starting + error[,1];
//   for (t in 2:n_time){
//     true_abd[,t] = A + B * true_abd[,t-1] + error[,t];
//   }
}
model {

  // offdiag_B ~ normal(0, .1);
  // diag_B ~ uniform(.01, 0.99);
  // A ~ normal(0, .3);
  // to_vector(error) ~ normal(0, sigma_error);
  // sigma_error ~ exponential(10);
  //
  // // likelihood
  // abds ~ poisson_log(to_vector(true_abd));
}
generated quantities{
  // array[n_time, S] int sim_abds;
  //
  // for (i in 1:n_time){
  //   sim_abds[i,] = poisson_log_rng(true_abd[,i]);
  // }
}
