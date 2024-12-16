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
  int<lower=0, upper=S*n_time> n_abs;
  array[n_abs, 2] int<lower=1,upper=max([S,n_time])> abs_idx;

  // Observations of species abundances
  // int<lower=S> n_obs; // every species is observed at least once!
  // array[n_obs] int<lower=0> abd;
  // array[n_obs] int<lower=1,upper=S*n_time> abd_idx;
}
transformed data{
  // set up addition matrix
  matrix[S,n_time] additions = rep_matrix(0, S, n_time);

  for(i in 1:n_add){
    additions[add_idx[i,1], add_idx[i,2]] = added[i];
  }

  // set up true abundance matrix
}
parameters {
  vector<lower=0,upper=.1>[S] A;
  vector<lower=0,upper=.1>[S*S] B_vec;
}
transformed parameters {

  matrix[S,S] B;

{
  int B_idx = 1;
  for (i in 1:S) {
    for (j in 1:S) {
      B[i,j] = B_vec[B_idx];
      B_idx += 1;
    }
  }
}


matrix[S, n_time] true_abd;

// add zeros
for(i in 1:n_abs){
  true_abd[abs_idx[i,1], abs_idx[i,2]] = 0;
}

  for (t in 2:n_time){
    vector[S] total_abd = true_abd[,t-1] + additions[,t-1];
    vector[S] growth = A + B * total_abd;

    for (s in 1:S) {
      true_abd[s,t] = total_abd[s] != 0 ? growth[s] : 0;
    }
  }


}
model {
  A ~ uniform(0, .1);
  B_vec ~ uniform(0, .1);
  // print(B);
  // print(A);
  // print(additions);
  // print(true_abd);
}
