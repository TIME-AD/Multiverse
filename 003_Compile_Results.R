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
while(end_main_loop == FALSE){
  estimates[[length(estimates)+1]] <- controller$load_project_data("estimates.RDS")
  if(is.na(controller$next_spec())){
    end_main_loop <- TRUE
  }
}
estimates <- list.rbind(estimates)


#Save compiled estimates
controller$set_script("003")
controller$save_project_data(estimates,"estimates_compiled.RDS")
#saveRDS(estimates,"estimates.RDS")