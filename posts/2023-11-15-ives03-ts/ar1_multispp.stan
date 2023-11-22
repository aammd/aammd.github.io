data{
  int n;
  int nclone;
  vector[n] time;
  vector[n] x;
  array[n] int<lower=1, upper=nclone> clone_id;
}
// transformed data {
//   vector[n] x = log(pop);
// }
parameters {
  vector[nclone] log_a;
  vector[nclone] logit_b;
  vector[nclone] log_sigma;
}
transformed parameters {
  vector[nclone] b = inv_logit(logit_b);
  vector[nclone] mu_max = exp(log_a) ./ (1 - b);
  vector[nclone] sigma_max = exp(log_sigma) ./ sqrt(1 - b^2);
}
model {
  log_a ~ normal(.7, .2);
  logit_b ~ normal(1, .2);
  log_sigma ~ normal(-1.5, .5);
  x ~ normal(
    mu_max[clone_id] .* (1 - pow(b[clone_id], time)),
    sigma_max[clone_id] .* sqrt(1 - pow(b[clone_id]^2, time))
    );
}
generated quantities {
  matrix[15, nclone] x_pred;
  x_pred[1,] = rep_row_vector(0, nclone);
  for (s in 1:nclone){
    for (j in 1:14) {
      x_pred[j+1,s] = normal_rng(
        mu_max[s] .* (1 - pow(b[s], j)),
        sigma_max[s] .* sqrt(1 - pow(b[s]^2, j))
        );
    }
  }
}
