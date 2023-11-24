
abar <- .7
assym <- .5
as <- rnorm(2, abar, assym)

curve(plogis(.2*(x - 50)) * plogis(-.1 * (x - 120)),
      xlim = c(0, 200), ylim = c(0, 1))

hof <- function(avec, bvec){
  force(avec)
  force(bvec)
  function(x) {
    plogis(avec[1]*(x - bvec[1])) * plogis(-avec[2] * (x - bvec[2]))
  }
}

curve(hof(c(.2, .1), bvec = c(45, 133))(x), xlim = c(0, 200))


(log(.2) + log(.1))/2

-1.96 - (-2.3)

curve(hof(
  exp(rnorm(2, mean = -1.96, sd = .34)),
  bvec = c(45, 133))(x),
  xlim = c(0, 200))

curve(hof(
  rlnorm(2, mean = -1.96, sd = .34),
  bvec = c(45, 133))(x),
  xlim = c(0, 200))

curve(hof(
  0.14*rlnorm(2, mean = 0, sd = .34),
  bvec = c(45, 133))(x),
  xlim = c(0, 200))

## OR factor out the TOTAL slope and partition it, with the idea that the total
## is going more to the right than the left

curve(dbeta(x, 6, 4) )

atot <- .2 + .1
p <- rbeta(1, 6, 4)
curve(hof(c(atot*p, atot*(1-p)), bvec = c(45, 133))(x), xlim = c(0, 200))

## HOF curve
hof <- function(avec, bvec){
  force(avec)
  force(bvec)
  function(x) {
    plogis(avec[1]*(x - bvec[1])) * plogis(-avec[2] * (x - bvec[2]))
  }
}
# or again via logistic distribution
atot <- rnorm(1, mean = .2, sd = .1)
# # alternative: the lognormal distribution
# atot <- rlnorm(1, mean = -1.6, sd = .2)
p <- plogis(rnorm(1, mean = .9, sd = .2))
curve(hof(c(atot*p, atot*(1-p)), bvec = c(45, 133))(x), xlim = c(0, 200))

curve(exp(-log(1 + exp(2*(x - 0)))), xlim = c(-3, 3))
