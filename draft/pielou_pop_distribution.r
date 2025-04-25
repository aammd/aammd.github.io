
#<!-- notes on simulating a population growth according to Pielou's book, p35, and interested to see if it matches her math at all.  -->



sim_growth <- function(r = .1){
  pop <- numeric(50)
  pop[1] = 2
  
  for (i in 2:length(pop)){
    pop[i] <- pop[i-1] + sum(runif(pop[i-1]) < r)
  }

  return(pop)
}





pops <- map_df(1:402, ~tibble(time = 1:50, N = sim_growth(r=.13)), .id = "sim")

ggplot(pops, aes(x = time, y = N, group = sim))+ geom_line(alpha = .4)

pops |> 
  filter(time == max(time)) |> 
  ggplot(aes(x=N)) + 
  geom_histogram(binwidth = 10)



#<!-- using the delta method from p35 of Mangel -->

making it most likely to work: using the expected, not observed, quantities 

```{r}
N_mean <- aphid_clone_data |> 
  mutate(lambda = sqrt(expect_aphids/1)) |> 
  arrange(clone_id) |> 
  mutate(r = log(lambda))
  group_by(clone_id) |> 
  summarise(mean_abd = mean(obs_aphids)) |> 
  pluck("mean_abd")

lambda_mean <- mean(N_mean/2)
lambda_var <- var(N_mean/2)

r <- log(lambda_mean) - lambda_var/(lambda_mean)^2


```

