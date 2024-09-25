data {
  int<lower=1> S;
  // how many assemblages and their data
  int<lower=1> n_assemblage;
  array[n_assemblage] int<lower=1> S_each;
  array[n_assemblage] int<lower=1> n_time_each;
  array[n_assemblage] int<lower=0,upper=S> n_shared;
  array[n_assemblage] int<lower=0,upper=S> n_introd;
  array[to_int(dot_product(to_vector(S_each), to_vector(n_time_each)))] int obs;
  // starting density for each species (assumption is that it is the same across the whole experiment for a species)
  vector[S] starting;
  // which species is introduced when? assumption here is that species are introduced only once.
  array[sum(n_shared)] int<lower=1,upper=S> shared_grp;
  array[sum(n_introd)] int<lower=1,upper=S> introd_seq;
}
transformed data {
  // final position for each group in the data
  array[n_assemblage] int S_end = cumulative_sum(S_each);
  array[n_assemblage] int time_end = cumulative_sum(n_time_each);
  array[n_assemblage] int shared_end = cumulative_sum(n_shared);
  array[n_assemblage] int introd_end = cumulative_sum(n_introd);
  // start and ends for errors
  array[sum(n_time_each)] int err_int_stt;
  array[sum(n_time_each)] int err_int_end;
  int idx_e = 1;
  // print("this is time end", time_end);


  for(i in 1:n_assemblage) {
    int n_nums = n_time_each[i];
    // print("I am selecting ", n_nums);
    err_int_end[idx_e:(idx_e - 1 + n_nums)] = rep_array(S_each[i], n_nums);
    idx_e += n_nums;
  }

  array[sum(n_time_each)] int err_ends = cumulative_sum(err_int_end);

  array[1] int ss;
  ss[1] = 0;
  err_int_stt = append_array(ss, head(err_int_end, size(err_int_end)-1));
  array[sum(n_time_each)] int err_init = cumulative_sum(err_int_stt);
  for (j in 1:size(err_init)) err_init[j] += 1;


  // print("error starts = ", err_init);
  // print("error ends = ", err_ends);


  // array[n_assemblage] int<lower=1> S_each;
  // for (i in 1:n_assemblage){
  //   S_each[i] = n_shared[i] + n_introd[i];
  // }
  //  get the
  int idx_sp=1;
  int idx_share=1;
  int idx_intro=1;

  array[sum(S_each)] int<lower=1,upper=S> sp;
  // S_each is entered separately, and so this serves as an extra double check (this = using it as the size below)
  for (i in 1:n_assemblage){
    if (n_shared[i] == 0) {
      sp[idx_sp:S_end[i]] = introd_seq[idx_intro:introd_end[i]];
      idx_intro += n_introd[i];
    } else if (n_introd[i] == 0){
      sp[idx_sp:S_end[i]] = shared_grp[idx_share:shared_end[i]];
      idx_share += n_shared[i];
    } else {
      sp[idx_sp:S_end[i]] = append_array(shared_grp[idx_share:shared_end[i]],
                                       introd_seq[idx_intro:introd_end[i]]);
      idx_share += n_shared[i];
      idx_intro += n_introd[i];
    }
    idx_sp += S_each[i];
  }
  print(sp);
}
// calculate S here if I get rid of it
parameters {
  vector[S*(S-1)] offdiag_B;
  vector<lower=0,upper=1>[S] diag_B;
  vector[S] A;
  vector[to_int(dot_product(to_vector(S_each), to_vector(n_time_each)))] error;
  real<lower=0> sigma_error;
}
transformed parameters {
  // make the B matrix
  matrix[S, S] B;

  // fill the diagonal
  for (s in 1:S){
    B[s, s] = diag_B[s];
  }

  // fill the off diagonals
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

  // calculate abundances

  matrix[S,sum(n_time_each)] true_abd;
  // fill in illegal values for every square
  //  these will only remain where the species was not yet added
  true_abd = rep_matrix(-9, S, sum(n_time_each));

  {
    int idx_spp=1;
    int idx_time=1;
    int idx_err=1;

    // do a transition matrix for every assemblage
    for (i in 1:n_assemblage){

      // get species vector for this assemblage
      array[S_each[i]] int sp_i = sp[idx_spp:S_end[i]];

      // A for this assemblage
      vector[S_each[i]] A_i = A[sp_i];
      // B for this assemblage
      matrix[S_each[i],S_each[i]] B_i = B[sp_i,sp_i];
      // error for this assemblage -- see in loop
      // true_a for this assemblage
      matrix[S_each[i], n_time_each[i]] true_abd_i = true_abd[sp_i, idx_time:time_end[i]];

      // starting true abd:
      // find the first vector and put it together
      vector[S_each[i]] start_pop;

      if (n_shared[i] == 0) {
        // if no shared species with last assemblage, then all were introduced
        start_pop = starting[sp_i];
      } else if (n_introd[i] == 0){
        // if no species are introduced, then all come from the last assemblage
        start_pop = true_abd[sp_i, idx_time - 1];
      } else {
        // if both, then take the appropriate parts from sp_i and use them to get the right numbers from the right places
        start_pop = append_row(
          true_abd[sp_i[1:n_shared[i]], idx_time - 1],
          starting[sp_i[ (n_shared[i]+1):(n_shared[i] + n_introd[i]) ]]
        );
      }

      // calculate true abundance for first sample
      // S_each is the number of species in this part of the dataset, so that is the number of errors we need.
      true_abd_i[,1] = B_i * start_pop + A_i + error[err_init[idx_err]:err_ends[idx_err]];

      // increment error
      idx_err += 1;

      // for loop for the rest of the timesteps here
      // increment errors every time
      for (t in 2:n_time_each[i]){

        true_abd_i[,t] = B_i * true_abd_i[,t-1] + A_i + error[err_init[idx_err]:err_ends[idx_err]];
        idx_err += 1;
      }

      // put the numbers back in the original object -- is this necessary?
      true_abd[sp_i, idx_time:time_end[i]] = true_abd_i;

      // increment counters
      idx_spp += S_each[i];
      idx_time += n_time_each[i];
    }

  }
}
model {

  offdiag_B ~ normal(0, .1);
  diag_B ~ uniform(.01, 0.99);
  A ~ normal(0, .3);
  error ~ normal(0, sigma_error);
  sigma_error ~ exponential(10);
  //
  // // likelihood
  // abds ~ poisson_log(to_vector(true_abd));
}
generated quantities{
 array[S, sum(n_time_each)] int sim_abd = rep_array(0, S, sum(n_time_each));

 for (t in 1:sum(n_time_each)) {
   sim_abd[,t] = poisson_log_rng(true_abd[,t]);
 }
}
