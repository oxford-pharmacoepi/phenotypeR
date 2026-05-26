
#' Data source description specification
#'
#' @param path If NULL, specification will be returned as an R object. If a
#' path to a directory is provided the specification will be exported.
#'
#' @returns JSON specification for data source descriptions
#' @export
dataSourceDescriptionSpecification <- function(path = NULL){

  database_description_spec <-  defineDataSourceSpec()

  if(!is.null(path)){
    jsonlite::write_json(
      database_description_spec,
      path = here::here("inst", "data_source_specification.json"),
      auto_unbox = TRUE,
      pretty = TRUE)
  }

  jsonlite::toJSON(
    database_description_spec,
    auto_unbox = TRUE,
    pretty = TRUE
  )
}

defineDataSourceSpec <- function() {
  list(
    title = "Data source description",
    description = "A specification for data source descriptions",
    type = "object",
    properties = list(

      administrative_details = list(
        type = "object",
        description = "Administrative metadata for the data source",
        properties = list(
          name_of_data_source = list(
            type = "string",
            description = "The full name of the data source."
          ),
          data_source_acronym = list(
            type = "string",
            description = "Short abbreviation/ acronym used in studies (e.g. for tables and figures)."
          ),
          data_source_website = list(
            type = "string",
            description = "The URL for the website or webpage dedicated to the data source, if available"
          ),
          hma_ema_catalogue = list(
            type = "string",
            description = "The URL for the webpage of the data source on the HMA-EMA Catalogues of real-world data sources and studies, if available"
          ),
          main_references = list(
            type = "string",
            description = "References to publications describing the data source (e.g. data source profile publications)."
          )
        ),
        required = c("name_of_data_source",
                     "data_source_acronym"),
        additionalProperties = FALSE
      ),

      data_collection = list(
        type = "object",
        description = "Information regarding the types of data captured.",
        properties = list(
          geography = list(
            type = "string",
            description = "The geographical area (e.g. country) covered by the data source"
          ),
          population = list(
            type = "string",
            description = "Information on the population captured by the data source."
          ),
          healthcare_setting_type_of_data = list(
            type = "string",
            description = "The category of data (e.g., Registry, EHR, Claims)."
          ),
          data_collection_process = list(
            type = "string",
            description = "How data is captured"
          ),
          general_representativeness = list(
            type = "string",
            description = "Representativeness of the dataset compared to the underlying population."
          ),
          data_source_coding = list(
            type = "string",
            description = "What data elements are captured and what source vocabularies are used."
          ),
          source_quality_control = list(
            type = "string",
            description = "Summary of quality control processes performed on source data."
          ),
          linkage = list(
            type = "string",
            description = "Description of patient-level linkages for different datasets, if any."
          ),
          mortality = list(
            type = "string",
            description = "How are deaths captured for individuals included in the data source."
          ),
          source_limitations = list(
            type = "string",
            description = "Summary of limitations of the data source."
          )
        ),
        required = c("geography",
                     "population",
                     "healthcare_setting_type_of_data",
                     "data_collection_process",
                     "general_representativeness",
                     "data_source_coding",
                     "source_quality_control",
                     "linkage",
                     "mortality",
                     "source_limitations"),
        additionalProperties = FALSE
      ),

      omop_standardisation = list(
        type = "object",
        description = "Information related to mapping data to the OMOP Common Data Model",
        properties = list(
          omop_mapping = list(
            type = "string",
            description = "Description of process of mapping source data to the OMOP Common Data Model"
          ),
          omop_quality_control = list(
            type = "string",
            description = "Summary of quality control processes performed while mapping to the OMOP Common Data Model and on the mapped data."
          )
        ),
        required = c("omop_mapping",
                     "omop_quality_control"),
        additionalProperties = FALSE
      ),

      required = c("administrative_details", "data_elements_collected", "omop_standardisation")
    )
  )
}
