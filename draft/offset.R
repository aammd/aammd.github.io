  library(ggplot2)

# Set seed for reproducibility
set.seed(123)

# Create a data frame with random x positions
df <- data.frame(x = runif(50, 0, 10))

# Plot using ggplot2
ggplot(df, aes(x = x)) +
  geom_segment(aes(x = x, xend = x, y = 0, yend = 2)) +  # Vertical lines from y=0 to y=2
  theme_void() +  # Remove background, axis, and grid lines
  coord_fixed(ratio = 1/5)  # Keep a 5:1 aspect ratio for the rectangle

library(ggplot2)

# Set seed for reproducibility
set.seed(123)

# Create a data frame with random x positions between 0 and 24
df <- data.frame(x = runif(50, 0, 24))

# Generate random start and end points for the blue rectangle
rect_start <- runif(1, 5, 10)
rect_end <- runif(1, 13, 20)

# Plot using ggplot2
ggplot(df, aes(x = x)) +
  # Draw the light blue rectangle
  annotate("rect", xmin = rect_start, xmax = rect_end, ymin = 0, ymax = 2, fill = "lightblue", alpha = 0.5) +
  # Add the randomly spaced vertical lines
  geom_segment(aes(x = x, xend = x, y = 0, yend = 2)) +  # Vertical lines from y=0 to y=2
  theme_void() +  # Remove background, axis, and grid lines
  coord_fixed(ratio = 1/3)  # Keep a 12:1 aspect ratio for the rectangle

##
library(ggplot2)

# Create a data frame with 20 squares, and a column for color
df <- data.frame(
  x = 1:20,
  y = rep(1, 20),
  color = ifelse(1:20 %in% c(10, 11), "lightblue", "white")  # Shade squares 10 and 11 light blue
)

# Plot using ggplot2
ggplot(df, aes(x = x, y = y)) +
  geom_tile(aes(fill = color, width = 0.9, height = 0.9), color = "black") +  # Draw squares
  scale_fill_identity() +  # Use specified colors from the data frame
  theme_void() +  # Remove background, axis, and grid lines
  coord_fixed(ratio = 1) +  # Keep squares aspect ratio
  theme(panel.grid = element_blank())  # Remove any remaining gridlines


## with dots -----

library(ggplot2)

# Set seed for reproducibility
set.seed(123)

# Create a data frame with 20 squares, and a column for color
df <- data.frame(
  x = 1:20,
  y = rep(1, 20),
  color = ifelse(1:20 %in% c(10, 11), "lightblue", "white")  # Shade squares 10 and 11 light blue
)

# Create a data frame for the dots (two random positions for each square)
dots <- data.frame(
  x = rep(1:20, each = 2),  # 2 dots per square
  y = rep(1, 40),  # Keep y as 1 for all dots (same row)
  dot_x = rep(1:20, each = 2) + runif(40, -0.4, 0.4),  # Random x position within square
  dot_y = rep(1, 40) + runif(40, -0.4, 0.4)  # Random y position within square
)

# Plot using ggplot2
ggplot() +
  # Draw the squares
  geom_tile(data = df, aes(x = x, y = y, fill = color, width = 0.9, height = 0.9), color = "black") +
  scale_fill_identity() +  # Use specified colors from the data frame
  # Add the random dots
  geom_point(data = dots, aes(x = dot_x, y = dot_y), color = "black", size = .6) +
  theme_void() +  # Remove background, axis, and grid lines
  coord_fixed(ratio = 1) +  # Keep squares aspect ratio
  theme(panel.grid = element_blank())  # Remove any remaining gridlines

### random dots -----
library(ggplot2)

# Set seed for reproducibility
set.seed(123)

# Create a data frame with 20 squares, and a column for color
df <- data.frame(
  x = 1:20,
  y = rep(1, 20),
  color = ifelse(1:20 %in% c(10, 11), "lightblue", "white")  # Shade squares 10 and 11 light blue
)

# Generate number of dots for each square based on Poisson distribution with mean 2
num_dots <- rpois(20, lambda = 2)

# Create a data frame for the dots
dots <- data.frame(
  square_x = rep(1:20, times = num_dots),  # Repeat each square position based on the number of dots
  dot_x = rep(1:20, times = num_dots) + runif(sum(num_dots), -0.4, 0.4),  # Random x position within each square
  dot_y = rep(1, sum(num_dots)) + runif(sum(num_dots), -0.4, 0.4)  # Random y position within each square
)

# Plot using ggplot2
ggplot() +
  # Draw the squares
  geom_tile(data = df, aes(x = x, y = y, fill = color, width = 0.9, height = 0.9), color = "black") +
  scale_fill_identity() +  # Use specified colors from the data frame
  # Add the random dots
  geom_point(data = dots, aes(x = dot_x, y = dot_y), color = "black", size = .4) +
  theme_void() +  # Remove background, axis, and grid lines
  coord_fixed(ratio = 1) +  # Keep squares aspect ratio
  theme(panel.grid = element_blank())  # Remove any remaining gridlines




### two sites -- a valley and a mountain

n <- 1000
avg_valley <- 12
avg_mountain <- 7
all_valley <- rpois(n, avg_valley)
all_mountain <- rpois(n, avg_mountain)

by_two <- seq(from =1, to = n, by = 2)
by_five <- seq(from = 1, to = n, by = 5)
library(purrr)
samp_valley <- sample(by_two, size = 30, replace = FALSE) |>
  map_dbl(~ sum(all_valley[.x:(.x+9)]))

# sample(by_two, size = 30, replace = FALSE) |>
  # map_dbl(~ length(all_valley[.x:(.x+1)]))

samp_mountain <- sample(by_five, size = 30, replace = FALSE) |>
  map_dbl(~ sum(all_mountain[.x:(.x+16)]))

# sample(by_five, size = 30, replace = FALSE) |>
#   map_dbl(~ length(all_valley[.x:(.x+4)]))

library(tidyverse)
flower_data <- bind_rows(
  tibble::tibble(site = "valley", count = samp_valley, quadrat_size = 10),
  tibble::tibble(site = "mountain", count = samp_mountain, quadrat_size = 17)
)

flower_data |>
  ggplot(aes(x=site, y = count)) + geom_count()

summary(lm(count ~ site, data = flower_data))

coef(glm(count ~ site, data = flower_data, family = poisson())) |> exp()
coef(glm(count ~ site + offset(log(quadrat_size)), data = flower_data, family = poisson())) |>
  sum() |>
  exp()

