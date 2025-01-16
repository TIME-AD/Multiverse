function(){

  res <- list(
    project = list(
      name = "Main Effect ITT Draft2 Bootstraps"
    ),
    scripts = list(
      "000b" = list(
        file_name = "000b_First_Dx_Comorbidities.R",
        param_combs = c()
      ),
      "001a" = list(
        file_name = "001a_Select_Enrollment_Periods.R",
        param_combs = c("collapse_enrollments",
                        "limit_first_enrollment")
      ),
      "001b" = list(
        file_name = "001b_Reclassify_Dementia.R",
        param_combs = c("outcome_and_censoring_vars",
                        "collapse_enrollments",
                        "limit_first_enrollment")
      ),
      "002" = list(
        file_name = "002_Create_Eligible_Sample.R",
        param_combs = c("collapse_enrollments",
                        "limit_first_enrollment",
                        "outcome_and_censoring_vars",
                        "burn_in_length",
                        "reenroll_burn_in_length",
                        "last_trial_date")
      ),
      "003" = list(
        file_name = "003_Matching.R",
        param_combs = c("collapse_enrollments",
                        "limit_first_enrollment",
                        "outcome_and_censoring_vars",
                        "burn_in_length",
                        "reenroll_burn_in_length",
                        "last_trial_date",
                        "match_cohort",
                        "age_restriction",
                        "exclude_prev_mcimem",
                        "matchAPOE",
                        "bsIter")
      ),
      "004" = list(
        file_name = "004_Merge_On_Covariates.R",
        param_combs = c("collapse_enrollments",
                        "limit_first_enrollment",
                        "outcome_and_censoring_vars",
                        "burn_in_length",
                        "reenroll_burn_in_length",
                        "last_trial_date",
                        "match_cohort",
                        "age_restriction",
                        "exclude_prev_mcimem",
                        "matchAPOE",
                        "bsIter"
        )
      ),
      "005" = list(
        file_name = "005_IPTW.R",
        param_combs = c("collapse_enrollments",
                        "limit_first_enrollment",
                        "outcome_and_censoring_vars",
                        "burn_in_length",
                        "reenroll_burn_in_length",
                        "last_trial_date",
                        "match_cohort",
                        "age_restriction",
                        "exclude_prev_mcimem",
                        "matchAPOE",
                        "bsIter",
                        "iptw")
      ),
      "006" = list(
        file_name = "006_Run_Cox_Models.R",
        param_combs = c("collapse_enrollments",
                        "limit_first_enrollment",
                        "outcome_and_censoring_vars",
                        "burn_in_length",
                        "reenroll_burn_in_length",
                        "last_trial_date",
                        "match_cohort",
                        "age_restriction",
                        "exclude_prev_mcimem",
                        "matchAPOE",
                        "bsIter",
                        "iptw",
                        "cox",
                        "first_yrs",
                        "periods",
                        "trim_level",
                        "use_predictors",
                        "weight",
                        "PS_adj",
                        "interactionDurationMonths",
                        "APOEixn",
                        "fuIntervalInteractions")
      )
    ),
    #Which subfolder should each result type be saved to
    results_locations = list(
      #"data_flowchart.RDS" = ".", #Need to break into pieces
      #000b
      "d_first_dx_comorbidities.RDS" = "000b",

      #001a
      "enrollment_periods.RDS" = "001a",

      #001b
      "d_first_dem_by_cat_wide.RDS" = "001b",
      "d_outcome_and_censoring_dates.RDS" = "001b",
      "d_all_dementia_long.RDS" = "001b",
      "d_mcimem_firstdx_norecode.RDS" = "001b",

      #002
      "d_pre_burn.RDS" = "002",
      "d_post_burn.RDS" = "002",
      "d_burned.RDS" = "002",

      #003
      "d_prematch.RDS" = "003",
      "matched_pairs.RDS" = "003",
      "matched_long.RDS" = "003",
      "d_analysis.RDS" = "003",

      #004
      "mean_labs_imputations.R" = "004",
      "d_t.RDS" = "004",

      #005
      "IPTW.RDS" = "005",
      "d_t_wPS.RDS" = "005",

      #006
      "d_trimmed.RDS"="006",
      "cox.RDS"="006",
      "cox_input.RDS"="006",
      "cox_coefs.RDS"="006"
    ),
    collapse_enrollments=list(
      n = FALSE
    ),
    limit_first_enrollment=list(
      y = TRUE
    ),
    burn_in_length = list(
      years_4 = 4
    ),
    reenroll_burn_in_length = list(
      years_1 = 1
    ),
    match_cohort = list(
      #Setting this to genetic only for testing purposes: Need to change back
      "Full"="Full",
      "Survey"="Survey",
      "Genetic"="Genetic"
    ),
    #identify trial dates for each dataset that have statin initiators between 2001-01-01 and 2010-12-31
    #Formerly called "period_for_analysis"
    #Start date is defined by the earliest statin rx in the eligible sample after burn-in in script 001
    last_trial_date = list(
      main = "2010-12-31"
    ),
    age_restriction = list(
      "n"=list(restrict_age=FALSE)
      # ,
      # "y_60min"=list(restrict_age=TRUE,
      #          age_min=60,
      #          age_max=NA),
      # "y_70min"=list(restrict_age=TRUE,
      #          age_min=70,
      #          age_max=NA)
    ),
    exclude_prev_mcimem = list(
      "n"=FALSE#,
      #"y"=TRUE
    ),
    matchAPOE = list(
      "n"=FALSE,
      "y"=TRUE
    ),
    bsIter=1:500,
    iptw = list(
      useModels=list(
        "0"="0"),
      varCategories = list(
        #basic demographic variables and history of diseases
        basic_0=c(
          "RACE_CAT","SEX_MALE",
          "Year","HX_MDD","HX_HTN","HX_CVD","HX_stroke","HX_HEAD_INJ","HX_DIABETES"),

        #cov_basic + prescriptions counts
        basic=c(
          "RACE_CAT","SEX_MALE",
          "Year","HX_MDD","HX_HTN","HX_CVD","HX_stroke","HX_HEAD_INJ","HX_DIABETES",
          "AV_CT_LOG","VC_CT_LOG","IP_CT_LOG","PRESC_CT_LOG"),

        #continuous variables including their quadratic form
        cont_quad = c("age","hba1c","HDL","LDL","age2","hba1c2","HDL2","LDL2"),

        #continuous variables in their quartile form
        cont_4 = c("age_4","hba1c_4","HDL_4","LDL_4"),

        #year prior status of major history of diseases
        yp = c("yp_MDD","yp_HTN","yp_CVD","yp_stroke","yp_HEAD_INJ","yp_DIABETES"),

        #survey variables
        surveys = c("EDUCATION","INCOME","MARITALSTATUS","SIZEOFHH",
                    "USABORN","USABORNFATHER","USABORNMOTHER","GENERALHEALTH","ALCOHOL_DAYSPERWEEK"),

        #which survey the participant took
        which_survey = c("WHICH_SURVEY"),

        #Genetics
        APOE=c("APOE")
      )
    ),
    cox = list(
      useModels=list(
        "Full"=list(
          "5"="5"
        ),
        "Survey"=list(
          "5"="5"
        ),
        "Genetic"=list(
          "5"="5",
          "6"="6"
        )
      ),
      first_yrs = list("y"=TRUE,
                       "n"=FALSE),
      periods = list( #All end dates should occur at/before the trial_end_date above
        "pre2011" =list(start = "2000-01-01",
                        end="2010-12-31")
      ),
      trim_level = list("0.01"=0.01), ## ex) 0.01 --> 1st~99th percentile, 0.05 --> 5th~95th percentile.
      use_predictors = list("y"=TRUE),
      weight = list("y"=TRUE),
      PS_adj = list("y"=TRUE,"n"=FALSE)
    )
  )

  x <- res$iptw$varCategories
  res$iptw$models <- list(
    "Full"=list(
      "0"=glue("statin_initiator ~(","{paste0(c(x$basic_0), collapse = ' + ')}",")^2"),
      "1"=glue("statin_initiator ~","{paste0(c(x$basic,x$yp,x$cont_quad), collapse = ' + ')}"),
      "2"=glue("statin_initiator ~(","{paste0(c(x$basic,x$yp,x$cont_quad), collapse = ' + ')}",")^2"),
      "3"=glue("statin_initiator ~(","{paste0(c(x$basic,x$yp,x$cont_4), collapse = ' + ')}",")^2")
    ),
    "Survey" = list(
      "0"=glue("statin_initiator ~(","{paste0(c(x$basic_0,x$which_survey), collapse = ' + ')}",")^2"),
      "1"=glue("statin_initiator ~","{paste0(c(x$basic,x$yp,x$cont_quad,x$surveys), collapse = ' + ')}"),
      "2"=glue("statin_initiator ~(","{paste0(c(x$basic,x$yp,x$cont_quad,x$surveys), collapse = ' + ')}",")^2"),
      "3"=glue("statin_initiator ~(","{paste0(c(x$basic,x$yp,x$cont_4,x$surveys), collapse = ' + ')}",")^2")
    ),
    "Genetic" = list(
      "0"=glue("statin_initiator ~(","{paste0(c(x$basic_0,x$which_survey,x$APOE), collapse = ' + ')}",")^2"),
      "1"=glue("statin_initiator ~","{paste0(c(x$basic,x$yp,x$cont_quad,x$surveys,x$APOE), collapse = ' + ')}"),
      "2"=glue("statin_initiator ~(","{paste0(c(x$basic,x$yp,x$cont_quad,x$surveys,x$APOE), collapse = ' + ')}",")^2"),
      "3"=glue("statin_initiator ~(","{paste0(c(x$basic,x$yp,x$cont_4,x$surveys,x$APOE), collapse = ' + ')}",")^2")
    )
  )

  res$cox$predictors <- list(
    #Need a way for each of these to specify interactions as well
    "Full"=list(
      #Min's models 1 and 2 are crude and IPTW weighted without predictors, respectively
      # so there's no need to specify predictors here
      #"3"= c("LDL_4","age_4"),
      #"4"= c("LDL_4","PS_DC"),
      "5"= c("LDL_4","age_4","PS_DC")
    ),
    "Survey" = list(
      #"3"= c("LDL_4","age_4"),
      #"4"= c("LDL_4","PS_DC"),
      "5"= c("LDL_4","age_4","PS_DC")
    ),
    "Genetic" = list(
      #"3"= c("LDL_4","age_4"),
      #"4"= c("LDL_4","PS_DC"),
      "5"= c("LDL_4","age_4","PS_DC"),
      #ADD ixn here
      "6"= c("LDL_4", "age_4", "PS_DC", "APOE", "PCs")
    )
  )

  #---New for Erin
  res$cox$interactionDurationMonths = list(
    "1yr" = 12,
    "6mo" = 6,
    "3mo" = 3,
    "1mo" = 1
  )

  res$cox$APOEixn = list(
    "y"=TRUE,
    "n"=FALSE
  )
  #---End new for Erin


  res$fuIntervalInteractions = list(
    "y"=TRUE,
    "n"=FALSE
  )

  res$outcome_and_censoring_vars = list(
    "ADRD"=list(
      outcome = c("AD","VD","NSD"),
      censor = c("PDDem", "LBD", "ALCD", "OTHD", "ALS", "FTD"),
      mcimem = c("MCI", "MEMLOSS"),
      recode_mcimem = FALSE,
      reclassify_censor_months = 12,
      reclassify_mcimem_months = 12
    ),
    "AD"=list(
      outcome = c("AD"),
      censor = c("PDDem", "LBD", "ALCD", "OTHD", "ALS", "FTD","VD","NSD"),
      mcimem = c("MCI", "MEMLOSS"),
      recode_mcimem = FALSE,
      reclassify_censor_months = 12,
      reclassify_mcimem_months = 12
    )
    # ,
    # "mcimem_in_outcome" = list(
    #   outcome = c("AD","VD","NSD","MCI", "MEMLOSS"),
    #   censor = c("PDDem", "LBD", "ALCD", "OTHD", "ALS", "FTD"),
    #   mcimem = c(),
    #   recode_mcimem = FALSE,
    #   reclassify_censor_months = 12,
    #   reclassify_mcimem_months = 12
    # )
  )
  return(res)
}