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
    title = "Clinical Description",
    shiny::div(class = "p-3",
               shiny::titlePanel(clinical_description_spec$title),
               shiny::p(clinical_description_spec$description,
                        class = "text-muted mb-4"),
               bslib::accordion(
                 multiple = TRUE,
                 open = c("Phenotype name",
                          "Metadata",
                          "Clinical Profile"),

                 bslib::accordion_panel(
                   title = "Phenotype name",
                   icon = shiny::icon("tags"),
                   metadata_ui[[1]],

                   shiny::div(
                     class = "p-3 mb-4 bg-light border-start border-primary border-4 rounded shadow-sm",

                     shiny::actionButton(
                       inputId = "draft_with_ai",
                       label = "Draft with AI",
                       icon = shiny::icon("wand-magic-sparkles"),
                       class = "btn-primary",
                       style = "margin-bottom: 15px;"
                     ),

                     shiny::uiOutput("ai_draft_message")
                   )

                 ),

                 bslib::accordion_panel(
                   title = "Metadata",
                   icon = shiny::icon("tags"),
                   do.call(bslib::layout_column_wrap, c(list(width = 1/2),
                                                        metadata_ui[-1]))
                 ),

                 bslib::accordion_panel(
                   title = "Clinical Profile",
                   icon = shiny::icon("file-medical"),
                   clinical_ui
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
        
        shiny::uiOutput("clinical_download_section")
    )
  )
)
