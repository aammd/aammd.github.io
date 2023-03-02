list(
  stantargets::tar_stan_mcmc(name = one_spp, 
                stan_files = "simple_type2.stan",
                data = generate_one_spp_type_too(),
                stdout = R.utils::nullfile(),
                stderr = R.utils::nullfile()
  )
)
