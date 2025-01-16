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
  instructions =file.path(project_dir,"Instructions")
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
controller$set_script("master")
#controller$validate_all_specs()

saveRDS(controller, file.path(controller$dirs$results,
                              controller$project_name,
                              "controller.RDS"))
