# Set the seed for reproducibility

# set.seed(123)

# Generate predictors
n <- 200  # Number of observations
x1 <- rnorm(n)
x2 <- rnorm(n)
x3 <- rnorm(n)
x4 <- rnorm(n)

# Data-generating model: y = 2*x1 + 3*x2 - x3 + error
error <- rnorm(n, mean = 0, sd = 2)
y <- 2*x1 + 3*x2 - x3 + error

# Create a data frame
data <- data.frame(y, x1, x2, x3, x4)

# Fit the full model
full_model <- lm(y ~ x1 + x2 + x3 + x4, data = data)

# Perform stepwise AIC simplification
simplified_model <- step(full_model, direction = "both", trace = 0)

# Print results
cat("Data-generating model: y = 2*x1 + 3*x2 - x3 + error\n\n")
cat("Simplified model based on AIC:\n")
print(summary(simplified_model))




# with a collider ---------------------------------------------------------

library(tidyverse)

seed_yield <- 5
loca_yield <- 2
avg_yield <- 45

aphid_abd <- 30
aphid_diff <- 20

aphid_data <- expand_grid(seed_type = c(0, 1),
       location = c(0, 1),
       rep_id = 1:30) |>
  mutate(avg_biomass = avg_yield + seed_yield*seed_type + loca_yield*location,
         avg_aphids = aphid_abd + aphid_diff * location,
         biomass = rnorm(length(avg_biomass), mean = avg_biomass, sd = 2),
         aphids = rnorm(length(avg_aphids), mean = avg_biomass, sd = 2))


ggplot(aphid_data, aes(x = biomass, y = aphids)) + geom_point()

plot(aphid_data)

# Fit the full model
full_model <- lm(aphids ~ biomass + location + seed_type, data = aphid_data)

summary(full_model)

# Perform stepwise AIC simplification
simplified_model <- step(full_model, direction = "both", trace = 0)

summary(simplified_model)



