# Phenotype a cohort

This comprises all the diagnostics that are being offered in this
package, this includes:

- A diagnostic on the OMOP CDM dataset as a whole via
  `databaseDiagnostics`.

- A diagnostic on the codelists associated with cohorts via
  `codelistDiagnostics`.

- A diagnostic on the cohort itself via `cohortDiagnostics`.

- A diagnostic on the frequency of the cohort in the dataset population
  via `populationDiagnostics`.

## Usage

``` r
phenotypeDiagnostics(
  cohort,
  databaseDiagnostics = list(),
  codelistDiagnostics = list(),
  cohortDiagnostics = list(),
  populationDiagnostics = list(),
  stagingDirectory = NULL
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- databaseDiagnostics:

  A list of arguments that uses `databaseDiagnostics`. If the list is
  empty, the default values will be used. Example: In the following
  example, all diagnostics will be run except *person table summary*
  from databaseDiagnostics: \*databaseDiagnostics = list(
  "personTableSummary" = FALSE )

- codelistDiagnostics:

  A list of arguments that uses `codelistDiagnostics`. If the list is
  empty, the default values will be used. Example: In the below example,
  all diagnostics will be run, and a subsample of 1,000 participants
  will be used to run measurement diagnostics and another independent
  subsample of 500 participants will be used to run drug diagnostics:
  \*codelistDiagnostics = list( "measurementDiagnosticsSample" = 1000,
  "drugDiagnosticsSample" = 500 )

- cohortDiagnostics:

  A list of arguments that uses `cohortDiagnostics`. If the list is
  empty, the default values will be used. Example: \*cohortDiagnostics =
  list( "cohortSurvival" = TRUE )

- populationDiagnostics:

  A list of arguments that uses `populationDiagnostics`. If the list is
  empty, the default values will be used. Example: In the below example,
  all diagnostics will be run and a subsample of 100,000 participants
  will be used to run populationDiagnostics. \*populationDiagnostics =
  list( "populationSample" = 100000 )

- stagingDirectory:

  Path to folder to save incremental results and log file

## Value

A summarised result

## Examples

``` r
# \donttest{
library(omock)
library(CohortConstructor)
library(PhenotypeR)

cdm <- mockCdmFromDataset(source = "duckdb")
#> ℹ Loading bundled GiBleed tables from package data.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.
cdm$warfarin <- conceptCohort(cdm,
                              conceptSet =  list(warfarin = c(1310149L,
                                                              40163554L)),
                              name = "warfarin")
#> ℹ Subsetting table drug_exposure using 2 concepts with domain: drug.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort warfarin created.
result <- phenotypeDiagnostics(cdm$warfarin)
#> Logging PhenotypeR progress in
#> /tmp/RtmpXy1srL/phenotypeDiagnostics_log_{date}_{time}1d5e7e1b6cd.txt
#> ℹ Creating log file:
#>   /tmp/RtmpXy1srL/phenotypeDiagnostics_log_2026_07_27_11_03_141d5e7e1b6cd.txt.
#> [2026-07-27 11:03:14] - Log file created
#> [2026-07-27 11:03:14] - Database diagnostics - getting CDM Snapshot
#> [2026-07-27 11:03:14] - Database diagnostics - summarising person table
#> ℹ The following estimates will be calculated:
#> • date_of_birth: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-07-27 11:03:18.058987
#> ✔ Summary finished, at 2026-07-27 11:03:18.116736
#> [2026-07-27 11:03:18] - Database diagnostics - summarising observation period
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-07-27 11:03:21.101873
#> ✔ Summary finished, at 2026-07-27 11:03:21.168175
#> [2026-07-27 11:03:22] - Codelist diagnostics - index event breakdown
#> Getting counts of warfarin codes for cohort warfarin
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.
#> [2026-07-27 11:03:23] - Cohort diagnostics - cohort attrition
#> [2026-07-27 11:03:23] - Cohort diagnostics - cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> [2026-07-27 11:03:25] - Cohort diagnostics - matched cohorts
#> → Sampling cohort `tmp_022_sampled_independent`
#> Returning entry cohort as the size of the cohorts to be sampled is equal or
#> smaller than `n`.
#> • Generating an age and sex matched cohort for warfarin
#> Starting matching
#> ℹ Creating copy of target cohort.
#> • 1 cohort to be matched.
#> ℹ Creating controls cohorts.
#> ℹ Excluding cases from controls
#> • Matching by gender_concept_id and year_of_birth
#> • Removing controls that were not in observation at index date
#> • Excluding target records whose pair is not in observation
#> • Adjusting ratio
#> Binding cohorts
#> ✔ Done
#> → Getting cohorts and indexes
#> [2026-07-27 11:03:34] - Cohort diagnostics - cohort characteristics
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names cast to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> [2026-07-27 11:03:39] - Cohort diagnostics - age density
#> ℹ The following estimates will be calculated:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-07-27 11:03:40.375593
#> ✔ Summary finished, at 2026-07-27 11:03:40.502371
#> Using defaults for windows for large scale characteristics: c(-365, -31),
#> c(-30, -1), c(0, 0), c(1, 30), and c(31, 365). These can be changed via passing
#> alternative windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_window`
#> Using defaults for event tables for large scale characteristics:
#> condition_occurrence, measurement, procedure_occurrence, device_exposure, and
#> observation. These can be changed via passing alternative windows as a global
#> option `PhenotypeR_summariseLargeScaleCharacteristics_eventInWindow`
#> Using defaults for episode tables for large scale characteristics:
#> drug_exposure, drug_era, and visit_occurrence. These can be changed via passing
#> alternative windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_episodeInWindow`
#> [2026-07-27 11:03:40] - Cohort diagnostics - large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table measurement (2 of 7)
#>  - getting characteristics from table measurement (2 of 7) for time window -365…
#>  - getting characteristics from table measurement (2 of 7) for time window -30 …
#>  - getting characteristics from table measurement (2 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 31 a…
#>  - getting characteristics from table procedure_occurrence (3 of 7)
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table observation (4 of 7)
#>  - getting characteristics from table observation (4 of 7) for time window -365…
#>  - getting characteristics from table observation (4 of 7) for time window -30 …
#>  - getting characteristics from table observation (4 of 7) for time window 0 an…
#>  - getting characteristics from table observation (4 of 7) for time window 1 an…
#>  - getting characteristics from table observation (4 of 7) for time window 31 a…
#>  - getting characteristics from table drug_exposure (5 of 7)
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 31…
#>  - getting characteristics from table drug_era (6 of 7)
#>  - getting characteristics from table drug_era (6 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (6 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (6 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (6 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (6 of 7) for time window 31 and …
#>  - getting characteristics from table visit_occurrence (7 of 7)
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#> Formatting result
#> 234 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table measurement (2 of 7)
#>  - getting characteristics from table measurement (2 of 7) for time window -365…
#>  - getting characteristics from table measurement (2 of 7) for time window -30 …
#>  - getting characteristics from table measurement (2 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 31 a…
#>  - getting characteristics from table procedure_occurrence (3 of 7)
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table observation (4 of 7)
#>  - getting characteristics from table observation (4 of 7) for time window -365…
#>  - getting characteristics from table observation (4 of 7) for time window -30 …
#>  - getting characteristics from table observation (4 of 7) for time window 0 an…
#>  - getting characteristics from table observation (4 of 7) for time window 1 an…
#>  - getting characteristics from table observation (4 of 7) for time window 31 a…
#>  - getting characteristics from table drug_exposure (5 of 7)
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 31…
#>  - getting characteristics from table drug_era (6 of 7)
#>  - getting characteristics from table drug_era (6 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (6 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (6 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (6 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (6 of 7) for time window 31 and …
#>  - getting characteristics from table visit_occurrence (7 of 7)
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#> Formatting result
#> 234 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` cast to character.
#> [2026-07-27 11:04:17] - Population diagnosics - denominator cohort
#> [2026-07-27 11:04:17] - Population diagnosics - sampling person table to 1e+05
#> people
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 3 sec
#> [2026-07-27 11:04:21] - Population diagnosics - incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 9 secs
#> [2026-07-27 11:04:31] - Population diagnosics - prevalence
#> ℹ Getting prevalence for analysis 1 of 7
#> ℹ Getting prevalence for analysis 2 of 7
#> ℹ Getting prevalence for analysis 3 of 7
#> ℹ Getting prevalence for analysis 4 of 7
#> ℹ Getting prevalence for analysis 5 of 7
#> ℹ Getting prevalence for analysis 6 of 7
#> ℹ Getting prevalence for analysis 7 of 7
#> ✔ Time taken: 0 mins and 6 secs
#> `populationDateStart`, `populationDateEnd`, and `populationSample` cast to
#> character.
#> `populationDateStart` and `populationDateEnd` eliminated from settings as all
#> elements are NA.
#> [2026-07-27 11:04:38] - Exporting log file

# }
```
