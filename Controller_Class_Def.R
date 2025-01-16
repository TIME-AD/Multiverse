
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create project controller object ----
# The controller object is responsible for:
#   -Managing directories
#   -Managing libraries
#   -Iterating through model specifications
#   -Pulling parameters for the current iteration
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Controller <- setRefClass("Controller",
                          fields=c("inputs",
                                   "project_name",
                                   "modelspecs",
                                   "i",
                                   "dirs",
                                   "fr",
                                   "project_data_lookups",
                                   "current_spec",
                                   "current_script_key"
                          ),
                          methods = list(
                            initialize = function(ms, ins, rootDir){
                              #Analysis option iteration
                              modelspecs <<- ms
                              inputs  <<- ins

                              i <<- 1
                              #Directory structure
                              init_dirs(rootDir)
                              create_project_directories()

                            },
                            set_script = function(script_key){
                              #Initialize the lookup for the script currently running
                              # Call this at the beginning of each script
                              current_script_key <<- script_key
                              i <<- 1
                              current_spec <<- project_data_lookups[[current_script_key]][i,]
                            },
                            init_libraries = function(){
                              library(tidyverse)
                              library(lubridate)
                              library(Rcpp)
                              library(clock)
                              library(gdata)
                              library(roxygen2)
                              library(metafor)
                              library(rlist)
                              library(glue)
                              library(Hmisc)
                              library(survival)
                              library(survminer)
                              library(broom)
                              library(rms)
                              library(table1)
                              library(missForest)
                              library(furrr)
                              library(h2o)
                              library(doParallel)
                              library(foreach)
                              library(parglm)
                              library(glmnet)
                              library(dplyr)
                              library(purrr)
                              library(personalized)
                              library(openxlsx)
                              library(parallel)
                              library(stringr)
                            },
                            init_dirs = function(root){
                              #Initialize or reinitialize dirs and file reader
                              dirs <<- list(
                                utility = file.path(root, "Utility"),
                                dataIn = file.path(root, "Input Data"),
                                functions = file.path(root,"functions"),
                                instructions = file.path(root,"Instructions"),
                                results = file.path(root, "Results")
                              )

                            },
                            create_project_directories = function(){
                              #Create results folder if it doesn't exist
                              if (!dir.exists(dirs$results)) {
                                dir.create(dirs$results)
                              }

                              #Create project subfolder
                              project_name <<- inputs$project$name
                              if(!dir.exists(file.path(dirs$results,project_name))){
                                dir.create(file.path(dirs$results,project_name))
                              }else{
                                cat(paste0("Warning: A project named '",project_name,"' already exists, results may be overwritten.\n"))
                              }

                              #Create subfolders to hold results from each script
                              if(length(unique(names(inputs$scripts))) != length(names(inputs$scripts))){
                                stop("Error: duplicate script keys exist in instructions file")
                              }
                              for(script_name in names(inputs$scripts)){
                                dir.create(file.path(dirs$results,project_name,script_name),showWarnings = FALSE)
                              }

                              #Set up index tables to look up results based on unique combinations of parameters
                              lookups <- list()
                              for(script_name in names(inputs$scripts)){
                                script_params <- inputs$scripts[[script_name]]$param_combs
                                if(length(script_params)){
                                  lookups[[script_name]] <- get_unique_spec_combs(script_params) %>%
                                    mutate(param_combo_id = row_number(),.before=everything())
                                  rownames(lookups[[script_name]]) <- NULL
                                }
                              }

                              lookups$master <- modelspecs

                              project_data_lookups <<- lookups
                            },
                            get_unique_spec_combs = function(params){
                              result <- modelspecs %>%
                                select(all_of(params)) %>%
                                unique()
                              return(result)
                            },
                            next_spec = function(){
                              # Iterate to the next analysis specification for the current script key, otherwise
                              #  return NA, indicating that analysis is finished
                              if(i+1 <= nrow(project_data_lookups[[current_script_key]])){
                                i <<- i + 1
                                current_spec <<- project_data_lookups[[current_script_key]][i,]
                              }else{
                                i <<- NA
                              }

                              return(i)
                            },

                            set_spec = function(i){
                              if(i <= nrow(project_data_lookups[[current_script_key]])){
                                i <<- i + 1
                                current_spec <<- project_data_lookups[[current_script_key]][i,]
                              }else{
                                print(paste0("Invalid index: ",i))
                              }
                            },

                            get_current_row = function(){
                              return(current_spec)
                            },

                            get_current_spec = function(param){
                              if(param ==  "param_combo_id"){
                                return(current_spec[[param]])
                              }

                              return(res)
                            },
                            save_project_data = function(data,
                                                         fileName,
                                                         opts = list(row.names=FALSE)){

                              #Determine what subfolder to save to
                              subfolder <- inputs$results_locations[[fileName]]
                              if(subfolder %in% names(project_data_lookups)){
                                #Determine lookup index
                                lookup_index <- get_current_spec("param_combo_id")

                                #Prefix the file name with the lookup index
                                fileName <- paste0(lookup_index,"_",fileName)
                              }

                              #Output path
                              outPath <- file.path(dirs$results,project_name,current_script_key,fileName)

                              cat(paste0("Saving ",outPath, " - "))
                              #Save
                              suffix <- str_split(fileName,"\\.")[[1]][[2]]
                              if(suffix == "RDS" | suffix == "rds"){
                                saveRDS(data,outPath)
                              }else if(suffix == "csv"){
                                write.csv(data,outPath,row.names = opts$row.names)
                              }else if(suffix == "R"){
                                dput(data,outPath)
                              }else{
                                stop(paste0(fileName," file type not handled"))
                              }
                              cat("Done\n")
                            },
                            load_project_data = function(fileName,
                                                         #If desired, use a specific param combo id
                                                         param_combo_id = NULL,
                                                         #Or a row from the output of get_template_row(script_key)
                                                         #Filled in with the desired specs
                                                         param_combo  = NULL
                            ){

                              #Determine what subfolder to load from
                              script_key <- inputs$results_locations[[fileName]]

                              if(script_key %in% names(project_data_lookups)){
                                #Pull the combination of the parameters used in the saving script that we want to load
                                if(is.null(param_combo_id)){
                                  if(is.null(param_combo)){
                                    param_combo <- get_current_row()
                                  }else{

                                  }
                                  saving_script_row <- param_combo %>%
                                    select(inputs$scripts[[script_key]]$param_combs) %>%
                                    left_join(project_data_lookups[[script_key]])

                                  if(nrow(saving_script_row) > 1){
                                    stop("Error: pulling parameter combination from saving script yielded multiple rows")
                                  }

                                  param_combo_id <- as.numeric(saving_script_row$param_combo_id)
                                }

                                #Prefix the file name with the lookup index (param_combo_id)
                                fileName <- paste0(param_combo_id,"_",fileName)
                              }

                              #Input path
                              inPath <- file.path(dirs$results,project_name,script_key,fileName)
                              cat(paste0("Loading ",inPath, " - "))

                              #Load
                              suffix <- str_split(fileName,"\\.")[[1]][[2]]
                              if(suffix == "RDS" | suffix == "rds"){
                                data <- readRDS(inPath)
                              }else if(suffix == "csv"){
                                data <- read.csv(inPath)
                              }else if(suffix == "R"){
                                data <- dget(inPath)
                              }else{
                                stop(paste0(fileName," file type not handled"))
                              }
                              cat("Done\n")

                              return(data)
                            },
                            get_template_row  =  function(script_key){
                              if(script_key %in% names(project_data_lookups)){
                                template_row <- project_data_lookups[[script_key]] %>% select (-param_combo_id) %>% .[1,]
                                template_row[1,colnames(template_row)] <- NA
                                return(template_row)
                              }else{
                                stop(paste0("Error in get_template_row, script_key unknown: script_key='",script_key,"'"))
                              }
                            },
                            create_template_row = function(script_key,values){
                              template_row <- get_template_row(script_key)
                              template_row[1,] <- values
                              return(template_row)
                            }#,
                            # load_helpers = function(scriptName){
                            #   h <- dget(file.path(dirs$functions,scriptName))()
                            #   return(h)
                            # },
                            # validate_current_specs =   function(){
                            # },
                            # validate_all_specs = function(){
                            #   cat("validating specs")
                            #   initial_i <- i
                            #   i <<- 0
                            #   while(!is.na(next_spec())){
                            #     validate_current_specs()
                            #   }
                            #   i <<- initial_i
                            #   cat(" - passed\n")
                            # }
                          )
)