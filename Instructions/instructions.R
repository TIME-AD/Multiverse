function(){

  res <- list(
    project = list(
      name = "Multiverse Workshop"
    ),

    #DESCRIBE WHAT THIS IS
    scripts = list(
      "000"= list(
        file_name = "000_Create_Model_Specifications.R",
        param_combs = c()
      ),
      "001" = list(
        #Apply eligibility criteria and merge on covariates, outputting different analysis data sets
        file_name = "001_create_eligible_sample.R",
        param_combs = c(
          "age_minimum_cutoffs",
          "cvd_history",
          "gender")
      ),
      "002" = list(
        #Run models with different exposure definitions, covariate sets, model forms and survey weighting choices
        file_name = "002_run_models.R",
        param_combs = c(
          "age_minimum_cutoffs",
          "cvd_history",
          "gender",
          "survey_weighting",
          "model_forms",
          "AGE",
          "RACE",
          "SEX",
          "EXERCISE",
          "bsIter"
        )
      ),
      "003" = list(),
      "004" = list()
    ),

    #DESCRIBE WHAT THIS IS
    #Which subfolder should each result type be saved to
    results_locations = list(
      #Example
      #"d_first_dx_comorbidities.RDS" = "000b",
      "cleaned_brfss.RDS" = "000",

      #001
      "sample.RDS" = "001",

      #002
      "estimates.RDS" = "002",
      #cis.RDS = "002",

      #003
      "estimates_compiled.RDS" = "003",       #Full sample and bootstrap estimates in long format
      "estimates_effects.RDS" = "003",        #Just full sample estimates
      "estimates_compiled_bsAgg.RDS" = "003", #Bootstrap estimates after aggregation

      #004
      "heatmap.png" = "004",      #Heatmap points and SEs
      "spec_plot_AGE.png" = "004",    #Paired specification plots
      "spec_plot_RACE.png" = "004",    #Paired specification plots
      "spec_plot_.png" = "004",    #Paired specification plots
      "spec_plot_AGE.png" = "004"    #Paired specification plots


      #Volcano plots (log se on y axis against estimate on x axis)

      #Tables
      # Show how to make a table 1 for each of the datasets output by 001

    ),

    #DESCRIBE WHAT THIS IS
    age_minimum_cutoffs = list(
      "50_plus" = 50,
      "60_plus" = 60,
      "70_plus" = 70
    ),
    cvd_history = list(
      "y"=TRUE,
      "n"=FALSE
    ),
    gender = list(
      "all"="all",
      "women"="women",
      "men"="men"
    ),
    #DESCRIBE THIS
    #0/1 refers to whether the covariate is included
    AGE = list(
      "n"=0,
      "y"=1
    ),
    SEX = list(
      "n"=0,
      "y"=1
    ),
    RACE = list(
      "n"=0,
      "y"=1
    ),
    EXERCISE = list(
      "n"=0,
      "y"=1
    ),
    model_forms = list("linear" = "linear",
                       "interaction" = "interaction",
                       "nonlinear" = "nonlinear"),
    survey_weighting = list(
      "y"=TRUE,
      "n"=FALSE
    ),

    bsIter=c(NA,1:2)
  )

  return(res)
}