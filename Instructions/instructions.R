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
          "EXERCISE",
          "bsIter"
        )
      )
    ),

    #DESCRIBE WHAT THIS IS
    #Which subfolder should each result type be saved to
    results_locations = list(
      #Example
      #"d_first_dx_comorbidities.RDS" = "000b",
      "cleaned_brfss.RDS" = "000",

      #001
      "sample.RDS" = "001"

      #002
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
    covariate_sets = list(
      AGE = c(0,1),
      SEX = c(0,1),
      RACE = c(0,1),
      EXERCISE = c(0,1)
    ),
    model_forms = c("linear","interaction","nonlinear"),
    survey_weighting = list(
      "y"=TRUE,
      "n"=FALSE
    ),

    bsIter=1:2
  )

  return(res)
}