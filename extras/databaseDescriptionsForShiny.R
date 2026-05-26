library(jsonlite)


spec <- PhenotypeR::dataSourceDescriptionSpecification() |>
  jsonlite::fromJSON(simplifyVector = FALSE)
data_props <- spec$properties$data_collection$properties |>
  names()
omop_props <- spec$properties$omop_standardisation$properties |>
  names()

empty_data_collection <- setNames(as.list(rep( "N/A (synthetic data)", length(data_props))), data_props)
empty_standardisation <- setNames(as.list(rep( "N/A (synthetic data)", length(omop_props))), omop_props)


list(
  administrative_details = list(
    name_of_data_source = "GiBleed synthetic database",
    data_source_acronym = "GiBleed",
    data_source_website = "",
    hma_ema_catalogue = "",
    main_references = ""
  ),
  data_collection = empty_data_collection,
  omop_standardisation = empty_standardisation) |>
  write_json(
    path = here::here("extras", "database_descriptions", "GIBleed.json"),
    pretty = TRUE,
    auto_unbox = TRUE)

list(
  administrative_details = list(
    name_of_data_source = "synput-1k synthetic database",
    data_source_acronym = "synput-1k",
    data_source_website = "",
    hma_ema_catalogue = "",
    main_references = ""
  ),
  data_collection = empty_data_collection,
  omop_standardisation = empty_standardisation) |>
  write_json(
    path = here::here("extras", "database_descriptions", "synput-1k.json"),
    pretty = TRUE,
    auto_unbox = TRUE)

list(
  administrative_details = list(
    name_of_data_source = "synthea-covid19-200k synthetic database",
    data_source_acronym = "synthea-covid19-200k",
    data_source_website = "",
    hma_ema_catalogue = "",
    main_references = ""
  ),
  data_collection = empty_data_collection,
  omop_standardisation = empty_standardisation) |>
  write_json(
    path = here::here("extras", "database_descriptions", "synthea-covid19-200k.json"),
    pretty = TRUE,
    auto_unbox = TRUE)

# check if will pass validation
# importDatabaseDescription(here::here("extras", "database_descriptions"))
