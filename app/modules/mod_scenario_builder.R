# mod_scenario_builder.R
# Scenario Builder Module - Analog Selection and Delay Configuration
#
# Purpose: Configure analog selection and launch delay scenarios
# Primary Decision: "What is the revenue-at-risk if launch timing shifts?"
#
# Design Principle: Implement only what the decision requires
# - Delay modeling: YES (core decision support)
# - Market access: DEFERRED (assumption-heavy)
# - Competition caps: DEFERRED (overreach)

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
        "Configure analog selection criteria and delay scenarios"
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
            style = "margin-bottom: 1em;",
            checkboxInput(
              ns("solid_tumors"),
              "Solid Tumors",
              value = TRUE,
              width = "100%"
            ),
            checkboxInput(
              ns("hematology"),
              "Hematology",
              value = TRUE,
              width = "100%"
            )
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
              "$500M+" = "500",
              "$1B+" = "1000",
              "$2B+" = "2000",
              "$3B+" = "3000"
            ),
            selected = "0",
            width = "100%"
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
        
        # ================================================================
        # DELAY SCENARIO CARD - Core Decision Support
        # ================================================================
        div(
          class = "ui segment",
          style = "margin-top: 1.5em;",
          
          h3(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("clock outline"),
            "Launch Delay Scenario"
          ),
          
          p(
            style = sprintf("color: %s; font-size: 0.85em; margin-bottom: 1em;", colors$text_muted),
            "Model the revenue impact of launch timing delays"
          ),
          
          # Delay in quarters (integer shifts only)
          h4(
            style = sprintf("color: %s; margin-top: 1em;", colors$text_primary),
            "Launch Delay (quarters)"
          ),
          sliderInput(
            ns("delay_quarters"),
            label = NULL,
            min = 0,
            max = 4,
            value = 2,
            step = 1,
            width = "100%",
            ticks = TRUE
          ),
          
          # Revenue at risk output
          div(
            style = sprintf(
              "margin-top: 1.5em; padding: 1em; background: %s; border-radius: 4px; border-left: 3px solid %s;",
              colors$background, colors$warning
            ),
            h4(
              style = sprintf("color: %s; margin: 0 0 0.5em 0;", colors$warning),
              "Revenue at Risk (Year 1-3)"
            ),
            div(
              style = sprintf("font-size: 1.8em; font-weight: bold; color: %s;", colors$primary),
              uiOutput(ns("revenue_at_risk_display"), inline = TRUE)
            ),
            p(
              style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.5em; margin-bottom: 0;", colors$text_muted),
              "Cumulative revenue foregone in first 3 years"
            )
          ),
          
          # Methodology note - THE PROTECTIVE SENTENCE
          div(
            style = sprintf(
              "margin-top: 1em; padding: 0.75em; background: %s; border-radius: 4px;",
              colors$background
            ),
            p(
              style = sprintf("color: %s; font-size: 0.8em; margin: 0; line-height: 1.5;", colors$text_muted),
              icon("info circle"),
              " This model evaluates the impact of launch timing delays assuming ",
              strong("demand is deferred, not destroyed"), 
              ". Competitive dynamics and access restrictions are excluded by design."
            )
          )
        ),
        
        # ================================================================
        # FUTURE ENHANCEMENTS NOTE (Deferred features)
        # ================================================================
        div(
          class = "ui segment",
          style = sprintf("margin-top: 1.5em; opacity: 0.7; border-left: 3px solid %s;", colors$text_muted),
          
          h4(
            style = sprintf("color: %s; margin-bottom: 0.5em;", colors$text_muted),
            icon("road"),
            "Future Enhancements"
          ),
          p(
            style = sprintf("color: %s; font-size: 0.85em; margin-bottom: 0.5em;", colors$text_muted),
            "The following scenario parameters are documented for potential extension:"
          ),
          tags$ul(
            style = sprintf("color: %s; font-size: 0.85em; margin: 0; padding-left: 1.5em;", colors$text_muted),
            tags$li("Market access curve adjustments (requires payer mix assumptions)"),
            tags$li("Competitive intensity caps (requires class-level forecasting)")
          ),
          p(
            style = sprintf("color: %s; font-size: 0.8em; font-style: italic; margin-top: 0.75em; margin-bottom: 0;", colors$text_muted),
            "These are excluded to maintain assumption transparency."
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
          
          # Count badge and status indicator
          div(
            style = "margin-bottom: 1em; display: flex; align-items: center; gap: 1em; flex-wrap: wrap;",
            uiOutput(ns("analog_count_badge")),
            uiOutput(ns("selection_status"))
          ),
          
          # Analog table
          reactableOutput(ns("analog_preview_table"))
        ),
        
        # Selection Rationale
        div(
          class = "ui segment",
          style = sprintf(
            "margin-top: 1.5em; border-left: 3px solid %s;",
            colors$primary
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
    # REACTIVE: Filtered Analogs (handles NULL inputs gracefully)
    # ========================================================================
    
    filtered_analogs <- reactive({
      # Depend on startup trigger to force initial evaluation
      shared$startup_trigger
      
      if (app_data$is_placeholder) {
        return(data.frame(
          product_name = character(),
          company = character(),
          approval_date = character(),
          indication = character(),
          tumor_class = character(),
          peak_revenue_millions = numeric()
        ))
      }
      
      # Safe defaults if inputs don't exist yet (NULL = use default)
      solid <- if (is.null(input$solid_tumors)) TRUE else input$solid_tumors
      heme <- if (is.null(input$hematology)) TRUE else input$hematology
      min_peak_val <- if (is.null(input$min_peak)) "0" else input$min_peak
      
      result <- app_data$analogs
      
      # Filter by tumor class
      if (!solid && !heme) {
        result <- result[0, ]
      } else if (solid && !heme) {
        result <- result[result$tumor_class == "Solid", ]
      } else if (!solid && heme) {
        result <- result[result$tumor_class == "Heme", ]
      }
      
      # Filter by peak revenue
      if (nrow(result) > 0 && "peak_revenue_millions" %in% names(result) && min_peak_val != "0") {
        min_revenue <- as.numeric(min_peak_val)
        result <- result[result$peak_revenue_millions >= min_revenue, ]
      }
      
      result[!duplicated(result$product_name), ]
    })
    
    # ========================================================================
    # REACTIVE: Revenue at Risk Calculation
    # ========================================================================
    
    revenue_at_risk <- reactive({
      delay_q <- input$delay_quarters
      if (is.null(delay_q) || delay_q == 0) return(0)
      
      if (app_data$is_placeholder) return(0)
      
      # Get curves for selected analogs
      curves <- app_data$curves
      if (is.null(curves) || nrow(curves) == 0) return(0)
      
      # Use selected analogs, or default to all analogs if NULL (initial load)
      selected_products <- if (is.null(shared$selected_analogs)) {
        app_data$analogs$product_name
      } else {
        shared$selected_analogs
      }
      
      selected_curves <- curves[curves$product_name %in% selected_products, ]
      if (nrow(selected_curves) == 0) return(0)
      
      # Calculate median revenue by year
      yearly_median <- aggregate(
        revenue_millions ~ years_since_launch,
        data = selected_curves,
        FUN = median
      )
      
      # Years 0-3 cumulative revenue (base case)
      base_years <- yearly_median[yearly_median$years_since_launch <= 3, ]
      
      # Delay shifts revenue - calculate lost quarters
      
      # Each quarter delay = ~1/4 of first year revenue lost + ripple effect
      # Simplified: delay_q quarters loses approximately (delay_q/4) * Year1 revenue
      
      if (nrow(base_years) == 0) return(0)
      
      year1_revenue <- base_years$revenue_millions[base_years$years_since_launch == 1]
      if (length(year1_revenue) == 0) year1_revenue <- base_years$revenue_millions[1]
      
      # Revenue at risk = delay quarters * (Year 1 revenue / 4)
      # This is a simplification: assumes linear quarterly accrual
      risk <- delay_q * (year1_revenue / 4)
      
      round(risk, 0)
    })
    
    # ========================================================================
    # OBSERVE: Apply Filters + Delay
    # ========================================================================
    
    observeEvent(input$apply_filters, {
      new_selection <- filtered_analogs()$product_name
      shared$selected_analogs <- new_selection
      
      # Store delay for Executive Brief
      shared$delay_quarters <- input$delay_quarters
      
      showNotification(
        paste0("Selection applied: ", length(new_selection), " analogs, ",
               input$delay_quarters, " quarter delay"),
        type = "message",
        duration = 3
      )
    })
    
    # Also update delay reactively (without requiring button click)
    observe({
      shared$delay_quarters <- input$delay_quarters
    })
    
    # ========================================================================
    # OUTPUT: Revenue at Risk Display
    # ========================================================================
    
    output$revenue_at_risk_display <- renderUI({
      risk <- revenue_at_risk()
      delay_q <- input$delay_quarters
      
      if (is.null(delay_q) || delay_q == 0) {
        span(
          style = sprintf("color: %s;", colors$text_muted),
          "No delay selected"
        )
      } else if (risk == 0) {
        span(
          style = sprintf("color: %s;", colors$text_muted),
          "Apply selection to calculate"
        )
      } else {
        paste0("$", format(risk, big.mark = ","), "M")
      }
    })
    
    # ========================================================================
    # OUTPUT: Analog Count Badge
    # ========================================================================
    
    output$analog_count_badge <- renderUI({
      # Force dependency
      shared$startup_trigger
      
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
    # OUTPUT: Selection Status
    # ========================================================================
    
    output$selection_status <- renderUI({
      # Force dependency
      shared$startup_trigger
      
      current_filtered <- filtered_analogs()$product_name
      applied <- shared$selected_analogs
      
      if (is.null(applied)) {
        div(
          style = sprintf(
            "display: inline-block; padding: 0.4em 0.8em; background: %s; color: white; border-radius: 4px; font-size: 0.85em;",
            colors$warning
          ),
          icon("exclamation triangle"),
          " Click 'Apply Selection'"
        )
      } else if (setequal(current_filtered, applied)) {
        div(
          style = sprintf(
            "display: inline-block; padding: 0.4em 0.8em; background: %s; color: white; border-radius: 4px; font-size: 0.85em;",
            colors$success
          ),
          icon("check"),
          " Selection applied"
        )
      } else {
        div(
          style = sprintf(
            "display: inline-block; padding: 0.4em 0.8em; background: %s; color: white; border-radius: 4px; font-size: 0.85em;",
            colors$warning
          ),
          icon("sync"),
          " Changes pending"
        )
      }
    })
    
    # ========================================================================
    # OUTPUT: Analog Preview Table
    # ========================================================================
    
    output$analog_preview_table <- renderReactable({
      # Force dependency on trigger and inputs directly
      shared$startup_trigger
      input$solid_tumors
      input$hematology
      input$min_peak
      
      analogs <- filtered_analogs()
      
      # Show message if no data
      if (is.null(analogs) || nrow(analogs) == 0) {
        return(
          reactable(
            data.frame(
              Message = "No analogs match current criteria. Adjust filters above."
            ),
            theme = reactableTheme(
              cellStyle = list(
                color = colors$text_muted, 
                textAlign = "center",
                padding = "2em"
              )
            )
          )
        )
      }
      
      # Format peak revenue - show in billions if > 1000M, otherwise millions
      format_revenue <- function(x) {
        if (x >= 1000) {
          paste0("$", round(x / 1000, 1), "B")
        } else {
          paste0("$", round(x), "M")
        }
      }
      
      display_data <- data.frame(
        Product = analogs$product_name,
        Company = analogs$company,
        `Tumor Type` = analogs$tumor_class,
        `Peak (Annual)` = sapply(analogs$peak_revenue_millions, format_revenue),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
      
      reactable(
        display_data,
        searchable = FALSE,
        pagination = FALSE,
        striped = TRUE,
        highlight = TRUE,
        compact = TRUE,
        theme = reactableTheme(
          headerStyle = list(
            background = colors$background,
            color = colors$text_primary,
            fontWeight = "bold"
          ),
          stripedColor = colors$background
        ),
        columns = list(
          Product = colDef(minWidth = 100),
          Company = colDef(minWidth = 100),
          `Tumor Type` = colDef(
            minWidth = 80,
            align = "center",
            cell = function(value) {
              badge_color <- if (value == "Solid") colors$primary else colors$secondary
              htmltools::div(
                style = sprintf(
                  "display: inline-block; padding: 2px 8px; background: %s; color: white; border-radius: 3px; font-size: 0.85em;",
                  badge_color
                ),
                value
              )
            }
          ),
          `Peak (Annual)` = colDef(minWidth = 100, align = "right")
        )
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
      
      criteria <- c()
      
      solid <- if (is.null(input$solid_tumors)) TRUE else input$solid_tumors
      heme <- if (is.null(input$hematology)) TRUE else input$hematology
      min_peak_val <- if (is.null(input$min_peak)) "0" else input$min_peak
      delay_q <- if (is.null(input$delay_quarters)) 2 else input$delay_quarters
      
      if (solid && heme) {
        criteria <- c(criteria, "all tumor types")
      } else if (solid) {
        criteria <- c(criteria, "solid tumors only")
      } else if (heme) {
        criteria <- c(criteria, "hematology only")
      }
      
      if (min_peak_val != "0") {
        # Format the threshold nicely
        min_val <- as.numeric(min_peak_val)
        if (min_val >= 1000) {
          criteria <- c(criteria, paste0("peak revenue ≥$", min_val/1000, "B"))
        } else {
          criteria <- c(criteria, paste0("peak revenue ≥$", min_val, "M"))
        }
      }
      
      delay_text <- if (delay_q > 0) {
        paste0(" Delay scenario: ", delay_q, " quarter(s).")
      } else {
        ""
      }
      
      paste0(
        "Selection includes ", n, " oncology products meeting criteria: ",
        paste(criteria, collapse = ", "), ".",
        delay_text,
        " This analog set informs the P25/P50/P75 scenario bounds."
      )
    })
    
  })
}