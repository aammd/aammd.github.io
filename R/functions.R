
text_title <- "How many groups is enough?"
text_desc <- "Simulations to see how many groups to use for a random effect"

post_title <- tolower(text_title) |>
  stringr::str_replace_all("[[:punct:]]", "") |>
  stringr::str_replace_all(" ", "-")

## make it so we can add other authors?
today_date <- Sys.Date()
post_dir_name <- paste0("posts/", today_date, "-", post_title)
fs::dir_create(post_dir_name)
setup_chunk <- "
```{r setup, eval=TRUE, message=FALSE, warning=FALSE}
library(targets)
library(ggplot2)
library(tidyverse)
library(tidybayes)
```
"

template <- '
---
title: {text_title}
author: Andrew MacDonald
description: |
{text_desc}
date: {today_date}
editor: source
categories: [UdeS, stan]
draft: true
---

{setup_chunk}
'

post_contents <- glue::glue(template)

index_file <- paste0(post_dir_name, "/index.qmd")
fs::file_create(index_file)

writeLines(post_contents, con = index_file)
