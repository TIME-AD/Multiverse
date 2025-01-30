#Download "2023 BRFSS Data (SAS Transport Format)" from https://www.cdc.gov/brfss/annual_data/annual_2023.html

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
controller$set_script("000")
controller$init_libraries()

brfss2023 <- read_xpt(file.path("Data","LLCP2023.XPT"))
brfss2023
