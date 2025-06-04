#Purpose: This script creates different datasets based off 3 eligibility criteria
#from the instructions document (1: age cutoffs, 2: sex stratification, 3: stratification 
#by CVD history). Each unique data file is saved to be used in next script. 

rm(list=ls())
library(reshape)
library(glue)
library(tidyverse)
library(dplyr)
library(lubridate)

# Change depending on your operating system
project_dir = setwd("~/Dropbox/Github/TIME-AD/Multiverse")

# Load directions output by previous script (000)
project_name <- "Multiverse Workshop"
directions_path_in <- file.path(project_dir,"Results",project_name,"000","directions.RDS")
directions <- readRDS(directions_path_in)

#This script will loop over the rows of the directions$specifications table.
# We're interested in 3 parameters of our specifications, combinations of which will create one analytic data set:
#   age_minimum_cutoffs: the created data set will be restricted to participants of this age or older
#   cvd_history: the created data set will be restricted to participants with this cvd history
#   gender: the created data set will include all participants, male participants, or female participants

#We want to loop over our instructions in order to make the datasets, however, if we make one per row of directions$specifications
#   we would be repeatiung ourselves, since there are 1152 different specifications...
directions$specifications %>% nrow()

#   but only 18 unique combinations of the parameters that are used to define the data sets
directions$specifications %>% dplyr::select(age_minimum_cutoffs, cvd_history, gender) %>% unique() %>% nrow()

# We can do this by making an index for each unique combination of these parameters
unique_elig_sample_specs <- directions$specifications %>%
  dplyr::select(age_minimum_cutoffs, cvd_history, gender) %>%
  unique() %>%
  mutate(elig_sample_index = row_number(), .before=everything())
rownames(unique_elig_sample_specs) <- NULL

#Then we can add this new index onto directions$specifications
directions$specifications <- directions$specifications %>% left_join(unique_elig_sample_specs)

#Update directions file with the new indices to results for the current script (001)
#    (Avoiding overwriting the results from the previous script can help in debugging)
directions_path_out <- file.path(project_dir,"Results",project_name,"001","directions.RDS")
saveRDS(directions,directions_path_out)

#Helper function
get_param <- dget("h_get_param.R")(directions)

# So now want to loop over only the combinations for eligible samples to create the 18 data sets
for(spec_row_index in 1:nrow(unique_elig_sample_specs)){
  spec <- unique_elig_sample_specs[spec_row_index,]

  # Filter cleaned dataset to include individuals above age cutoff
  analytic_data <- directions$data %>%
    filter(age_imputed >= get_param(spec,"age_minimum_cutoffs"),
           # Additionally restrict based off CVD history
           cvd_history == get_param(spec,"cvd_history"))

  #Optionally filter further by gender (note: not run if options$gender == "all")
  if(spec$gender == "women"){
    analytic_data <- analytic_data %>% filter(
      female == 1
    )
  }else if(spec$gender == "men"){
    analytic_data <- analytic_data %>% filter(
      female == 0
    )
  }

  #Save data, using the index to keep track of the data sets
  data_filename <- paste0("sample_",spec$elig_sample_index,".RDS")
  print(paste0("Saving ",data_filename))
  saveRDS(analytic_data,
          file.path(directions$dirs$results,
                    directions$instructions$project$name,
                    "001",
                    data_filename))
}
