#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Basic Example of Code for VoE/Model Specification Analysis
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Purpose: (Simplified) Example code for implementing a model specification analysis;
# First create a grid of specifications to iterate over. Second, apply different
# specifications in a loop.
# Sections of this script can be separated into different scripts and modified
# for different types of specifications.
# Created 3/25/2024
#
# Authored by:
# Erin Ferguson, MPH @ UCSF; erin.ferguson@ucsf.edu
# Scott Zimmerman, MPH @ UCSF; scott.zimmerman@ucsf.edu
#
# Based on a MELODEM presentation: https://drive.google.com/file/d/1Vuc7s0RWibQEZdFvT3yAdaK8hkWJn_Mm/view
#
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set up of any packages needed  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)
# Change depending on your operating system
root <- "Q"
files_dir= file.path(paste0(root,":/Files"))
project_dir = file.path(files_dir,"Analyses/Model Specification")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create list of specifications of interest ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
specs <- list(
  # Create a saving structure where results will save to project + subfolder
  # This may be important if you have multiple scripts
  # For example, you can first run specifications to create your cohort and save to folder A
  # and then run models that will save to folder B.
  project = list(
    name = "Name of Project"
  ),
  results_locations = list(
    # Change to be the where results from each script should save
    # Example above, create cohort with specifications
    "example_create_cohort.RDS" = "A",

    # Run covariate specification models on cohort
    "example_run_models.RDS" = "B"
  ),
  # This is one way we can make our code more efficient, explained at the end of this
  # script.
  scripts = list(
    "example_create_cohort" = list(
      param_combs = c("burn_in_length",
                      "match_cohort")
    ),
    "example_run_models" = list(
      param_combs = c("burn_in_length",
                      "match_cohort",
                      "cox"))),
  # Examples of some specifications we used:
  # Burn in/run-in period
  burn_in_length = list(
    years_4 = 4,
    years_0 = 0
  ),
  # Which cohort we use (in Kaiser)
  match_cohort = list(
    "Full"="Full",
    "Survey"="Survey"
  )
)

# Example for how to iterate over covariates
# In this example, different cohorts have different covariates. This can be
# simplified for the use of just one cohort
Full = expand.grid.df(expand.grid(list(
  # Any covariates you want to change (here: depression, head injury, diabetes)
  HX_MDD = c(0,1),
  HX_HEAD_INJ = c(0,1),
  HX_DIABETES = c(0,1))),
  # Any covariates you always want to adjust for
  data.frame(age = 1,
             RACE_CAT = 1,
             SEX_MALE = 1),
  unique=TRUE)
# Survey
Survey = expand.grid.df(expand.grid(list(
  # Any covariates you want to change (here: education and income)
  Education = c(0,1),
  Income = c(0,1))),
  # Any covariates you always want to adjust for
  data.frame(age = 1,
             RACE_CAT = 1,
             SEX_MALE = 1),
  unique=TRUE)

expand.covariates <- function(x){
  names(x)[x==1]
}
specs$cox$useModels = list(
  "Full" = apply(Full,1,expand.covariates),
  "Survey" = apply(Full,1,expand.covariates))
rm(Full, Survey)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Expand specifications into a grid ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Select all your (non-covariate) specifications and expand grid
df <- expand.grid(
  burn_in_length= names(specs$burn_in_length),
  match_cohort = names(specs$match_cohort)
)
# Add in covariates
cox_model_opts <- data.frame(match_cohort = character(),
                             cox = character())
for (dataset in names(specs$cox$useModels)) {
  temp <- data.frame(match_cohort = dataset,
                     cox = names(specs$cox$useModels[[dataset]]))
  cox_model_opts <- rbind(cox_model_opts, temp)
}
df <- left_join(df,cox_model_opts)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create cohort with specifications in loop ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load your whole (unmanipulated) dataset
data_raw <- readRDS("yourdata.RDS")

for(current_spec in 1:nrow(df)){
  # Look up specs from the instructions grid using the key in the current row
  opts <- list(
    burn_in_length=specs$burn_in_length[[df[current_spec, "burn_in_length"]]],
    match_cohort=specs$match_cohort[[df[current_spec, "match_cohort"]]]
  )

  # Example of specification: run-in period
  data_spec <- data_raw %>%
    filter(enrollment_start <= baseline_date %m-% years(opts$burn_in_length))
  # Example of specification: cohort used
  data_spec <- data_spec %>%
    filter(cohort == opts$match_cohort)

  # Need to save data for spec
  fileName <- paste0(current_spec, "_example_create_cohort.RDS")
  outPath <- file.path(project_dir,specs$project[["name"]],specs$results_locations[["example_create_cohort.RDS"]],fileName)
  saveRDS(data_spec, outPath)
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Run models with specifications ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Depending on the complexity of your research question, the for loop below (lines 156- 175)
# can be combined with the for loop above (lines 131-149)
for(current_spec in 1:nrow(df)){
  # Read in data for current spec from previous for loop
  fileName_read <- paste0(current_spec, "_example_create_cohort.RDS")
  readpath <- file.path(project_dir,specs$project[["name"]],specs$results_locations[["example_create_cohort.RDS"]],fileName_read)
  cohort_data <- readRDS(readpath)
  # Pull options for this spec
  opts <- list(
    match_cohort=specs$match_cohort[[df[current_spec, "match_cohort"]]],
    cox_model = df[current_spec, "cox"]
  )
  # Identify covariates
  covariates <- specs$cox$useModels[[opts$match_cohort]][[opts$cox_model]]
  temp <- glue("{paste0(covariates, collapse = ' + ')}" )
  # Run cox model (can be modified to model of interest)
  cox_output <- coxph(as.formula(paste0("Surv(FU_YEARS,OUTCOME_EVENT) ~", temp)),
                      data = dataset)
  fileName <- paste0(current_spec, "_example_run_models.RDS")
  outPath <- file.path(project_dir,specs$project[["name"]],specs$results_locations[["example_run_models.RDS"]],fileName)
  saveRDS(cox_output, outPath)
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Bonus: Increase Your Code Efficiency ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# In the code above, your code loops over a grid of all your model specifications. However,
# you might have noticed that you are running the same code and saving the same file multiple times.
# For example, if ran in full, 1_example_run_models.RDS to 8_example_run_models.RDS would be identical.
# You can increase the efficiency of your code by only running *unique* combinations of specifications
# at each step.
#
# This code can be confusing to implement, but it will speed up your code & save on storage!
#
#
# For example, in the "Create cohort with specifications in loop" you only need 4 unique
# datasets based off of your specifications
expand.grid(unique(df$burn_in_length), unique(df$match_cohort))

# In order to deal with this, you can index which parameters you need in each script and run only through those
# specifications.
specs$lookups <- list()
for(script_name in names(specs$scripts)){
  # For each script, look up at specifications you use
  script_params <- specs$scripts[[script_name]]$param_combs
  if(length(script_params)){
    # Pull unique combinations of these parameters
    specs$lookups[[script_name]] <- df %>%
      select(all_of(script_params)) %>%
      unique() %>%
      # Create NEW id for the combination of these unique values
      mutate(param_combo_id = row_number(),.before=everything())
    rownames(specs$lookups[[script_name]]) <- NULL
  }
}

# Then, when you run the cohort script you will run through only 4 lines instead of 32!
current_spec <- 1
while(end_main_loop == FALSE){
  # Specs for the current row
  opts <- list(
    burn_in_length=specs$burn_in_length[[specs$lookups$example_create_cohort[current_spec, "burn_in_length"]]],
    match_cohort=specs$match_cohort[[specs$lookups$example_create_cohort[current_spec, "match_cohort"]]]
  )

  # Example of specification: run-in period
  data_spec <- data_raw %>%
    filter(enrollment_start <= baseline_date %m-% years(opts$burn_in_length))
  # Example of specification: cohort used
  data_spec <- data_spec %>%
    filter(cohort == opts$match_cohort)

  # Need to save data for spec
  fileName <- paste0(current_spec, "_example_create_cohort.RDS")
  outPath <- file.path(project_dir,specs$project[["name"]],specs$results_locations[["example_create_cohort.RDS"]],fileName)
  saveRDS(data_spec, outPath)

  # Further iteration
  current_spec <- current_spec + 1
  if (current_spec == nrow(specs$lookups$example_create_cohort)) {
    end_main_loop == TRUE
  }
}

# However, this now means when you read in this data later you will need to look up this unique combination id
# i.e. which dataset does row 27 of df need to load to run cox models

# You can do this by selecting for unique parameters and matching it to this look-up we created in the prior step
# Let's pretend we are running cox models from our condensed script
current_spec <- 1
end_main_loop <- FALSE
while(end_main_loop == FALSE){
  # Find the unique specification id corresponding to the data we need to load
  unique_combinations <- df[current_spec,] %>% select(burn_in_length, match_cohort) %>%
    left_join(specs$lookups$example_create_cohort)
  # Read in data from previous spec
  fileName_read <- paste0(unique_combinations$param_combo_id, "_example_create_cohort.RDS")
  readpath <- file.path(project_dir,specs$project[["name"]],specs$results_locations[["example_create_cohort.RDS"]],fileName_read)
  cohort_data <- readRDS(readpath)

  # Then complete rest of script from above.
}




