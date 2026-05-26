server <- function(input, output, session) {

  admin_props <- names(db_spec$properties$administrative_details$properties)
  data_props <- names(db_spec$properties$data_collection$properties)
  omop_props <- names(db_spec$properties$omop_standardisation$properties)

  all_props <- c(admin_props, data_props, omop_props)
  db_props <- stats::setNames(all_props, all_props)

  required_admin <- unlist(db_spec$properties$administrative_details$required)
  required_data_elements <- unlist(db_spec$properties$data_collection$required)
  required_omop_elements <- unlist(db_spec$properties$omop_standardisation$required)

  all_db_fields <- c(required_admin, required_data_elements, required_omop_elements)

  db_labels <- sapply(all_db_fields, get_label_text)
  names(db_labels) <- all_db_fields

  db_missing <- shiny::reactive({
    all_db_fields[vapply(all_db_fields, function(id) {
      val <- input[[id]]
      if (is.null(val) || length(val) == 0) return(TRUE)
      if (is.character(val) && all(trimws(val) == "")) return(TRUE)
      if (any(is.na(val))) return(TRUE)
      return(FALSE)
    }, logical(1))]
  })

  output$dynamic_css <- shiny::renderUI({
    missing <- c(db_missing())
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
        PhenotypeR::dataSourceDescriptionSpecification(),
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

  output$db_download_section <- shiny::renderUI({
    missing <- db_missing()

    if (length(missing) == 0) {
      shiny::div(
        class = "d-flex gap-2",
        shiny::downloadButton("download_db_json", "Download JSON", class = "btn-primary")      )
    } else {
      missing_names <- paste(db_labels[missing], collapse = ", ")
      shiny::tagList(
        shiny::div(
          class = "d-flex gap-2",
          shiny::actionButton("disabled_db_json", "Download JSON", class = "btn-secondary disabled")        ),
        shiny::p(paste("Please fill in the following missing required fields to enable downloads:", missing_names), class = "text-danger mt-2 fw-bold")
      )
    }
  })


  output$download_db_json <- shiny::downloadHandler(
    filename = function() {
      acronym <- input$data_source_acronym

      paste0(acronym, "_", "database_description", ".json")

    },
    content = function(file) {
      shiny::req(length(db_missing()) == 0)

      export_data <- list(
        administrative_details = stats::setNames(lapply(admin_props, function(id) {
          if (is.null(input[[id]])) character(0) else input[[id]]
        }), admin_props),

        data_elements_collected = stats::setNames(lapply(data_props, function(id) {
          if (is.null(input[[id]])) character(0) else input[[id]]
        }), data_props),

        omop_standardisation = stats::setNames(lapply(omop_props, function(id) {
          if (is.null(input[[id]])) character(0) else input[[id]]
        }), omop_props)
      )

      jsonlite::write_json(
        export_data,
        file,
        auto_unbox = TRUE,
        pretty = TRUE
      )
    }
  )

}
