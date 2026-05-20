library(shiny)
library(bslib)
library(jsonlite)
library(jsonvalidate)
library(officer)
library(tools)
library(shinyjs)

get_label_text <- function(id) {
  switch(id,
         "hma_ema_catalogue" = "HMA-EMA catalogue entry",
         "healthcare_setting_type_of_data" = "Healthcare setting / type of data",
         "omop_mapping" = "Mapping to the OMOP Common Data Model",
         "omop_quality_control" = "Data quality control for OMOP Common Data Model mapping",
         stringr::str_to_sentence(gsub("_", " ", id)))
}
create_label_ui <- function(id, description) {
  shiny::tags$span(
    get_label_text(id),
    bslib::tooltip(shiny::icon("info-circle"), description)
  )
}

db_spec <- PhenotypeR::dataSourceDescriptionSpecification() |>
  jsonlite::fromJSON(simplifyVector = FALSE)

db_admin <- db_spec$properties$administrative_details$properties
db_data_collection <- db_spec$properties$data_collection$properties
db_omop_standardisation <- db_spec$properties$omop_standardisation$properties

db_admin_ui <- lapply(names(db_admin), function(id) {
  prop <- db_admin[[id]]
  label_ui <- create_label_ui(id, prop$description)

  if (id == "main_references") {
    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 3, width = "100%", autoresize = TRUE)
    )
  } else {
    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 1, width = "100%", autoresize = TRUE)
    )
  }
})
db_data_collection_ui <- lapply(names(db_data_collection), function(id) {
  prop <- db_data_collection[[id]]
  label_ui <- create_label_ui(id, prop$description)

    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 5, width = "100%", autoresize = TRUE)
    )
})
db_omop_standardisation_ui <- lapply(names(db_omop_standardisation), function(id) {
  prop <- db_omop_standardisation[[id]]
  label_ui <- create_label_ui(id, prop$description)

  bslib::card(
    full_screen = TRUE,
    class = "expandable-card",
    shiny::textAreaInput(id, label_ui, rows = 5, width = "100%", autoresize = TRUE)
  )
})
