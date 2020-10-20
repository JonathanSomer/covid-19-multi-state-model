# Assign weights at the patient level. 
# When the datasets are then generated based on these objects the same weight will be used for all transitions
assign_weights = function(dataset) {
  weighted_dataset = lapply(dataset, function(obj) {
    obj$weight = rexp(1,1)
    return(obj)
  })
  return(weighted_dataset)
}
