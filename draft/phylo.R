## based on Ives book chapter 3.6

n <- 20
b0 <- 0
b1 <- .5
lam.x <- 1
lam.e <- .5
phy <- ape::compute.brlen(
  ape::rtree(n=n),
  method = "Grafen",
  power = 1)

plot(phy)

ape::vcv(phy, corr = TRUE)


phy.x <- phylolm::transf.branch.lengths(phy=phy, model="lambda",
                               parameters=list(lambda = lam.x))$tree
phy.e <- phylolm::transf.branch.lengths(phy=phy, model="lambda",
                               parameters=list(lambda = lam.e))$tree
x <- ape::rTraitCont(phy.x, model = "BM", sigma = 1)
e <- ape::rTraitCont(phy.e, model = "BM", sigma = 1)
x <- x[match(names(e), names(x))]
Y <- b0 + b1 * x + e
Y <- array(Y)
rownames(Y) <- phy$tip.label
