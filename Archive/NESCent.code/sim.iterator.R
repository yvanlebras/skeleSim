## This is a function to iterate through simulations and analyses
## This function should take the following information:
##      The simulation parameters contained in the megalist
##      The analyis function contained in the megalist
## And this function should return:
##      Modifications to the megalist in the replicate metadata
##      Mods to the megalist, adding the output of the analyses

## Started 19 March 2015
## Started by cp

############################
############################

## Load required packages
library(adegenet)
library(rmetasim)

## Load required functions (that we wrote)
source("new.mainparam.list.R")
source("set.commonparams.R")
source("set.scenarios.R")
source("set.specparams.rmetasim.R")
source("rmetasim.sim.wrap.R")
source("rmetasim2adegenet.R")

## Make a toy megalist
megalist <- new.mainparam.list()
megalist <- set.commonparams(megalist)
megalist <- set.specparams.rmetasim(megalist)
megalist <- set.scenarios(megalist)
megalist$simwrap <- rmetasim.sim.wrap

## Make a toy popgen analysis function
generic.popgen.function <- function(){
  a_vector <- c("stat1"=abs(floor(rnorm(1,1,10))),
                "stat2"=runif(1),
                "stat3"=rnorm(1), 
                "stat4"=rbinom(1,1,.5))
  return(a_vector)
}
megalist$analyses_to_run <- generic.popgen.function




#############################
#### Run the simulations ####
#############################

sim.iterator <- function(megalist){
  ## Number of Scenarios
  num_scenarios <- nrow(megalist$scenarios_list)
  ## Number of Reps
  num_reps <- megalist$common_params$num_reps
  ## Define a "results_from_analysis" list
  megalist$results_from_analysis <-
    as.data.frame(do.call(rbind, lapply(1:num_scenarios, function(scenario) {
      megalist$current_scenario <- scenario
      do.call(rbind, lapply(1:num_reps, function(rep) {
         megalist$current_replicate <- rep
         megalist <- megalist$sim.func(megalist)
         megalist <- megalist$analysis.func(megalist)
         c(scenario = scenario, megalist$rep.analysis)
      }))
    })))
  return(megalist)
}


sim.iterator(megalist)
