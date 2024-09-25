norowi <- readr::read_csv("~/Downloads/parasitoids - Sheet2.csv")

## how many weevils? 1292
norowi$n |> sum()
# yes

library(tidyverse)

norowi |>
  ggplot(aes(x = n, y = y/n)) + geom_point()


## how many seed heads # 373
nrow(norowi)
# yes

glimpse(norowi)
max(norowi$patch1) # these are known as "areas" in the text
## how many places with 0 hosts

norowi |>
  group_by(patch1) |>
  summarize(tot_n = sum(n)) |>
  arrange(tot_n)

# no zeros in data.. are the 0s gone

norowi$patch1 |> n_distinct()

## yes the 0s are removed from the dataset. why.

## how many plants were empty:

## says we have 131 non-empty plants but there's only 128 distinct plants
with(norowi, paste0(patch1, "_", plant1)) |> n_distinct()

## how many have all or none

norowi |>
  mutate(prop = y/n,
         all_or_nothing = prop == 0 | prop == 1) |>
  pluck("all_or_nothing") |>
  sum()

## that's the correct number of all or nothings
