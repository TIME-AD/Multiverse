rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)
library(rlist)

# Change depending on your operating system
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")

# Define controller class
source("Controller_Class_Def.R")

# Load controller
project_name <- "Multiverse Workshop"
controller <- readRDS(file.path("Results",project_name,"controller.RDS"))
controller$init_libraries()

#Load outputs
estimates <- list()
controller$set_script("002")
end_main_loop <- FALSE
test <- FALSE
while(end_main_loop == FALSE){
  #TO DO: Aggregate bootstraps

  estimates[[length(estimates)+1]] <- controller$load_project_data("estimates.RDS") %>%
    cbind(controller$get_current_row())

  estimates[[length(estimates)]]$coef <- rownames(estimates[[length(estimates)]])

  rownames(estimates[[length(estimates)]]) <- NULL
  if(is.na(controller$next_spec()) | (test == TRUE & length(estimates) >= 100)){
    end_main_loop <- TRUE
  }
}
estimates <- list.rbind(estimates)

controller$set_script("003")
controller$save_project_data(estimates,"estimates_compiled.RDS")

#estimates <- controller$load_project_data("estimates_compiled.RDS")
estimates_effects <- estimates %>%
  filter(is.na(bsIter))
controller$save_project_data(estimates_bsAgg,"estimates_effects.RDS")

estimates_bsAgg <- estimates %>%
  filter(!is.na(bsIter)) %>%
  select(-c("z value","param_combo_id","bsIter")) %>%
  group_by(age_minimum_cutoffs,
           cvd_history,gender,survey_weighting,
           model_forms,AGE,RACE,
           SEX,EXERCISE,coef) %>%
  summarise(mean_est = mean(Estimate),
            sd_est = sd(Estimate),
            mean_sd = mean(`Std. Error`))

#Save compiled estimates
controller$save_project_data(estimates_bsAgg,"estimates_compiled_bsAgg.RDS")
#saveRDS(estimates,"estimates.RDS")