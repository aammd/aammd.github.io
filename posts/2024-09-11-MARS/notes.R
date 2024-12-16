#' Effect on other species should be less than effect on self, right?
#'
#' so instead of
#'
#' the columns of the matrix are always less than the diagonal, within a trophic
#' level
#'
#' so the diagonal value is per-capita effect on yourself and the rest of that
#' column is some proportion of it
#'
#' Does the sign need to change? negative for competition, but still less in
#' absolute magnitude? does that even make sense? maybe the diagonal and the
#' off-diagonal mean different things. I'll have to go back to the original
#' papers and try to understand it more
#'
#' what are properties of matrices where different blocks of the matrix are
#' functions, controlled by a different set of in put parameters?
#'
#' adding forbidden links tot he model wtill save on degrees of freedom. Fewer
#' parameters to estimate
#'
#' Do the calculations on the log scale, so that we add them together and
#' exponentiate them once at the end
#'
#' -exp(log_inv_logit(self limitation) + log_inv_logit(intraspecific_proportion))
#'
#' I wonder, I think i could define the whole matrix as exp() and just do it in
#' one line, but would that actually help matters? probably not
#'
#' But that reminds me, I think it IS possible to add the addition matrix and
#' the true_abd tables together directly, use that new matrix as the input and
#' still have true_abd as the output. would that be too mindbending.
#'
#' I also feel that there should be some kind of relationship between a
#' predator's percapita effect on prey and their growth rate.. maybe because to
#' me both relate to body size: Bigger predators require more prey and produce
#' less young per unit time than smaller predators.
#'
#' so then model the parameters as functions of body size? damn. Imagine. The
#' input parameters are the allometric scaling values, and the output is a
#' measure of food web stabiity or whatever.
#'
#' Coming back down to earth, there is the matter of adding in effects for
#' treatment. Does it really make sense for some of this to vary by treatment or
#' replicate -- would the factor by which self-limitation is transformed to
#' other-limitation really be expected to vary by habitat?
#'
#' perhaps self-limitation would vary by replicate? I will need to read Matt's paper and see if there are any specific hypotheses
#'\
#'
#'
#'
#' take out parasite on parasite violence (competition) an consider even taking out the density dependence of the parasitoid.
