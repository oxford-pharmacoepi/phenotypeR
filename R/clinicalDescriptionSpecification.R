#' Clinical description specification
#'
#' @param path If NULL, specification will be returned as an R object. If a
#' path to a directory is provided the specification will be exported.
#'
#' @returns JSON specification for clinical descriptions
#' @export
clinicalDescriptionSpecification <- function(path = NULL){

  clinical_description_spec <- defineClinicalSpec()

  if(!is.null(path)){
    jsonlite::write_json(
      clinical_description_spec,
      path = here::here("inst", "clinical_specification.json"),
      auto_unbox = TRUE,
      pretty = TRUE)
  }

  jsonlite::toJSON(
    clinical_description_spec,
    auto_unbox = TRUE,
    pretty = TRUE
  )
}

defineClinicalSpec <- function() {
  list(
    title = "Clinical Description",
    description = "A clinical description to inform development of computable phenotypes using real world health data.",
    type = "object",
    properties = list(

      metadata = list(
        type = "object",
        description = "Information on the provenance of clinical description.",
        properties = list(
          phenotype_name = list(
            type = "string",
            description = "The name of the phenotype the clinical description is for."
          ),
          version = list(
            type = "string",
            description = "The version number or identifier of this clinical profile document."
          ),
          created_by = list(
            type = "string",
            description = "The name or identifier of the person/ tool."
          ),
          created_date = list(
            type = "string",
            format = "date",
            description = "The date this clinical profile was originally generated, formatted as YYYY-MM-DD."
          ),
          last_edited_by = list(
            type = "string",
            description = "The name or identifier of person/ tool that most recently modified the description."
          ),
          last_edited_date = list(
            type = "string",
            format = "date",
            description = "The date this clinical profile was most recently modified, formatted as YYYY-MM-DD."
          ),
          source_of_information = list(
            type = "string",
            description = "The references, literature, or data sources used to compile this clinical profile."
          )
        ),
        required = c(
          "phenotype_name",
          "version",
          "created_by",
          "created_date",
          "last_edited_by",
          "last_edited_date",
          "source_of_information"
        ),
        additionalProperties = FALSE
      ),

      clinical_profile = list(
        type = "object",
        description = "The core clinical and epidemiological data.",
        properties = list(
          introduction_synonyms = list(
            type = "string",
            description = "A high-level description of the condition, including commonly used synonyms in the medical literature and by medical professionals."
          ),
          clinical_presentation_and_symptoms = list(
            type = "string",
            description = "A summary of the typical clinical presentation and associated symptoms."
          ),
          assessment_diagnosis = list(
            type = "string",
            description = "An explanation of how patients are assessed and how the diagnosis is made."
          ),
          therapeutic_plan_treatment = list(
            type = "string",
            description = "A description of the typical therapeutic or treatment plan."
          ),
          complications_prognosis = list(
            type = "string",
            description = "A summary of common complications and the prognosis for patients."
          ),
          disqualifiers = list(
            type = "string",
            description = "An explanation of disqualifiers and differential diagnoses considered by medical professionals."
          ),
          epidemiology = list(
            type = "string",
            description = "A summary of the known epidemiology, including prevalence, risk factors, and comorbidities."
          )
        ),
        required = c(
          "introduction_synonyms",
          "clinical_presentation_and_symptoms",
          "epidemiology",
          "assessment_diagnosis",
          "therapeutic_plan_treatment",
          "complications_prognosis",
          "disqualifiers"
        ),
        additionalProperties = FALSE
      )
    ),
    required = c("metadata", "clinical_profile"),
    additionalProperties = FALSE
  )
}
