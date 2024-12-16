// this version of the model also includes flexibility for various additions over time

data {
  // NOTES on some of the data validation:
  // the max for some indexes is set to timepoint id. This is maybe a little
  // confusing because some of these variables hold both time and species IDs
  // I'm making the assumption that you have more timepoints than you do species!

  // We add total species richness for convenience but also have the number of
  // trophic levels and the number of species in each!
  int<lower=1> S;
  int<lower=1> n_trophic;
  array[n_trophic] int<lower=1,upper=S> S_trophic;
  array[S] int<lower=1,upper=S> sp_id;

  int<lower=S,upper=S*S> nlinks;
  array[nlinks] int resc;
  array[nlinks] int cons;

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
  // note that this includes the first week, when species are added but not present
  int<lower=S, upper=S*n_time> n_abs;
  array[n_abs, 2] int<lower=1,upper=max([S,n_time])> abs_idx;

  // Observations of species abundances
  // int<lower=S> n_obs; // every species is observed at least once!
  // array[n_obs] int<lower=0> abd;
  // array[n_obs] int<lower=1,upper=S*n_time> abd_idx;
}
transformed data {
  // set up addition matrix
  matrix[S,n_time] additions = rep_matrix(0, S, n_time);

  for(i in 1:n_add){
    additions[add_idx[i,1], add_idx[i,2]] = added[i];
  }

  // calculate how many competition values we need
  array[n_trophic] int ndiags;
  for (k in 1:n_trophic){
    ndiags[k] = S_trophic[k] * S_trophic[k] - S_trophic[k];
  }

  int ncomp = sum(ndiags);
}
parameters {
  real avg_log_A;
  vector[S] sp_log_A;
  real<lower=0> sigma_sp_log_A;
  vector[n_time] time_log_A;
  real<lower=0> sigma_time_log_A;
  vector[S] diag_B_logit;
  vector[ncomp] log_comp;
  vector[nlinks] logit_prey_effects;
  vector[nlinks] log_pred_eff_fac;
}
transformed parameters {
  // interaction matrix
  matrix[S,S] B;

  //  transform and fill diagonal of interaction matrix
  // CONSTRAINT: between 0 and 1
  vector<lower=0,upper=1>[S] diag_B = inv_logit(diag_B_logit);

  for (s in 1:S){
    B[s, s] = diag_B[s];
  }

  vector[ncomp] comp = -exp(log_comp);
  // fill in the competition elements.
  // this needs to be done in {} because
  // otherwise declaring B_idx
  // is an error.
  {
    // index for going into the off-diag vector
    int idx = 1;
    // index for tracking which species we are looking at
    // tr_start = trophic start, ie the first species in that trophic level
    int tr_start = 1;
    int tr_end = 0;

    for (k in 1:n_trophic) {

      tr_end += S_trophic[k];

      // print("filling in species", tr_start, "to", tr_end);
      // Fill the upper triangle
      for (i in tr_start:(tr_end - 1)) {
        // print("now filling row ", i);
        for (j in (i+1):tr_end) {
          // print(" and col ", j);
          // print(" with index ", idx);
          B[i, j] = comp[idx];
          idx += 1;
        }
      }

        // print("lower tri");

      // Fill the lower triangle
      for (i in (tr_start + 1):tr_end) {
        // print("now filling row ", i);
        for (j in tr_start:(i-1)) {
          // print(" and col ", j);
          // print(" with index ", idx);
          B[i, j] = comp[idx];
          idx += 1;
        }

      }

      tr_start += S_trophic[k];
    }
  }


  // Predation effects
  // transform effects
  vector[nlinks] prey_effects = inv_logit(logit_prey_effects);
  vector[nlinks] pred_effects = -prey_effects .* exp(log_pred_eff_fac);
  // fill in matrix
  for (i in 1:nlinks){
        B[resc[i],cons[i]] = pred_effects[i];
        B[cons[i],resc[i]] = prey_effects[i];
    }
// print(B);
  // Growth rate
  matrix[S, n_time] A;

  for (s in 1:S){
    for (t in 1:n_time){
      A[s,t] = exp(avg_log_A + sp_log_A[s] + time_log_A[t]);
    }
  }

  // Abundance matrix
  matrix[S, n_time] true_abd;

  // add zeros
  for(i in 1:n_abs){
    true_abd[abs_idx[i,1], abs_idx[i,2]] = 0;
  }

  // Change over time
  for (t in 2:n_time){
    vector[S] total_abd = true_abd[,t-1] + additions[,t-1];
    vector[S] growth = A[,t] + B * total_abd;

    for (s in 1:S) {
      true_abd[s,t] = total_abd[s] != 0 ? growth[s] : 0;
    }
  }


}
model {
  avg_log_A ~ normal(1.6, .1);
  sp_log_A ~ normal(0, sigma_sp_log_A);
  sigma_sp_log_A ~ exponential(6);
  time_log_A ~ normal(0, sigma_time_log_A);
  sigma_time_log_A ~ exponential(6);
  diag_B_logit ~ normal(-2.5, .2);
  log_comp ~ normal(-2, .2);
  logit_prey_effects ~ normal(-2, 1);
  log_pred_eff_fac ~ normal(-2, .3);
  // print(B);
  // print(A);
  // print(additions);
  // print(true_abd);
}
generated quantities {
  array[S, n_time] int obs_abd;

  for(i in 1:n_time){
    obs_abd[,i] = poisson_log_rng(true_abd[,i]);
  }
}
