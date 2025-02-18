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
controller$set_script("003")
estimates <- controller$load_project_data("estimates_compiled.RDS")

#Paired specification plots

#Heatmap points and SEs

#Volcano plots (log se on y axis against estimate on x axis)

#Tables
# Show how to make a table 1 for each of the datasets output by 001