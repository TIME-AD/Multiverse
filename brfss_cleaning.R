rm(list=ls())
library(tidyverse)
library(haven)
brfss2023 <- read_xpt(file.path("Data/LLCP2023.XPT"))
#colnames(brfss2023)

# Select appropriate column names
variables_tokeep <- c("_AGE80", "_AGE_G", # Weird age variables
                      "SEXVAR", "_RACEPRV", "MARITAL", "EDUCA", "_INCOMG1", "WEIGHT2", "HTIN4", # sociodemographics
                      "GENHLTH", "_HLTHPL1", #health status
                      "MARIJAN1", "SMOKDAY2", #marijuana & tobacco use
                      "EXERANY2", # exercise
                      "CVDSTRK3", "CVDINFR4", "CVDCRHD4", #cardiovascular disease
                      "DRNKANY6", "DROCDY4_", "_RFBING6", "_DRNKWK2", "_RFDRHV8", "ALCDAY4", "MAXDRNKS", "AVEDRNK3", # alcohol variables
                      "BPHIGH6", "BPMEDS1",#hypertension variables
                      "_LLCPWT") #survey weights
cohort <- brfss2023[,variables_tokeep]

cohort <- cohort %>%
  rename(age_imputed = "_AGE80", # Imputed age value, collapsed above 80
         age_categories = "_AGE_G", # Age in 6 groups (18-24, 25-34, 35-44, 45-54, 55-64, >65)
         sex = SEXVAR, # Sex at birth
         race = "_RACEPRV", # Race variable defined from race & Ethnicity vars
         marital_status = MARITAL, #marital status
         education = EDUCA, # highest level of education
         income = "_INCOMG1", #household income
         weight_lbs = WEIGHT2, #weight in pounds
         height_ins = HTIN4, # weight in inches
         generalhealth = GENHLTH, # self-reported health status
         insurance = "_HLTHPL1", #health insurance coverage
         marijuana = MARIJAN1, #days of marijuana use in past month
         smokingstatus = SMOKDAY2, #smoking status
         exercise = EXERANY2, # exercise in past 30 days
         stroke = CVDSTRK3, #stroke
         heartattack = CVDINFR4, #heart attack
         coronaryheartd = CVDCRHD4, #coronary heart disease
         drink_indicator = DRNKANY6, #indicator for having at least 1 drink in past 30 days
         drink_occasions = DROCDY4_, #drink-occasions-per-day
         bingedrink = "_RFBING6", #binge drinker (>=5 for men, >=4 for women on one day) #BINGE
         drink_perweek = "_DRNKWK2", #number of drinks per week                          #DRINKS/WEEK
         heavydrink = "_RFDRHV8", #heavy drinker (>14 per week for men, >7 for women)
         drink_past30 = ALCDAY4, #number of days per month with a drink                  #FREQ
         averagen_drink = AVEDRNK3, #average drinks per day on days when drinking        #QUANTITY
         max_drinks = MAXDRNKS, # maximum number of drinks on one occasion
         high_bp = BPHIGH6, #high blood pressure
         bp_medication = BPMEDS1, #high blood pressure meds
         surveyweights = "_LLCPWT") # survey weights

# Clean some data
cohort <- cohort %>%
  mutate(female = case_when(sex == 2 ~ 1,
                            sex == 1 ~ 0,
                            TRUE ~ NA),
         marital_status = case_when(marital_status == 6 ~ 5,
                                    marital_status == 9 ~ NA,
                                    TRUE ~ marital_status),
         education = case_when(education == 9 ~ NA,
                               education == 1 ~ 3,
                               education == 2 ~ 3,
                               TRUE ~ education),
         income = case_when(income == 9 ~ NA,
                            TRUE ~ income),
         # if weight variable is between 9023 & 9352, we need to convert from kg to pounds
         weight_lbs = case_when(weight_lbs == 9999 ~ NA,
                                weight_lbs == 7777 ~ NA,
                                weight_lbs >= 9023 & weight_lbs <= 9352 ~ (weight_lbs - 9000)*2.205,
                                TRUE ~ weight_lbs),
         generalhealth = case_when(generalhealth == 7 | generalhealth == 9 ~ NA,
                                   TRUE ~ generalhealth),
         insurance = case_when(insurance == 2 ~ 0,
                               insurance == 9 ~ NA,
                               TRUE ~ insurance),
         marijuana = case_when(marijuana == 88 ~ 0,
                               marijuana == 77 ~ NA,
                               marijuana == 99 ~ NA,
                               TRUE ~ marijuana),
         smokingstatus = case_when(smokingstatus == 7 ~ NA,
                                   smokingstatus == 9 ~ NA,
                                   TRUE ~ smokingstatus),
         exercise = case_when(exercise == 7 ~ NA,
                              exercise == 9 ~ NA,
                              exercise == 2 ~ 0,
                              TRUE ~ exercise),
         stroke = case_when(stroke == 7 ~ NA,
                              stroke == 9 ~ NA,
                              stroke == 2 ~ 0,
                              TRUE ~ stroke),
         heartattack = case_when(heartattack == 7 ~ NA,
                                 heartattack == 9 ~ NA,
                                 heartattack == 2 ~ 0,
                              TRUE ~ heartattack),
         coronaryheartd = case_when(coronaryheartd == 7 ~ NA,
                                    coronaryheartd == 9 ~ NA,
                                    coronaryheartd == 2 ~ 0,
                                 TRUE ~ coronaryheartd),
         drink_indicator = case_when(drink_indicator == 7 ~ NA,
                                     drink_indicator == 9 ~ NA,
                                     drink_indicator == 2 ~ 0,
                                    TRUE ~ drink_indicator),
         drink_occasions = case_when(drink_occasions == 900 ~ NA,
                                     TRUE ~ drink_occasions),
         bingedrink = case_when(bingedrink == 9 ~ NA,
                                bingedrink == 2 ~ 1,
                                bingedrink == 1 ~ 0,
                                TRUE ~ bingedrink),
         drink_perweek = case_when(drink_perweek == 99900 ~ NA,
                                TRUE ~ drink_perweek),
         heavydrink = case_when(heavydrink == 9 ~ NA,
                                heavydrink == 2 ~ 1,
                                heavydrink == 1 ~ 0,
                                TRUE ~ heavydrink),
         # Sometimes this variable is coded per week, and sometimes per month
         drink_past30 = case_when(drink_past30 == 777 ~ NA,
                                  drink_past30 == 999 ~ NA,
                                  drink_past30 == 888 ~ 0,
                                  drink_past30 >= 101 & drink_past30 <=199 ~ (drink_past30-100)*4,
                                  drink_past30 >= 201 & drink_past30 <=299 ~ (drink_past30-200),
                                TRUE ~ drink_past30),
         averagen_drink = case_when(averagen_drink == 88 ~ 0,
                                    averagen_drink == 77 ~ NA,
                                    averagen_drink == 99 ~ NA,
                                  TRUE ~ averagen_drink),
         max_drinks = case_when(max_drinks == 88 ~ NA,
                                max_drinks == 77 ~ NA,
                                max_drinks == 99 ~ NA,
                                TRUE ~ max_drinks),
         high_bp = case_when(high_bp == 7 ~ NA,
                             high_bp == 9 ~ NA,
                             TRUE ~ high_bp),
         bp_medication = case_when(high_bp == 3 ~ 0,
                                   bp_medication == 2 ~ 0,
                                   bp_medication == 7 ~ NA,
                                   bp_medication == 9 ~ NA,
                                   TRUE ~ bp_medication)
         ) %>%
  select(-sex)

cohort$age_categories <- factor(cohort$age_categories,
                      levels = c(1,2,3,4,5,6),
                      labels = c("18-24", "25-34", "35-44", "45-54", "55-64","65 and older"))
cohort$race <- factor(cohort$race,
                                levels = c(1,2,3,4,5,6,7,8),
                                labels = c("White", "Black", "American Indian/Alaska Native",
                                           "Asian", "Hawaiian or Pacific Islander", "Other", "Multiracial", "Hispanic"))
cohort$marital_status <- factor(cohort$marital_status,
                                   levels = c(1,2,3,4,5),
                                   labels = c("Married", "Divorced", "Widowed", "Separated", "Single"))
cohort$education <- factor(cohort$education,
                                   levels = c(3,4,5,6),
                                   labels = c("Less than HS", "HS", "Some college", "College/more"))
cohort$income <- factor(cohort$income,
                              levels = c(1,2,3,4,5,6,7),
                              labels = c("Less than 15k", "15-25k", "25-35k", "35-50k", "50-100k", "100-200k", "More than 200k"))
cohort$generalhealth <- factor(cohort$generalhealth,
                        levels = c(1,2,3,4,5),
                        labels = c("Excellent", "Very good", "Good", "Fair", "Poor"))
cohort$smokingstatus <- factor(cohort$smokingstatus,
                               levels = c(1,2,3),
                               labels = c("Every Day", "Some Days", "Never"))
cohort$high_bp <- factor(cohort$high_bp,
                               levels = c(1,2,3,4),
                               labels = c("Yes", "During Pregnancy", "No", "Pre-hypertensive"))

cohort <- cohort %>% mutate(
  alcohol_niaaa = case_when(
    !drink_indicator ~ "none",
    drink_indicator & !heavydrink & !bingedrink ~ "light-to-moderate",
    heavydrink | bingedrink ~ "heavy"
  ),
  hypertension = case_when(
    high_bp == "Yes" ~ 1,
    TRUE ~ 0
  )
)

saveRDS(cohort, file.path("Data/cleaned_brfss.RDS"))
