This Notebook
=============

This notebook provides a simple setting which illustrates basic usage of
the model.

A Typical Setting:
==================

In a typical setting of modelling patient illness trajectories, there
are multiple sources of complexity:

1.  There could be many states (mild, severe, recovered, released from
    hospital, death etc.)

2.  The probability of each transition and the duration of the stay in
    each state depend on patient covariates.

3.  Patient covariates can change over time, possibly in a manner which
    depends on the states visited.

In order to introduce the multi-state-model we shall use a much simpler
setting where our data arrives from a simple 3 state model and
covariates do not change over time or affect the probabilities of
transitions between states.

A Simple Multi-State Setting:
=============================

Patients start at state 1, state 3 shall be a terminal state and states
1,2 shall be identical in the sense that from both:

1.  With probability 1/2 you transition to state 3 within 1 day.

2.  With probability 1/2 you transition to state 2 or 1 (depending on
    the present state), within *t* ∼ exp(*λ*)

<figure>
<img src="./toy_setting.png" alt="A simple Multi-State Model" id="id" class="class" style="width:50.0%;height:50.0%" /><figcaption>A simple Multi-State Model</figcaption>
</figure>For this setting, one can show that the expected time until
reaching a terminal state is $1+\\frac{1}{\\lambda}$ (see proof at the
end of this notebook.)

The Dataset Structure
---------------------

Let’s load the dataset, which was constructed based on the graph above:

    dataset = create_toy_setting_dataset(lambda=2)
    typeof(dataset)

    ## [1] "list"

The dataset is simply a list. Each element in the list corresponds to a
single sample’s (i.e “patient’s”) observed path. Let’s look one such
object in detail:

    head(dataset, n=1)

    ## [[1]]
    ## [[1]]$covariates
    ## [1]  0.5302694 -0.2560965
    ## 
    ## [[1]]$states
    ## [1] 1 2 1 3
    ## 
    ## [[1]]$time_at_each_state
    ## [1] 0.2852433 0.5656666 1.0000000
    ## 
    ## [[1]]$id
    ## [1] 1

We see the following attributes:

1.  `covariates`: These are the sample’s covariates. In this case they
    were randomally generated and do not affect the state transitions,
    but for a patient this could be a numerical vector with entries such
    as:
    -   “age in years”
    -   “is male”
    -   “number of days that have passed since hospitalization”
    -   etc..
2.  `states`: These are the observed states the sample visited, encoded
    as positive integers. Here we can see the back and forth between
    states 1 and 2, ending with the only terminal state (state 3).

3.  `time_at_each_state`: These are the observed times spent at each
    state.

4.  `id`: (optional) a unique identifier of the patient.

**Note:** if the last state is a terminal state, then the vector of
times should be shorter than the vector of states by 1. Conversely, if
the last state is not a terminal state, then the length of the vector of
times should be the same as that of the states. In such a case, the
sample is inferred to be right censored.

Updating Covariates Over Time
-----------------------------

In order to update the patient covariates over time, we need to define a
state-transition function. In this simple case, the covariates do not
change and the function is trivial:

    update_covariates = function(covariates_entering_origin_state, ...){
      return(covariates_entering_origin_state)
    }

You can define the function to accept any of the following named
arguments, which are supplied to the function by default within the
model:

-   sample\_covariates
-   origin\_state
-   target\_state
-   time\_at\_origin\_state
-   absolute\_time\_of\_entry\_to\_target\_state

Assume some model includes a covariate for the total time spent thus far
in the SEVERE state, and assume this is the first covariate. An example
non-trivial function could be:

    example_function = function(sample_covariates, origin_state, target_state, time_at_origin_state){
      
      if (origin_state == SEVERE) {
        sample_covariates[1] = sample_covariates[1] + time_at_origin_state
      }
      
      return(sample_covariates)
    }

Defining Terminal States
------------------------

    terminal_states = c(3) # 3 is the only terminal state

Fitting The Model
-----------------

Load and init the Model:

    source('./model/multi_state_competing_risks_model.R')
    model = MultiStateModel()

Fit the Model:

    model$fit(dataset, 
              terminal_states, 
              update_covariates, 
              covariate_names=c("covariate one", "covariate two"))

    ## [1] "Fitting Model at State:  1"
    ## [1] ">>> Fitting Transition to State:  2 , n events:  635"
    ## [1] ">>> Fitting Transition to State:  3 , n events:  676"
    ## [1] "Fitting Model at State:  2"
    ## [1] ">>> Fitting Transition to State:  1 , n events:  311"
    ## [1] ">>> Fitting Transition to State:  3 , n events:  324"

We can see that a model was fit to each non-terminal state, and we can
see the number of observed events observed for each transition.

**Note:** If the number of events for a certain transition is too small,
a warning message could appear indicating that the model fitting did not
converge. Avoid use of the model in such cases as it is highly
unpredictable!

Making Predictions
------------------

Predictions are done via monte carlo simulation. Initial patient
covariates, along with the patient’s current state are supplied. The
next states are sequentially sampled via the model parameters. The
process concludes when the patient arrives at a terminal state or the
number of transitions exceeds the specified maximum.

    all_runs = model$run_monte_carlo_simulation(
                  # the current covariates of the patient. 
                  # especially important to use updated covariates in case of
                  # time varying covariates along with a prediction from a point in time 
                  # during hospitalization
                  sample_covariates = c(0.2,-0.3), 
                  
                  # in this setting samples start at state 1, but
                  # in general this can be any non-terminal state which
                  # then serves as the simulation starting point
                  origin_state = 1, 
                  
                  # in this setting we start predictions from time 0, but 
                  # predictions can be made from any point in time during the 
                  # patient's trajectory
                  current_time = 0,   
                  
                  # If there is an observed upper limit on the number of transitions, we recommend
                  # setting this value to that limit in order to prevent generation of outlier paths
                  max_transitions = 100,
                  
                  # the number of paths to simulate:
                  n_random_samples = 1000)

### The Simulation Results Format:

Each run is described by a list of states and times spent at each state
(same format as the `dataset` the model is fit to).

    head(all_runs, n=1)

    ## [[1]]
    ## [[1]]$states
    ## [1] 1 3
    ## 
    ## [[1]]$time_at_each_state
    ## [1] 1.000011

### Analyzing The Results

Recall we could compute the expected time for this simple setting? We
will now see that the model provides an accurate estimate of this
expected value of $1+ \\frac{1}{\\lambda}$

    plot_total_time_until_terminal_state(lambda = 2, 
                                         all_runs = all_runs)

![](first_example_files/figure-markdown_strict/unnamed-chunk-11-1.png)

Conclusion
==========

This notebook provides a simple example usage of the multi-state model,
beginning with the structure of the dataset used to fit the model and up
to a simple analysis of the model’s predictions.

By following this process you can fit the model to any such dataset and
make predictions

### Appendix 1: Proof that the expected time until reaching the terminal state is $1 + \\frac{1}{\\lambda}$

Let *T* be the random variable denoting the time until reaching the
terminal state \#3, and let *S*<sub>2</sub> be the random variable
denoting the second state visited by the sample (recall all patients
start at state 1, that is: *S*<sub>1</sub> = 1)

From the law of total expectation:
*E*\[*T*\] = *E*\[*E*\[*T*|*S*<sub>2</sub>\]\] = *P*(*S*<sub>2</sub> = 3) ⋅ *E*\[*T*|*S*<sub>2</sub> = 3\] + *P*(*S*<sub>2</sub> = 2) ⋅ *E*\[*T*|*S*<sub>2</sub> = 2\]

Denote *T* = *T*<sub>1</sub> + *T*<sub>2<sup>+</sup></sub> (“The total
time is the sum of the time of the first transition plus the time from
arrival to the second state onwards”). Then:

$$=\\frac{1}{2} \\cdot 1 + \\frac{1}{2} \\cdot E\[T\_1 + T\_{2^+}|S\_2=2\] = \\frac{1}{2} + \\frac{1}{2} \\cdot (E\[T\_1|S\_2=2\] + E\[T\_{2^+}|S\_2=2\])$$

$$=\\frac{1}{2} \\cdot 1 + \\frac{1}{2} \\cdot (\\frac{1}{\\lambda} + E\[T\])$$

We then have:
$$2 \\cdot E\[T\]= 1 + (\\frac{1}{\\lambda} + E\[T\])$$

and:

$$E\[T\] = 1+\\frac{1}{\\lambda}$$
