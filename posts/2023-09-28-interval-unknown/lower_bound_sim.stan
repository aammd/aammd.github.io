data {
  int n;
  vector[n] lowers;
}
parameters {
  vector<lower=lowers>[n] alpha;
}
model {
  alpha ~ std_normal();
}
