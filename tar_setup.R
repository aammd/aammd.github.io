
## set it up
# tar_config_set(script = "posts/2023-11-24-how-to-model-growth/tar_script.R",
#                store = "posts/2023-11-24-how-to-model-growth/store",
#                project = "2023-11-24-how-to-model-growth")
#

Sys.setenv(TAR_PROJECT = "2023-11-24-how-to-model-growth")
tar_make()
