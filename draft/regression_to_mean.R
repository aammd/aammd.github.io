true <- rnorm(20000, 0, 1) #runif(2000, -2,2)
hab1 <- rnorm(20000, true)
hab2 <- rnorm(20000, true)

lm(hab2 ~ hab1) |> summary()
plot(hab1, hab2)
abline(0,1)
abline(lm(hab2 ~ hab1), col = "green", lwd = 2)

# The amount of correlation present depends on how much variation there is in
# the original data -- the relative difference of scale between the x-axis and
# the error in the two habitats

# How would I test this hypothesis? that a tradeoff exists between two different habitats?
# maybe fit the two as a factor in an anova?

hab_df <- rbind(
  cbind(hab1, 1),
  cbind(hab2, 0)) |>
  as.data.frame()

names(hab_df) <- c("hab", "is_one")

summary(lm(hab~ is_one, data = hab_df))


