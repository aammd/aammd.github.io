data {
  int<lower=1> N;
  int<lower=1> J;
  matrix[N, J] M;
  int<lower=1> n_obs;
  array[n_obs] int<lower=1,upper=N*J> vec_idx;
}
parameters {
  real y;
}
model {
  y ~ std_normal();
  vector[N*J] v;
  v = to_vector(M);
  print(v);
  print(v[vec_idx]);
}

