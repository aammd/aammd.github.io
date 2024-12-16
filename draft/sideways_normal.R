library(ggplot2)

  # Set parameters for the normal distribution
  mean_y <- 5  # Center of the normal distribution
  sd_y <- 0.5   # Standard deviation

  # Create a sequence of y values
  y_values <- seq(0, 10, length.out = 100)

  # Calculate the corresponding normal density values
  normal_density <- dnorm(y_values, mean = mean_y, sd = sd_y)

  # Create a data frame for plotting
  df <- data.frame(y = y_values, density = normal_density)

  # Plot using ggplot2
  ggplot(df, aes(x = density, y = y)) +
    geom_polygon(color = "green", size = 1) +  # Plot the normal distribution
    geom_area(aes(fill = "Normal Distribution"), alpha = 0.3) +  # Shade the area under the curve
    labs(title = "Vertical Normal Distribution", x = "Density", y = "y") +  # Axis labels and title
    theme_minimal() +  # Clean theme
    scale_fill_manual(name = "Legend", values = "lightgreen") +  # Custom legend
    theme(legend.position = "none")  # Remove legend

