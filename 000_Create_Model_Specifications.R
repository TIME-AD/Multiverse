rm(list=ls())
library(glue)
library(tidyverse)
library(dplyr)

# Define controller class
source("Controller_Class_Def.R")
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Directories ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")
dirs <- list(
  instructions =file.path(project_dir,"Instructions"),
  data =file.path(project_dir,"Data"),
  results =file.path(project_dir,"Results")
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Read in input files ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inputs <- dget(file.path(dirs$instructions,"instructions.R"))()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the list of analysis options for the project ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
elig_criteria <- expand.grid(
  age_minimum_cutoffs = inputs$elig_criteria$age_minimum_cutoffs,
  cvd_history = inputs$elig_criteria$cvd_history,
  drug_use = inputs$elig_criteria$drug_use
)

model_info <- expand.grid(
  survey_weighting = inputs$survey_weighting,
  model_forms = inputs$model_forms
)

covariate_sets <- expand.grid(
  AGE = inputs$covariate_sets$AGE,
  SEX = inputs$covariate_sets$SEX,
  RACE = inputs$covariate_sets$RACE,
  EXERCISE = inputs$covariate_sets$EXERCISE
)

bootstrap_ids <- expand.grid(
  bsIter = inputs$bsIter)

df <- cross_join(elig_criteria,model_info) %>%
  cross_join(covariate_sets) %>%
  cross_join(bootstrap_ids) %>%
  arrange()

#Save object in its initial state
controller <- Controller$new(df,inputs,project_dir) #Calls Controller definition's "initialize" method
controller$set_script("000")
#controller$validate_all_specs()

# TO DO: Validate that all necessary packages are installed
#controller$install_libraries()

#Create a local copy of the brfss data in the project directory
brfss_data <- readRDS(file.path("Data/cleaned_brfss.RDS"))
controller$save_project_data(brfss_data, "cleaned_brfss.RDS")

saveRDS(controller, file.path(controller$dirs$results,
                              controller$project_name,
                              "controller.RDS"))

