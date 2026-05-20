library(shiny)
library(bslib)
library(jsonlite)
library(jsonvalidate)
library(officer)
library(tools)
library(shinyjs)

db_spec <- PhenotypeR::dataSourceDescriptionSpecification() |>
  jsonlite::fromJSON(simplifyVector = FALSE)


get_label_text <- function(id) {
  switch(id,
         tools::toTitleCase(gsub("_", " ", id)))
}
create_label_ui <- function(id, description) {
  shiny::tags$span(
    get_label_text(id),
    bslib::tooltip(shiny::icon("info-circle"), description)
  )
}


db_admin <- db_spec$properties$administrative_details$properties
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

db_data <- db_spec$properties$data_elements_collected$properties
db_data_ui <- lapply(names(db_data), function(id) {
  prop <- db_data[[id]]
  label_ui <- create_label_ui(id, prop$description)

    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 5, width = "100%", autoresize = TRUE)
    )
})
