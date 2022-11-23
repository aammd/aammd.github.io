# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed. # nolint
library(stantargets)

# Set target options:
tar_option_set(
  packages = c("tibble", "ggplot2", "tidyverse"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source(files = dir("posts", pattern=".*\\.R", full.names = TRUE, recursive=TRUE))
tar_source(files = "R")
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(
    name = decay_add,
    command = make_decay_data_additive()
  ),
  tar_target(
    name = decay_mult,
    command = make_decay_data_multiplicative()
  ),
  tar_target(
    name = plot_add,
    command = plot_group_df(decay_add)
  ),
  tar_target(
    name = plot_mult,
    command = plot_group_df(decay_mult)
  ),
  # growth_curve_measurement_error ------------------------------------------
  tar_target(
    name = vb_one_tree,
    command = sim_vb_one_tree()
  ),
  tar_stan_mcmc(
    growth_curve_meas,
    stan_files = c(
      "posts/2022-10-14-growth_curve_measurement_error/vb_one_tree_Lo.stan",
      "posts/2022-10-14-growth_curve_measurement_error/vb_one_tree_Lo_oneline.stan"
    ),
    data = purrr::splice(
      as.list(vb_one_tree),
      n = nrow(vb_one_tree)
      ),
    return_draws = FALSE,
    stdout = R.utils::nullfile(),
    stderr = R.utils::nullfile()
  ),
  tar_stan_mcmc(
    growth_curve_predict,
    stan_files = c(
      "posts/2022-10-14-growth_curve_measurement_error/vb_one_tree_Lo_oneline_predictions.stan"),
    data = sim_vb_one_tree_and_new(),
    return_draws = FALSE,
    stdout = R.utils::nullfile(),
    stderr = R.utils::nullfile()
  )
  ,
  tar_quarto(blog)
)
