# Purpose: This script compiled coefficients from all models into one place for ease of use. 

rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)
library(rlist)

# Set up directory (change depending on your operating system)
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")

# Define controller class
source("Controller_Class_Def.R")

# Load controller
project_name <- "Multiverse Workshop"
controller <- readRDS(file.path("Results",project_name,"controller.RDS"))
controller$init_libraries()

# Create empty list to store estimates
estimates <- list()
controller$set_script("002")
end_main_loop <- FALSE
while(end_main_loop == FALSE){
  #Load outputs
  estimates[[length(estimates)+1]] <- controller$load_project_data("estimates.RDS") %>%
    cbind(controller$get_current_row())

  estimates[[length(estimates)]]$coef <- rownames(estimates[[length(estimates)]])
# Remove row names 
  rownames(estimates[[length(estimates)]]) <- NULL
  if(is.na(controller$next_spec())){
    end_main_loop <- TRUE
  }
}
# Bind list elements by row and save
estimates <- list.rbind(estimates)

controller$set_script("003")
controller$save_project_data(estimates,"estimates_compiled.RDS")
