# Covid-19 Multi-State Model

## Welcome

This package presents a multi-state survival analysis model which can be used to predict covid-19 patients' illness trajectories from time of hospitalization up to time of recovery or death.

Transitions between states (such as: "severe" to "death") are modeled using survival models with competing risks, and the patient's journey is estimated via Monte-Carlo simulation over these transitions, while updating time-dependent patient covariates.

The following examples introduce the model and provide examples for typical usage. We suggest following the examples in order.

Each notebook has a corresponding pre-rendered html file with the same name as the `*.Rmd` file. Reviewing the html files is the fastest way to review the examples and decide if they are useful for your setting.

## 1. Introducing The Model

### [first_example.Rmd](./first_example.Rmd)

This notebook provides a simple working example, while introducing the basic components of the model and dataset used to fit the model. 

By following the steps described in this notebook you can fit the model to your own data and make predictions. 


## 2. Prediction Using the Model Fit to Israeli Covid-19 Data

If you do not have access to Covid-19 patient data, you can perform predictions using our model which was fit to national Israeli Covid-19 patient data.

**Note:** We strongly encourage using a model which was fit to data that is as close as possible to your own setting, ideally: recent data from the same hospital. Even among Israeli hospitals there was weak generalization among certain hospitals.

### [single_patient_prediction.Rmd](./single_patient_prediction.Rmd)

  This notebook shows how to  estimate the following values, for a single patient: 
  
  * probability of death
  * probability of future severe state
  * quantiles of predicted time in hospital
  * quantiles of predicted time in severe state
  * Cumulative Distribution Function (CDF) for time at hospital
  
 
### [multiple_patient_prediction.Rmd](./multiple_patient_prediction.Rmd)
  This notebook provides an aggregate view of the future for any set of patients. These could be all patients in a certain hospital, ward or even an entire country.
  
  * Expected number of deaths over time
  * Expected number of hospitalized patients over time
  * Expected number of hospitalized severe patients over time
  
  The notebook also shows how to include expected future hospitalizations in the estimates.
