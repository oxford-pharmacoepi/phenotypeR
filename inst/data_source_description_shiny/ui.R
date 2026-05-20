ui <- bslib::page(

  theme = bslib::bs_theme(version = 5, preset = "lumen"),

  id = "nav",
  fillable = FALSE,

  shiny::tags$head(
    shinyjs::useShinyjs(),
    shiny::uiOutput("dynamic_css"),
    shiny::tags$style("
      .accordion-button:not(.collapsed) {
        background-color: var(--bs-accordion-bg) !important;
        color: var(--bs-accordion-color) !important;
        box-shadow: none !important;
      }
      .accordion-button:focus {
        box-shadow: none !important;
        border-color: rgba(0,0,0,.125) !important;
      }
    ")
  ),
  tags$head(tags$style(HTML("
    /* Hide the text input box from the fileInput */
    .custom-file-btn .form-control {
      display: none !important;
    }
    /* Fix the right-side border radius so the button doesn't look cut off */
    .custom-file-btn .btn-file {
      border-radius: var(--bs-border-radius, 4px) !important;
    }
    /* Remove default bottom margins to match the download button */
    .custom-file-btn .shiny-input-container {
      margin-bottom: 0px !important;
    }
    /* Keep the upload progress bar neatly tucked under the button */
    .custom-file-btn .progress {
      margin-top: 5px !important;
      margin-bottom: 0px !important;
    }
  "))),

  bslib::nav_panel(
    title = "Database Description",
    shiny::div(class = "p-3",
               shiny::titlePanel(db_spec$title),
               shiny::p(db_spec$description,
                        class = "text-muted mb-4"),


               bslib::accordion(
                 multiple = TRUE,
                 open = c("Administrative details",
                          "Data collected",
                          "OMOP CDM mapping"),

                 bslib::accordion_panel(
                   title = "Administrative details",
                   icon = shiny::icon("file-medical"),
                   db_admin_ui
                 ),

                 bslib::accordion_panel(
                   title = "Data collected",
                   icon = shiny::icon("file-medical"),
                   db_data_collection_ui
                 ),

                 bslib::accordion_panel(
                   title = "OMOP CDM mapping",
                   icon = shiny::icon("file-medical"),
                   db_omop_standardisation_ui
                 )
               )
    ),

    div(style = "display: flex; gap: 10px; align-items: flex-start;",

        div(class = "custom-file-btn",
            fileInput(
              inputId = "upload_json",
              label = NULL,
              buttonLabel = "Upload JSON",
              width = "auto"
            )
        ),

        shiny::uiOutput("db_download_section")
    ),

  )
)
