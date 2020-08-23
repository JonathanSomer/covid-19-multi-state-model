
# create the toy setting dataset
create_toy_setting_dataset = function(lambda){
  
  create_one_object = function(id){
    states = c()
    time_at_each_state = c()
    
    current_state = 1
    while (current_state != 3) {
      
      states = c(states, current_state)
      
      transition_to_3 = rbinom(1, 1, 0.5) == 1
      if (transition_to_3) {
        time_at_each_state = c(time_at_each_state, 1)
        current_state = 3
      } else {
        time_at_each_state = c(time_at_each_state, rexp(1, rate = lambda))
        current_state = 1 + (current_state %% 2)
      }
    }
    states = c(states, 3)
    
    object = list(
      covariates = rnorm(2), # random.
      states = states,
      time_at_each_state = time_at_each_state,
      id = id
    )
    
    return(object)
  }
  
  
  dataset = lapply(c(1:1000), create_one_object)
  
  return(dataset)
}



# plot distribution of times to terminal state and compare expeted to observed mean time
plot_total_time_until_terminal_state = function(lambda, all_runs) {
  t = as.numeric(lapply(all_runs, function(run) sum(run$time_at_each_state)))
  
  ggplot(data.frame(t), aes(x=t)) + 
    geom_density() + 
    geom_vline(xintercept= 1 + 1/lambda, color = "blue") +
    geom_vline(xintercept=mean(t), color = "red") + 
    ggtitle("Distribution of Total Time Until Terminal State") + 
    labs(subtitle = "Expected time denoted by blue line,\nMean observed time denoted by red line")
}