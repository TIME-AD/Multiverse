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

#Make a paired spec plot for exercise
d1 <- ests_list$`alcohol_niaaalight-to-moderate` %>% filter(EXERCISE == "y") %>%
  select(-c(`Std. Error`,EXERCISE)) %>%
  rename(Estimate_y = Estimate)
d0 <- ests_list$`alcohol_niaaalight-to-moderate` %>% filter(EXERCISE == "n") %>%
  select(-c(`Std. Error`,EXERCISE)) %>%
  rename(Estimate_n = Estimate)
d <- left_join(d1,d0) %>%
  filter(!is.na(Estimate_y),!is.na(Estimate_n))

controller$set_script("004")
p_spec_exercise <- ggplot(d,aes(x=Estimate_n,
                  y=Estimate_y)) +
  geom_point() +
  ggtitle("Comparison of inclusion vs exclusion of exercise as \na covariate, comparing light-to-moderate to non-drinkers")
p_spec_exercise
controller$save_project_data(p_spec_exercise,"spec_plot_EXERCISE.png")

#Heatmap points and SEs: estimate is x axis, log(se) is y axis
# Don't need to do per spec.
p_heatmap <- ests_list$`alcohol_niaaalight-to-moderate` %>%
  ggplot(aes(x = exp(Estimate), y = log(`Std. Error`))) +
  geom_hex() +
  ggtitle("Heatmap summarizing the distribution of estimates across specifications")
p_heatmap

controller$save_project_data(p_heatmap,"heatmap.png")