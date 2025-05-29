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
controller$set_script("001")
controller$init_libraries()

#This script will loop over the rows of this instructions table.
# Each row has a different combination of parameters, and will create one analytic data set
#   age_minimum_cutoffs: the created data set will be restricted to participants of this age or older
#   cvd_history: the created data set will be restricted to participants with this cvd history
#   drug_use: the created data set will be restricted to participants with this history of drug use
controller$project_data_lookups$`000`

#Load the project data
brfss_data <- controller$load_project_data("cleaned_brfss.RDS")

#Main loop
end_main_loop <- FALSE
while(end_main_loop == FALSE){
  options <- list(
    age_minimum_cutoffs = controller$get_current_spec("age_minimum_cutoffs"),
    cvd_history = controller$get_current_spec("cvd_history"),
    gender = controller$get_current_spec("gender")
  )

  analytic_data <- brfss_data %>%
    filter(age_imputed >= options$age_minimum_cutoffs,
           cvd_history == as.numeric(options$cvd_history))

  #Optionally filter by gender unless options$gender == "all"
  if(options$gender == "women"){
    analytic_data <- brfss_data %>%
      filter(age_imputed >= options$age_minimum_cutoffs,
             cvd_history == as.numeric(options$cvd_history))
  }else if(options$gender == "men"){
    analytic_data <- brfss_data %>%
      filter(age_imputed >= options$age_minimum_cutoffs,
             cvd_history == as.numeric(options$cvd_history))
  }

  controller$save_project_data(analytic_data,"sample.RDS")

  if(is.na(controller$next_spec())){
    end_main_loop <- TRUE
  }
}
