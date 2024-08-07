test_that("postgres test", {
  skip_on_cran()
  skip_if(Sys.getenv("CDM5_POSTGRESQL_DBNAME") == "")

  db <- DBI::dbConnect(RPostgres::Postgres(),
                       dbname = Sys.getenv("CDM5_POSTGRESQL_DBNAME"),
                       host = Sys.getenv("CDM5_POSTGRESQL_HOST"),
                       user = Sys.getenv("CDM5_POSTGRESQL_USER"),
                       password = Sys.getenv("CDM5_POSTGRESQL_PASSWORD"))
  cdm <- CDMConnector::cdm_from_con(
    con = db,
    cdm_schema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"),
    write_schema = c(schema =  Sys.getenv("CDM5_POSTGRESQL_SCRATCH_SCHEMA"),
                     prefix = "incp_"),
    achilles_schema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA")
  )

  cdm$asthma <- CohortConstructor::conceptCohort(cdm = cdm,
                                                  conceptSet = list("asthma" = 317009),
                                                  name = "asthma")
  drug_codes <- CodelistGenerator::getDrugIngredientCodes(cdm,
                                       name = c("diclofenac", "metformin"))
  cdm$drugs <- CohortConstructor::conceptCohort(cdm = cdm,
                                                conceptSet = drug_codes,
                                                name = "drugs")
  cdm <- omopgenerics::bind(cdm$asthma, cdm$drugs, name = "my_cohort")

  result_code_diag <- codelistDiagnostics(cdm$my_cohort)
  # shiny with only codelist results
  expect_no_error(shinyDiagnostics(result_code_diag))

  result_cohort_diag <- cohortDiagnostics(cdm$my_cohort)
  expect_no_error(reportDiagnostics(result = result_code_diag))
  # shiny with only cohort diagnostics results
  expect_no_error(shinyDiagnostics(result = result_cohort_diag))

  # shiny with all results
  result_all <- omopgenerics::bind(result_code_diag, result_cohort_diag)
  expect_no_error(shinyDiagnostics(result = result_all))

  CDMConnector::cdm_disconnect(cdm = cdm)

})
