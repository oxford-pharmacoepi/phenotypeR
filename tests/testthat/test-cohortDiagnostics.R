test_that("run with a single cohort", {
  testthat::skip_on_cran()

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockVisitOccurrence() |>
    omock::mockProcedureOccurrence() |>
    omock::mockCohort(name = "my_cohort")

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                          schema ="main", overwrite = TRUE)

  expect_no_error(result <- cdm$my_cohort |>
    cohortDiagnostics(matchedSample = 0))

  # Check settings
  expect_identical(
    result |>
      omopgenerics::settings() |>
      dplyr::pull("diagnostic") |>
      unique(),
    "cohortDiagnostics")

  expect_identical(
    result |>
      omopgenerics::settings() |>
      dplyr::pull("matched_sample") |>
      unique(),
    "0")

  # Check all the expected summarised results have been calculated)
  expect_true(all(c((dplyr::pull(omopgenerics::settings(result), "result_type") |> unique()) %in%
                      c("summarise_cohort_attrition", "summarise_cohort_count", "summarise_characteristics",
                    "summarise_table", "summarise_large_scale_characteristics"))))
  expect_true(result$group_level |> unique() == "cohort_1")

  # cohort and timing and overlap should have been skipped
  expect_false(any("summarise_cohort_overlap" ==
   omopgenerics::settings(result) |>
    dplyr::pull("result_type")))

  # option lsc FALSE works
  expect_no_error(result <- cdm$my_cohort |> cohortDiagnostics(largeScaleCharacteristics = FALSE))
  expect_false(any("summarise_large_scale_characteristics" ==
                     omopgenerics::settings(result) |>
                     dplyr::pull("result_type")))

})

test_that("run with multiple cohorts", {
  testthat::skip_on_cran()

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 2000, seed = 1234) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockVisitOccurrence() |>
    omock::mockProcedureOccurrence() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  expect_no_error(result <- cdm$my_cohort |>
                    cohortDiagnostics())
  expect_no_error(result_comp <- cdm$my_cohort |>
                    cohortDiagnostics(compareCohorts = TRUE))

  # check density is being calculated
  expect_true(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "table")))

  # Check density is calculated by cohort
  expect_identical(result |>
                     dplyr::filter(variable_name == "age") |>
                     dplyr::select("group_level") |>
                     dplyr::distinct() |>
                     dplyr::pull() |>
                     sort(),
                   c("cohort_1", "cohort_1_matched", "cohort_1_sampled",
                     "cohort_2", "cohort_2_matched", "cohort_2_sampled"))

  # cohort and timing and overlap should have been estimated now we have more than one cohort
  expect_false(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "cohort_overlap")))
  expect_true(any(stringr::str_detect(
    omopgenerics::settings(result_comp) |>
      dplyr::pull("result_type"),
    "cohort_overlap")))
  expect_false(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "cohort_timing")))
  expect_true(any(stringr::str_detect(
                   omopgenerics::settings(result_comp) |>
                    dplyr::pull("result_type"),
                   "cohort_timing")))

  # Check matched cohorts
  expect_true(
    all(sort(unique(result_comp$group_level)) == c("cohort_1", "cohort_1 &&& cohort_2", "cohort_1_matched", "cohort_1_sampled",
                                                        "cohort_2", "cohort_2 &&& cohort_1", "cohort_2_matched", "cohort_2_sampled"))
  )

  # Check all the summarised results are there
  expect_true(
    all(result |>
          omopgenerics::settings() |>
          dplyr::pull("result_type")  %in%
        c(rep("summarise_cohort_attrition",2), "summarise_cohort_count", "summarise_cohort_overlap",
        "summarise_cohort_timing", "summarise_characteristics", "summarise_table",
        rep("summarise_large_scale_characteristics", 12))
    )
  )


  result_cohort_2 <- cdm$my_cohort |>
    cohortDiagnostics(cohortId = 2)
  expect_true(result_cohort_2 |>
                dplyr::filter(stringr::str_detect(group_level, "cohort_1")) |>
                nrow() == 0)
  expect_true(result_cohort_2 |>
                dplyr::filter(stringr::str_detect(group_level, "cohort_2")) |>
                nrow() > 0)



  # empty death tables ----
  cdm <- omopgenerics::emptyOmopTable(cdm, name = "death")
  expect_warning(cohortDiagnostics(cdm$my_cohort, cohortSurvival = TRUE))

  # check age distribution when there are cohorts with less than 100 people ----
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 500, seed = 1) |>
    omock::mockObservationPeriod(seed = 1) |>
    omock::mockConditionOccurrence(seed = 1) |>
    omock::mockVisitOccurrence() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2, seed = 1)

  # check when only one cohortId is provided and it does not have more than 100 subjects
  expect_warning(res <- cdm_local$my_cohort |>
    cohortDiagnostics(cohortId = 1,
                      cohortCount = FALSE,
                      cohortCharacteristics = TRUE,
                      largeScaleCharacteristics = FALSE,
                      compareCohorts = FALSE,
                      cohortSurvival = FALSE,
                      cohortSample = 99,
                      matchedSample = NULL
                      ))

  expect_equal(res |>
    dplyr::distinct(group_level) |>
    dplyr::pull(),
    c("cohort_1", "cohort_1_sampled", "cohort_1_matched"))

  expect_equal(res |>
    omopgenerics::settings() |>
    dplyr::pull("result_type"),
    "summarise_characteristics")

  # check when only one of the cohorts has less than 100 subjects, and the sample and the matched cohort of this one do not reach 100 subjects
  cdm_local$my_cohort <- cdm_local$my_cohort |>
    CohortConstructor::requireAge(ageRange = c(0,10), cohortId = 1)

  expect_warning(res <- cdm_local$my_cohort |>
                   cohortDiagnostics(cohortCount = FALSE,
                                     cohortCharacteristics = TRUE,
                                     largeScaleCharacteristics = FALSE,
                                     compareCohorts = FALSE,
                                     cohortSurvival = FALSE,
                                     cohortSample = NULL,
                                     matchedSample = NULL))

  expect_equal(res |>
                visOmopResults::filterSettings(result_type == "summarise_table") |>
                dplyr::distinct(group_level) |>
                dplyr::pull("group_level"),
              "cohort_2")

  # check when only one of the cohorts has less than 100 subjects
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 2000, seed = 1) |>
    omock::mockObservationPeriod(seed = 1) |>
    omock::mockConditionOccurrence(seed = 1) |>
    omock::mockVisitOccurrence() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2, seed = 1)

  cdm_local$my_cohort <- cdm_local$my_cohort |>
    CohortConstructor::requireAge(ageRange = c(0,5), cohortId = 1)

  expect_warning(res <- cdm_local$my_cohort |>
                   cohortDiagnostics(cohortCount = FALSE,
                                     cohortCharacteristics = TRUE,
                                     largeScaleCharacteristics = FALSE,
                                     compareCohorts = FALSE,
                                     cohortSurvival = FALSE,
                                     cohortSample = NULL,
                                     matchedSample = NULL))

  expect_equal(res |>
    visOmopResults::filterSettings(result_type == "summarise_table") |>
    dplyr::distinct(group_level) |>
    dplyr::pull("group_level"),
  c("cohort_2", "cohort_2_matched", "cohort_2_sampled"))

  # check survival analysis is being done -----
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockVisitOccurrence() |>
    omock::mockProcedureOccurrence() |>
    omock::mockDeath() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  result <- cohortDiagnostics(cdm$my_cohort,
                              compareCohorts = TRUE,
                              cohortSurvival = TRUE)

  expect_true("summarise_cohort_count" %in%
                   c(result |>
                     omopgenerics::settings() |>
                     dplyr::pull("result_type") |>
                     unique()))
  expect_true("summarise_cohort_count" %in%
                c(result |>
                omopgenerics::settings() |>
                dplyr::pull("result_type") |>
                unique()))
  expect_true("summarise_cohort_overlap" %in%
                c(result |>
                omopgenerics::settings() |>
                dplyr::pull("result_type") |>
                unique()))
  expect_true("summarise_cohort_timing" %in%
                c(result |>
                omopgenerics::settings() |>
                dplyr::pull("result_type") |>
                unique()))
  expect_true("summarise_characteristics" %in%
                c(result |>
                omopgenerics::settings() |>
                dplyr::pull("result_type") |>
                unique()))
  expect_true("summarise_large_scale_characteristics" %in%
                c(result |>
                omopgenerics::settings() |>
                dplyr::pull("result_type") |>
                unique()))
  expect_true("survival_estimates" %in%
                c(result |>
                omopgenerics::settings() |>
                dplyr::pull("result_type") |>
                unique()))

})


