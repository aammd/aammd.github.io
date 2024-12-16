// this version of the model also includes flexibility for various additions over time

data {
  // NOTES on some of the data validation:
  // sometimes I set max = n_time; this is because I think its safe to assume
  // that in many of these models there are more observation timepoints than species.
  int<lower=1> Sc; // richness of consumers
  int<lower=1> Sr; // richness of resources

  // consumer-resource interactions (cr for short)
  // how many consumer-resource links are in the foodweb?
  // upper limit is all the consumers are cannibal omnivores
  int<lower=1,upper=Sc*(Sr + Sc)> n_cr;
  array[n_cr] int<lower=1,upper=Sr> resc_id;
  array[n_cr] int<lower=1,upper=Sc> pred_id;

  // number of timepoints NOT including the first week of setup
  // time = 1 is the first week of observations
  int<lower=2> n_time;

  // number of additions -- every species is added at least once!
  int<lower=(Sr + Sc)> n_add;
  vector[n_add] added;
  array[n_add, 2] int<lower=1,upper=max([Sr+Sc, n_time])> add_idx;

  // Absences
  // how many times do we KNOW that a species is at 0 abundance?
  int<lower=0, upper=(Sr+Sc)*n_time> n_abs;
  array[n_abs, 2] int<lower=1,upper=max([Sr+Sc,n_time])> abs_idx;

  // Observations of species abundances
  // int<lower=S> n_obs; // every species is observed at least once!
  // array[n_obs] int<lower=0> abd;
  // array[n_obs] int<lower=1,upper=S*n_time> abd_idx;
}
transformed data{
  int S = Sr + Sc;
  // set up addition matrix
  matrix[S,n_time] additions = rep_matrix(0, S, n_time);

  for(i in 1:n_add){
    additions[add_idx[i,1], add_idx[i,2]] = added[i];
  }

  // set up true abundance matrix
}
parameters {
  vector[S] log_A;
  vector[S] diag_B_logit;
  vector[S*(S-1)] offdiag_B;
  vector[n_cr] resc_eff_on_pred_logit;
  vector[n_cr] pred_eff_on_resc_log_fac;
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

  vector[n_cr] resc_eff_on_pred = inv_logit(resc_eff_on_pred_logit);
  for (i in 1:n_cr){
    // resource effect on predator
    B[pred_id[i], resc_id[i]] = resc_eff_on_pred[i];

    // predator effect on resource
    B[resc_id[i], pred_id[i]] = resc_eff_on_pred[i] * (1 + exp(pred_eff_on_resc_log_fac[i]))

  }

  // Growth rate
  vector<lower=0>[S] A = exp(log_A);


  // Abundance matrix
  matrix[S, n_time] true_abd;

  // add zeros
  for(i in 1:n_abs){
    true_abd[abs_idx[i,1], abs_idx[i,2]] = 0;
  }

  // Change over time
  for (t in 2:n_time){
    vector[S] total_abd = true_abd[,t-1] + additions[,t-1];
    vector[S] growth = A + B * total_abd;

    for (s in 1:S) {
      true_abd[s,t] = total_abd[s] != 0 ? growth[s] : 0;
    }
  }


}
model {
  log_A ~ normal(0, .5);
  diag_B_logit ~ normal(-2, .5);
  offdiag_B ~ normal(0, .1);
  // print(B);
  // print(A);
  // print(additions);
  // print(true_abd);
}
