# Purpose: This script runs logistic regression models using unique covariate sets & functional forms from each 
# dataset created in "001_create_eligible_sample.R." 

rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)

# Change depending on your operating system
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")

# Load directions output by previous script (001)
project_name <- "Multiverse Workshop"
directions_path_in <- file.path(project_dir,"Results",project_name,"001","directions.RDS")
directions <- readRDS(directions_path_in)

#Helper function
get_param <- dget("h_get_param.R")(directions)

#Now we can loop over every row of directions$specifications for the analysis step
last_elig_sample_index <- 0
for(spec_row_index in 1:nrow(directions$specifications)){
  spec <- directions$specifications[spec_row_index,]

  #Loading is a slow operation, we can try to avoid excessive loading with this:
  if (last_elig_sample_index != spec$elig_sample_index){
    data_filename <- paste0("sample_", spec$elig_sample_index, ".RDS")
    print(paste0("Loading ",data_filename))

    data <- readRDS(file.path(directions$dirs$results,
                              directions$instructions$project$name,
                              "001",
                              data_filename))
  }

  #Create formula
  #Create formula from covariates. First, covariates we always adjust for: marital status, income, insurance, & general health 
  covs <- c("marital_status","income","insurance","generalhealth")

    # Add each of these variables, if specified 
  if(get_param(spec,"AGE")==1){
    covs <- c(covs,"age_imputed")
  }
  if(get_param(spec,"RACE")==1){
    covs <- c(covs,"race")
  }
  if(get_param(spec,"SEX")==1){
    covs <- c(covs,"female")
  }
  if(get_param(spec,"EXERCISE")==1){
    covs <- c(covs,"exercise")
  }
  formula <- "hypertension ~ alcohol_niaaa"
  formula <- paste0(formula," + ",paste0(covs,collapse=" + "))

  #Handle model form: add interaction, if specified 
  if(get_param(spec,"model_forms") == "interaction"){
    formula <- paste0(formula," + age_imputed*alcohol_niaaa")
  }
  #Handle model form: add non-linear age, if specified 
  else if(get_param(spec,"model_forms") == "nonlinear"){
    formula <- paste0(formula," + age_imputed^2")
  }

  #Make weights vector (or all 1 if no weighting indicated)
  if(get_param(spec,"survey_weighting")==TRUE){
    weights <- data$surveyweights
  }else{
    weights <- rep(1,nrow(data))
  }

  #Run logistic regression model from formula & data specified 
  model <- glm(formula=as.formula(formula),
               data=data,
               family=binomial())

  #Save results from this model: only coefficients for space
  estimates <- summary(model)$coef
  estimates_filename <- paste0("estimates_",spec_row_index,".RDS")
  print(paste0("Saving ",estimates_filename))
  saveRDS(estimates,
          file.path(directions$dirs$results,
                    directions$instructions$project$name,
                    "002",
                    estimates_filename))

  #Update last eligible sample index
  last_elig_sample_index <- spec$elig_sample_index
}
