# Purpose: Create directions for multiverse analysis from instructions document (~/Github/TIME-AD/Multiverse/Instructions/). 
# This identifies the unique combination of all decisions and the final list of models that need to be run. 
# Each following script calls the output of this script. 
rm(list=ls())
library(glue)
library(tidyverse)
library(dplyr)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Directories ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set up environment 
root_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")
dirs <- list(
  instructions = file.path(root_dir,"Instructions"),
  data = file.path(root_dir,"Data"),
  results = file.path(root_dir,"Results")
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Read in input files (instructions document)----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inputs <- dget(file.path(dirs$instructions,"instructions.R"))()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the list of analysis options for the project ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Identify unique combinations of eligibility criteria decisions
elig_criteria <- expand.grid(
  age_minimum_cutoffs = names(inputs$age_minimum_cutoffs),
  cvd_history = names(inputs$cvd_history),
  gender = names(inputs$gender)
)

# Identify unique combinations of model form decisions
model_info <- expand.grid(
  survey_weighting = names(inputs$survey_weighting),
  model_forms = names(inputs$model_forms)
)

# Identify unique combinations of covariate sets
covariate_sets <- expand.grid(
  AGE = names(inputs$AGE),
  SEX = names(inputs$SEX),
  RACE = names(inputs$RACE),
  EXERCISE = names(inputs$EXERCISE)
)

# Combine all unique decisions for final list of all unique models 
df <- cross_join(elig_criteria,model_info) %>%
  cross_join(covariate_sets) %>%
  arrange()

# Models may have decisions that are mutually exclusive. Here, you can't stratify by sex AND adjust for sex. 
#Drop sex adjustment in sex-stratified analyses
df <- df %>%
  filter(gender == "all" | (gender == "women" & SEX == "n") | (gender == "men" & SEX == "n"))
table(df$gender,df$SEX)

#Create a local copy of the brfss data in the project directory
brfss_data <- readRDS(file.path("Data/cleaned_brfss.RDS"))

#Save all of this info as a single object
directions <- list(
  instructions = inputs,
  specifications = df,
  data = brfss_data,
  dirs = dirs
)

#Set up directory structure
##Create results folder if it doesn't exist
if (!dir.exists(dirs$results)) {
  dir.create(dirs$results)
}

#Create project subfolder
if(!dir.exists(file.path(dirs$results,inputs$project$name))){
  dir.create(file.path(dirs$results,inputs$project$name))
}else{
  cat(paste0("Warning: A project named '",inputs$project$name,"' already exists, results may be overwritten.\n"))
}

#Create subfolders to hold results from each script
if(length(unique(names(inputs$scripts))) != length(names(inputs$scripts))){
  stop("Error: duplicate script keys exist in instructions file")
}
for(script_name in names(inputs$scripts)){
  dir.create(file.path(dirs$results,inputs$project$name,script_name),showWarnings = FALSE)
}

#Save directions
directions_path <- file.path(dirs$results,inputs$project$name,"000","directions.RDS")
saveRDS(directions,directions_path)
