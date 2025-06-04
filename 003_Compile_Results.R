rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)
library(rlist)

# Change depending on your operating system
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")

# Load directions output by previous script (001)
project_name <- "Multiverse Workshop"
directions_path_in <- file.path(project_dir,"Results",project_name,"001","directions.RDS")
directions <- readRDS(directions_path_in)

#Load estimates (output from script 002)
estimates <- list()
end_main_loop <- FALSE
for(spec_row_index in 1:nrow(directions$specifications)){
  spec <- directions$specifications[spec_row_index,]
  estimates_filename <- paste0("estimates_",spec_row_index,".RDS")
  estimates[[length(estimates)+1]] <- readRDS(file.path(directions$dirs$results,
                                                        directions$instructions$project$name,
                                                        "002",
                                                        estimates_filename)) %>%
    cbind(spec)

  #Move row names (coefficient names from the model summary) to a new column, and remove the row names
  estimates[[length(estimates)]]$coef <- rownames(estimates[[length(estimates)]])
  rownames(estimates[[length(estimates)]]) <- NULL
  estimates[[length(estimates)]]$spec_row_index <- spec_row_index
}
estimates <- list.rbind(estimates)

saveRDS(estimates,
        file.path(directions$dirs$results,
                  directions$instructions$project$name,
                  "003",
                  "estimates_compiled.RDS"))
