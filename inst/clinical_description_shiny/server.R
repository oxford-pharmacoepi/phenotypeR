server <- function(input, output, session) {

  required_metadata <- unlist(clinical_description_spec$properties$metadata$required)
  required_clinical <- unlist(clinical_description_spec$properties$clinical_profile$required)
  all_clinical_fields <- c(required_metadata, required_clinical)

  clinical_labels <- sapply(all_clinical_fields, get_label_text)
  names(clinical_labels) <- all_clinical_fields

  clinical_missing <- shiny::reactive({
    all_clinical_fields[vapply(all_clinical_fields, function(id) {
      val <- input[[id]]
      if (is.null(val) || length(val) == 0) return(TRUE)
      if (is.character(val) && all(trimws(val) == "")) return(TRUE)
      if (any(is.na(val))) return(TRUE)
      return(FALSE)
    }, logical(1))]
  })

  output$dynamic_css <- shiny::renderUI({
    missing <- c(clinical_missing())
    if (length(missing) > 0) {
      css_rules <- paste0(
        "input#", missing, ", textarea#", missing, ", div#", missing, " input { ",
        "background-color: #ffe6e6 !important; border-color: #dc3545 !important; ",
        "}",
        collapse = "\n"
      )
      shiny::tags$style(shiny::HTML(css_rules))
    }
  })

  shiny::observeEvent(input$upload_json, {
    shiny::req(input$upload_json)

    tryCatch({
      validate <- jsonvalidate::json_validate(
        input$upload_json$datapath,
        PhenotypeR::clinicalDescriptionSpecification(),
        verbose = TRUE,
        error = TRUE)
      
      uploaded_values <- jsonlite::fromJSON(input$upload_json$datapath) |>
        purrr::flatten()
      id_to_update <- names(uploaded_values)
      
      for (id in id_to_update) {
        val <- uploaded_values[[id]]
        if (!is.null(val) && length(val) > 0) {
          shiny::updateTextInput(session, inputId = id, value = val)
          shiny::updateTextAreaInput(session, inputId = id, value = val)
          if (grepl("^\\d{4}-\\d{2}-\\d{2}$", as.character(val))) {
            shiny::updateDateInput(session, inputId = id, value = val)
          }
        }
      }
      
      shiny::showNotification("Data successfully loaded from JSON", type = "message")
      
    }, error = function(e) {
      shiny::showNotification(paste("Failed to parse JSON:", e$message), type = "error")
    })
  })
  
  
  output$clinical_download_section <- shiny::renderUI({
    missing <- clinical_missing()

    if (length(missing) == 0) {
      shiny::div(
        class = "d-flex gap-2",
        shiny::downloadButton("download_clinical_json", "Download JSON", class = "btn-primary")
      )
    } else {
      missing_names <- paste(clinical_labels[missing], collapse = ", ")
      shiny::tagList(
        shiny::div(
          class = "d-flex gap-2",
          shiny::actionButton("disabled_clinical_json", "Download JSON", class = "btn-secondary disabled")        ),
        shiny::p(paste("Please fill in the following missing required fields to enable downloads:", missing_names), class = "text-danger mt-2 fw-bold")
      )
    }
  })

  output$download_clinical_json <- shiny::downloadHandler(
    filename = function() {
      paste0("clinical_description_", Sys.Date(), ".json")
    },
    content = function(file) {
      shiny::req(length(clinical_missing()) == 0)

      export_data <- list(
        metadata = stats::setNames(lapply(names(metadata_props), function(id) {
          if (!is.null(metadata_props[[id]]$format) && metadata_props[[id]]$format == "date") {
            as.character(input[[id]])
          } else {
            input[[id]]
          }
        }), names(metadata_props)),
        clinical_profile = stats::setNames(lapply(names(clinical_props), function(id) {
          input[[id]]
        }), names(clinical_props))
      )

      jsonlite::write_json(
        export_data,
        file,
        auto_unbox = TRUE,
        pretty = TRUE
      )
    }
  )


  shiny::observeEvent(input$draft_with_ai, {

    if (input$phenotype_name == "") {
      shiny::showNotification("Phenotype name must be provided", type = "error", duration = 5)
      return()
    }

    if (is.null(chat)) {
      shiny::showNotification(
        "No LLM available. Run app locally using PhenotypeR::draftClinicalDescription() and create ellmer chat object in global.R to use this functionality",
        type = "error",
        duration = 10
      )
      return()
    }

    shinyjs::disable("draft_with_ai")
    shiny::showModal(
      shiny::modalDialog(
        title = "Drafting with AI",
        shiny::div(
          class = "d-flex align-items-center gap-3",
          shiny::icon("spinner", class = "fa-spin fa-2x text-primary"),
          shiny::span("Please wait while LLM generates the clinical description",
                      class = "fs-5")
        ),
        footer = NULL,
        easyClose = FALSE
      )
    )

    on.exit({
      shinyjs::enable("draft_with_ai")
      shiny::removeModal()
    })

    tmp <- file.path(tempdir(), omopgenerics::uniqueTableName())
    dir.create(tmp)

    PhenotypeR::draftClinicalDescription(chat,
                                       name = input$phenotype_name,
                                       outputDir = tmp)

    clinical_description <- PhenotypeR:::importClinicalDescription(path = tmp)

    for (i in seq_along(names(clinical_description[[1]]$clinical_profile))) {
      shiny::updateTextAreaInput(
        session = session,
        inputId = names(clinical_description[[1]]$clinical_profile[i]),
        value = clinical_description[[1]]$clinical_profile[[i]]
      )
    }

    for (i in seq_along(names(clinical_description[[1]]$metadata))) {
      shiny::updateTextAreaInput(
        session = session,
        inputId = names(clinical_description[[1]]$metadata[i]),
        value = clinical_description[[1]]$metadata[[i]]
      )
    }
  })

}
