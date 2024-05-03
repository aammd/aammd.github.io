
a <- .5
y <- 1
curve(exp(-a*x)/(exp(-a*x) + y), xlim = c(-6, 10), ylim = c(0,1))
abline(v = log(1/y)/a, h = .5, lty = 2)
curve(plogis(-a*(x - 1/a * log(1/y))), add = TRUE, lty = 2, col = "red", lwd = 2)


## sums of random variables

#' make a sum of many random variables. Can its value be approximated?
#'

library(tidyverse)
things <- rnorm(3000, 0, 1)
sum(things)

map_dbl(1:200, ~sum(rnorm(300))) |> hist()
