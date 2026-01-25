# mod_scenario_builder.R
# Scenario Builder Module - Analog Selection and Configuration
#
# Purpose: Configure analog selection and scenario parameters
# Primary Persona: Brand VP / Commercial Lead
# This module drives the analysis in other tabs

# ============================================================================
# MODULE UI
# ============================================================================

mod_scenario_builder_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Header
    div(
      style = "margin-bottom: 1.5em;",
      h2(
        style = sprintf("color: %s; margin-bottom: 0.25em;", colors$primary_dark),
        icon("sliders horizontal"),
        "Scenario Builder"
      ),
      p(
        style = sprintf("color: %s;", colors$text_secondary),
        "Configure analog selection criteria and scenario parameters"
      )
    ),
    
    # ========================================================================
    # TWO COLUMN LAYOUT: SELECTION + PREVIEW
    # ========================================================================
    
    div(
      class = "ui two column stackable grid",
      
      # ----------------------------------------------------------------------
      # LEFT COLUMN: Selection Controls
      # ----------------------------------------------------------------------
      
      div(
        class = "six wide column",
        
        # Analog Selection Card
        div(
          class = "ui segment",
          
          h3(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("filter"),
            "Analog Selection Criteria"
          ),
          
          p(
            style = sprintf(
              "color: %s; font-size: 0.9em; margin-bottom: 1.5em;",
              colors$text_muted
            ),
            "Pre-specify inclusion criteria to ensure defensible analog selection"
          ),
          
          # Therapeutic Focus
          h4(
            style = sprintf("color: %s; margin-top: 1em;", colors$text_primary),
            "Therapeutic Focus"
          ),
          div(
            class = "ui form",
            checkboxInput(
              ns("solid_tumors"),
              "Solid Tumors",
              value = TRUE
            ),
            checkboxInput(
              ns("hematology"),
              "Hematology",
              value = TRUE
            )
          ),
          
          # Line of Therapy
          h4(
            style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
            "Line of Therapy"
          ),
          selectInput(
            ns("line_of_therapy"),
            label = NULL,
            choices = c(
              "All Lines" = "all",
              "First Line (1L)" = "1L",
              "Second Line+ (2L+)" = "2L+"
            ),
            selected = "all"
          ),
          
          # Launch Year Range
          h4(
            style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
            "Launch Year Range"
          ),
          sliderInput(
            ns("launch_years"),
            label = NULL,
            min = 2010,
            max = 2024,
            value = c(2015, 2024),
            step = 1,
            sep = ""
          ),
          
          # Minimum Peak Revenue
          h4(
            style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
            "Minimum Peak Revenue"
          ),
          selectInput(
            ns("min_peak"),
            label = NULL,
            choices = c(
              "No minimum" = "0",
              "$100M+" = "100",
              "$500M+" = "500",
              "$1B+" = "1000"
            ),
            selected = "100"
          ),
          
          # Apply button
          div(
            style = "margin-top: 2em;",
            actionButton(
              ns("apply_filters"),
              "Apply Selection",
              class = "ui primary button",
              style = sprintf("background: %s;", colors$primary)
            )
          )
        ),
        
        # Scenario Parameters Card
        div(
          class = "ui segment",
          style = "margin-top: 1.5em;",
          
          h3(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("cogs"),
            "Scenario Parameters"
          ),
          
          # Launch Delay
          h4(
            style = sprintf("color: %s; margin-top: 1em;", colors$text_primary),
            "Launch Delay (months)"
          ),
          sliderInput(
            ns("delay_months"),
            label = NULL,
            min = 0,
            max = 12,
            value = 0,
            step = 3
          ),
          
          # Market Access
          h4(
            style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
            "Market Access Scenario"
          ),
          radioButtons(
            ns("market_access"),
            label = NULL,
            choices = c(
              "Favorable (rapid formulary)" = "favorable",
              "Base (typical timeline)" = "base",
              "Challenging (access delays)" = "challenging"
            ),
            selected = "base"
          ),
          
          # Competitive Intensity
          h4(
            style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
            "Competitive Intensity"
          ),
          radioButtons(
            ns("competitive"),
            label = NULL,
            choices = c(
              "Low (limited competition)" = "low",
              "Moderate (2-3 competitors)" = "moderate",
              "High (crowded market)" = "high"
            ),
            selected = "moderate"
          )
        )
      ),
      
      # ----------------------------------------------------------------------
      # RIGHT COLUMN: Preview and Summary
      # ----------------------------------------------------------------------
      
      div(
        class = "ten wide column",
        
        # Selected Analogs Preview
        div(
          class = "ui segment",
          
          h3(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("list"),
            "Selected Analogs"
          ),
          
          # Count badge
          div(
            style = "margin-bottom: 1em;",
            uiOutput(ns("analog_count_badge"))
          ),
          
          # Analog checklist
          div(
            style = "max-height: 400px; overflow-y: auto;",
            uiOutput(ns("analog_checklist"))
          )
        ),
        
        # Selection Rationale
        div(
          class = "ui segment",
          style = sprintf(
            "margin-top: 1.5em; border-left: 3px solid %s;",
            colors$secondary
          ),
          
          h4(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("clipboard check"),
            "Selection Rationale"
          ),
          
          p(
            style = sprintf("color: %s; font-size: 0.9em;", colors$text_secondary),
            uiOutput(ns("selection_rationale"), inline = TRUE)
          ),
          
          # Governance note
          div(
            style = sprintf(
              "margin-top: 1em; padding: 0.75em; background: %s; border-radius: 4px;",
              colors$background
            ),
            p(
              style = sprintf("color: %s; font-size: 0.85em; margin: 0;", colors$text_muted),
              icon("info circle"),
              " ",
              strong("Governance Note: "),
              "Analog selection criteria should be documented and approved ",
              "before reviewing outcome data. This separation ensures defensible analysis."
            )
          )
        )
      )
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

mod_scenario_builder_server <- function(id, app_data, shared) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ========================================================================
    # REACTIVE: Filtered Analogs
    # ========================================================================
    
    filtered_analogs <- reactive({
      
      if (app_data$is_placeholder) {
        return(data.frame(
          product_name = character(),
          company = character(),
          approval_date = as.Date(character()),
          indication = character(),
          tumor_type = character(),
          line_of_therapy = character()
        ))
      }
      
      # Start with all analogs
      result <- app_data$analogs
      
      # Filter by tumor type
      if (!input$solid_tumors && !input$hematology) {
        # If nothing selected, show nothing
        result <- result |> filter(FALSE)
      } else if (!input$solid_tumors) {
        result <- result |> filter(tumor_type == "Hematology")
      } else if (!input$hematology) {
        result <- result |> filter(tumor_type == "Solid")
      }
      
      # Filter by line of therapy
      if (input$line_of_therapy != "all") {
        result <- result |> filter(line_of_therapy == input$line_of_therapy)
      }
      
      # Filter by launch year
      # result <- result |>
      #   filter(
      #     year(approval_date) >= input$launch_years[1],
      #     year(approval_date) <= input$launch_years[2]
      #   )
      
      result
    })
    
    # ========================================================================
    # OBSERVE: Apply Filters Button
    # ========================================================================
    
    observeEvent(input$apply_filters, {
      # Update shared reactive values
      shared$selected_analogs <- filtered_analogs()$product_name
      
      shared$scenario_config <- list(
        delay_months = input$delay_months,
        market_access_scenario = input$market_access,
        competitive_intensity = input$competitive
      )
    })
    
    # ========================================================================
    # OUTPUT: Analog Count Badge
    # ========================================================================
    
    output$analog_count_badge <- renderUI({
      n <- nrow(filtered_analogs())
      
      badge_color <- if (n == 0) {
        colors$danger
      } else if (n < 5) {
        colors$warning
      } else {
        colors$success
      }
      
      div(
        style = sprintf(
          "display: inline-block; padding: 0.5em 1em; background: %s; color: white; border-radius: 4px;",
          badge_color
        ),
        sprintf("%d analogs match criteria", n)
      )
    })
    
    # ========================================================================
    # OUTPUT: Analog Checklist
    # ========================================================================
    
    output$analog_checklist <- renderUI({
      
      analogs <- filtered_analogs()
      
      if (nrow(analogs) == 0) {
        return(
          div(
            style = sprintf("color: %s; padding: 2em; text-align: center;", colors$text_muted),
            icon("exclamation triangle"),
            " No analogs match current criteria. Adjust filters."
          )
        )
      }
      
      # Create checklist
      tagList(
        lapply(seq_len(nrow(analogs)), function(i) {
          product <- analogs[i, ]
          
          div(
            style = sprintf(
              "padding: 0.75em; border-bottom: 1px solid %s; display: flex; align-items: center;",
              colors$border
            ),
            
            # Checkbox
            div(
              style = "margin-right: 1em;",
              checkboxInput(
                ns(paste0("analog_", i)),
                label = NULL,
                value = TRUE
              )
            ),
            
            # Product info
            div(
              style = "flex: 1;",
              div(
                style = sprintf("font-weight: bold; color: %s;", colors$text_primary),
                product$product_name
              ),
              div(
                style = sprintf("font-size: 0.85em; color: %s;", colors$text_secondary),
                paste0(product$company, " | ", product$indication)
              )
            )
          )
        })
      )
    })
    
    # ========================================================================
    # OUTPUT: Selection Rationale
    # ========================================================================
    
    output$selection_rationale <- renderUI({
      n <- nrow(filtered_analogs())
      
      if (n == 0) {
        return("No analogs selected. Adjust criteria above.")
      }
      
      # Build rationale text
      criteria <- c()
      
      if (input$solid_tumors && input$hematology) {
        criteria <- c(criteria, "all tumor types")
      } else if (input$solid_tumors) {
        criteria <- c(criteria, "solid tumors only")
      } else if (input$hematology) {
        criteria <- c(criteria, "hematology only")
      }
      
      if (input$line_of_therapy != "all") {
        criteria <- c(criteria, paste0(input$line_of_therapy, " setting"))
      }
      
      criteria <- c(criteria, paste0(
        "launched ", input$launch_years[1], "-", input$launch_years[2]
      ))
      
      if (input$min_peak != "0") {
        criteria <- c(criteria, paste0(
          "peak revenue ≥$", input$min_peak, "M"
        ))
      }
      
      paste0(
        "Selection includes ", n, " oncology products meeting criteria: ",
        paste(criteria, collapse = ", "), ". ",
        "This analog set informs the P25/P50/P75 scenario bounds."
      )
    })
    
  })
}
