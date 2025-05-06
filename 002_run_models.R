rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)

# Change depending on your operating system
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")

# Define controller class
source("Controller_Class_Def.R")

# Load controller
project_name <- "Multiverse Workshop"
controller <- readRDS(file.path("Results",project_name,"controller.RDS"))
controller$set_script("002")
controller$init_libraries()

end_main_loop <- FALSE
while(end_main_loop == FALSE){
  options <- list(
    #001 parameters
    age_minimum_cutoffs = controller$get_current_spec("age_minimum_cutoffs"),
    cvd_history = controller$get_current_spec("cvd_history"),
    gender = controller$get_current_spec("gender"),

    #002 parameters
    survey_weighting = controller$get_current_spec("survey_weighting"),
    model_forms = controller$get_current_spec("model_forms"),
    AGE = controller$get_current_spec("AGE"),
    SEX = controller$get_current_spec("SEX"),
    RACE = controller$get_current_spec("RACE"),
    EXERCISE = controller$get_current_spec("EXERCISE"),
    bsIter = controller$get_current_spec("bsIter")
  )

  #DESCRIBE HOW THIS WORKS:
  data <- controller$load_project_data("sample.RDS")

  #Handle bootstrapping
  if(!is.na(options$bsIter)){
    set.seed(options$bsIter)
    data <- sample_n(data, size=nrow(data), replace=TRUE)
  }

  #Create formula
  covs <- c("marital_status","income","insurance","generalhealth") #could add BMI
  if(options$AGE==1){
    covs <- c(covs,"age_imputed")
  }
  if(options$RACE==1){
    covs <- c(covs,"race")
  }
  if(options$SEX==1){
    covs <- c(covs,"female")
  }
  if(options$EXERCISE==1){
    covs <- c(covs,"exercise")
  }
  formula <- "hypertension ~ alcohol_niaaa"
  formula <- paste0(formula," + ",paste0(covs,collapse=" + "))

  #Handle model form
  if(options$model_forms == "interaction"){
    formula <- paste0(formula," + age_imputed*alcohol_niaaa")
  }else if(options$model_forms == "nonlinear"){
    formula <- paste0(formula," + age_imputed^2")
  }

  #Make weights vector (or all 1)
  if(options$survey_weighting==TRUE){
    weights <- data$surveyweights
  }else{
    weights <- rep(1,nrow(data))
  }

  ## TO DO: NEED TO SET ALCOHOL REFERENCE TO LIGHT-TO-MOD

  #Run model
  model <- glm(formula=as.formula(formula),
               data=data,
               family=binomial())

  #Save results
  ## Discuss whether to do in one file or multiple
  ## Multiple: better for parallel and more robust if errors occur
  ## Single: Runs faster, get one output data set that doesn't need post-processing before plotting
  estimates <- summary(model)$coef
  controller$save_project_data(estimates,"estimates.RDS")

  #Walk through adding another output:
  # CIs <- confint(model)
  # controller$save_project_data(estimates,"cis.RDS")

  if(is.na(controller$next_spec())){
    end_main_loop <- TRUE
  }
}