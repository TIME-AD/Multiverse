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

#Load outputs
estimates <- readRDS(file.path(directions$dirs$results,
                     directions$instructions$project$name,
                     "003",
                     "estimates_compiled.RDS")) %>%
  select(-c(`z value`, `Pr(>|z|)`,"spec_row_index","elig_sample_index"))

ests_list <- list()
for(coef in unique(estimates$coef)){
  ests_list[[coef]] <- estimates %>%
    filter(coef == !!coef)
}

#Make a paired spec plot for exercise
d1 <- ests_list$`alcohol_niaaalight-to-moderate` %>% filter(EXERCISE == "y") %>%
  select(-c(`Std. Error`,EXERCISE)) %>%
  dplyr::rename(Estimate_y = Estimate)
d0 <- ests_list$`alcohol_niaaalight-to-moderate` %>% filter(EXERCISE == "n") %>%
  select(-c(`Std. Error`,EXERCISE)) %>%
  dplyr::rename(Estimate_n = Estimate)
d <- left_join(d1,d0) %>%
  filter(!is.na(Estimate_y),!is.na(Estimate_n))

p_spec_exercise <- ggplot(d,aes(x=Estimate_n,
                  y=Estimate_y)) +
  geom_point() +
  geom_abline(slope=1,intercept=0,linetype="dotted")+
  ggtitle("Comparison of inclusion vs exclusion of exercise as \na covariate, comparing light-to-moderate to non-drinkers")
p_spec_exercise
p_spec_exercise_path <- file.path(
  directions$dirs$results,
  directions$instructions$project$name,
  "004",
  "spec_plot_EXERCISE.png")
ggsave(p_spec_exercise_path,plot=p_spec_exercise, height = 8, width = 8, units = "in")

#Heatmap points and SEs: estimate is x axis, log(se) is y axis
# Don't need to do per spec.
p_heatmap <- ests_list$`alcohol_niaaalight-to-moderate` %>%
  ggplot(aes(x = exp(Estimate), y = log(`Std. Error`))) +
  geom_hex() +
  ggtitle("Heatmap summarizing the distribution of estimates across specifications")
p_heatmap
p_heatmap_path <- file.path(
  directions$dirs$results,
  directions$instructions$project$name,
  "004",
  "heatmap.png")
ggsave(p_heatmap_path,plot=p_heatmap, height = 8, width = 8, units = "in")

