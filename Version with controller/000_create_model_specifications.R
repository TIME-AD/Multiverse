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
  instructions = file.path(project_dir,"Instructions"),
  data = file.path(project_dir,"Data"),
  results = file.path(project_dir,"Results")
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Read in input files ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inputs <- dget(file.path(dirs$instructions,"instructions.R"))()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the list of analysis options for the project ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
elig_criteria <- expand.grid(
  age_minimum_cutoffs = names(inputs$age_minimum_cutoffs),
  cvd_history = names(inputs$cvd_history),
  gender = names(inputs$gender)
)

model_info <- expand.grid(
  survey_weighting = names(inputs$survey_weighting),
  model_forms = names(inputs$model_forms)
)

covariate_sets <- expand.grid(
  AGE = names(inputs$AGE),
  SEX = names(inputs$SEX),
  RACE = names(inputs$RACE),
  EXERCISE = names(inputs$EXERCISE)
)

df <- cross_join(elig_criteria,model_info) %>%
  cross_join(covariate_sets) %>%
  arrange()

#Drop sex adjustment in sex-stratified analyses
df <- df %>%
  filter(gender == "all" | (gender == "women" & SEX == "n") | (gender == "men" & SEX == "n"))
table(df$gender,df$SEX)

#Save object in its initial state
controller <- Controller$new(df,inputs,project_dir) #Calls Controller definition's "initialize" method
controller$set_script("000")

#Create a local copy of the brfss data in the project directory
brfss_data <- readRDS(file.path("Data/cleaned_brfss.RDS"))
controller$save_project_data(brfss_data, "cleaned_brfss.RDS")

saveRDS(controller, file.path(controller$dirs$results,
                              controller$project_name,
                              "controller.RDS"))

