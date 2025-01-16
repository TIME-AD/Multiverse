rm(list=ls())
library(glue)
library(tidyverse)
library(dplyr)

# Define controller class
source("Controller_Class_Def.R")

# Erin to fix this in the future because it isn't pulling all of the Cox models correctly,
# and if it does, the controller becomes so big nothing works anymore

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Directories ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
root <- "V"
files_dir= file.path(paste0(root,":/Files"))
project_dir = file.path(files_dir,"Analyses/Model Specification")
dirs <- list(
  instructions =file.path(project_dir,"Instructions")
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Read in input files ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inputs <- dget(file.path(dirs$instructions,"modelspec_inputs_scz_draft2_bs.R"))()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the list of analysis options for the project ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
df <- expand.grid(
  outcome_and_censoring_vars = names(inputs$outcome_and_censoring_vars),
  collapse_enrollments= names(inputs$collapse_enrollments),
  limit_first_enrollment= names(inputs$limit_first_enrollment),
  burn_in_length= names(inputs$burn_in_length),
  reenroll_burn_in_length = names(inputs$reenroll_burn_in_length),
  last_trial_date=names(inputs$last_trial_date),
  match_cohort = names(inputs$match_cohort),
  age_restriction=names(inputs$age_restriction),
  exclude_prev_mcimem=names(inputs$exclude_prev_mcimem),
  matchAPOE=names(inputs$matchAPOE),
  bsIter = inputs$bsIter
)

cox_model_opts <- unlist(inputs$cox$useModels)
cox_model_opts <- data.frame(useModels=names(cox_model_opts)) %>%
  separate(useModels,c("match_cohort","cox"),"\\.")

df <- left_join(df,cox_model_opts)

cox_df <- expand.grid(
  match_cohort = names(inputs$cox$useModels),
  first_yrs = "y",
  periods = names(inputs$cox$periods),
  trim_level = names(inputs$cox$trim_level),
  iptw  = names(inputs$iptw$useModels),
  use_predictors = names(inputs$cox$use_predictors),
  weight =  names(inputs$cox$weight),
  PS_adj =  names(inputs$cox$PS_adj),
  interactionDurationMonths = names(inputs$cox$interactionDurationMonths),
  APOEixn = names(inputs$cox$APOEixn),
  fuIntervalInteractions = c("n"),

  #Erin added 12/30/23
  #predictors = names(inputs$cox$predictors),
  stringsAsFactors = FALSE
) %>% arrange(match_cohort,first_yrs,periods,trim_level,iptw,weight,PS_adj) %>%
  mutate(iptw = case_when(
    weight == "n" & PS_adj == "n"~ NA_character_,
    TRUE ~ iptw)) %>%
  unique()

rownames(cox_df) <- NULL

df <- left_join(df, cox_df,relationship = "many-to-many")

#Remove anything that includes APOE interaction if it's not the genetic data set
df <- df %>% filter(!(APOEixn=="y" & match_cohort != "Genetic"))

#Remove anything that matching on APOE if it's not in the genetic data set
df <- df %>% filter(!(matchAPOE=="y" & match_cohort != "Genetic"))

#One row for FU interactions
df_tvIndicators <- df[5,]
df_tvIndicators[1,"fuIntervalInteractions"] <- "y"
df_tvIndicators[1,"first_yrs"] <- "n"
df <- rbind(df,df_tvIndicators)


df <- df %>% as.data.frame() %>% mutate(id = row_number(), .before=everything())


#Save object in its initial state
controller <- Controller$new(df,inputs,root)
controller$set_script("master")
controller$validate_all_specs()

#saveRDS(controller, file.path(dirs$instructions,"controller.RDS"))
saveRDS(controller, file.path(controller$dirs$results,
                              controller$project_name,
                              "controller.RDS"))
