function(){#Wrapper for instructions

  res <- list(
    project = list(
      name = "Multiverse Workshop"
    ),

    scripts = list(
      #Set up all of the different model specifications
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
          "EXERCISE"
        )
      ),
      "003" = list(),
      "004" = list()
    ),

    #Which subfolder should each result type be saved to
    results_locations = list(
      #000
      "cleaned_brfss.RDS" = "000",

      #001
      "sample.RDS" = "001",

      #002
      "estimates.RDS" = "002",

      #003
      "estimates_compiled.RDS" = "003",

      #004
      "spec_plot_EXERCISE.png" = "004",    #Paired specification plot
      "heatmap.png" = "004"                #Heatmap points and SEs

    ),

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

    #Covariates
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
    )
  )

  return(res)
}
