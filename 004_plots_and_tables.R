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
estimates <- controller$load_project_data("estimates_compiled.RDS") %>%
  select(-c(`z value`, `Pr(>|z|)`,"param_combo_id"))
ests_list <- list()
for(coef in unique(estimates$coef)){
  ests_list[[coef]] <- estimates %>%
    filter(coef == !!coef)
}

#Paired specification plots - estimate w/ vs estimate w/out the specification
specs <- colnames(estimates)[3:11]
for(spec in specs){
  print(spec)
  print(unique(ests_list$`alcohol_niaaalight-to-moderate`[[spec]]))
}
#Also loop over alcohol levels

d1 <- ests_list$`alcohol_niaaalight-to-moderate` %>% filter(EXERCISE == "y") %>%
  select(-c(`Std. Error`,EXERCISE)) %>%
  rename(Estimate_y = Estimate)
d0 <- ests_list$`alcohol_niaaalight-to-moderate` %>% filter(EXERCISE == "n") %>%
  select(-c(`Std. Error`,EXERCISE)) %>%
  rename(Estimate_n = Estimate)
d <- left_join(d1,d0) %>% filter(!is.na(Estimate_y),!is.na(Estimate_n))

p <- ggplot(d,aes(x=Estimate_n,y=Estimate_y)) +
  geom_point()
p

#Heatmap points and SEs: estimate is x axis, log(se) is y axis
# Don't need to do per spec.
ests_list$`alcohol_niaaalight-to-moderate` %>%
  ggplot(aes(x = exp(Estimate), y = log(`Std. Error`))) + geom_hex()

#Volcano plots (log se on y axis against estimate on x axis)
# and color based on spec
ests_list$`alcohol_niaaalight-to-moderate` %>%
  ggplot(aes(x = exp(Estimate),
             y = log(`Std. Error`),
             color = EXERCISE)) +
  geom_point()

# MAYBE: Show how to make a table 1 for each of the datasets output by 001

#VoE estimate: relative HR: HR of 99th/HR of 1st percentile... range of p values, or ratio of 99/1st p value


#Mean differences in estimate by spec:
# Within pairs, how did it change the estimate, and range: min change it had vs largest change it had on the pt est
