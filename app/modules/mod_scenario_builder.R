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
    # Header with help icon
    div(
      style = "margin-bottom: 1.5em;",
      div(
        style = "display: flex; justify-content: space-between; align-items: flex-start;",
        div(
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
        # Help icon button
        tags$button(
          class = "ui circular icon button basic",
          style = "margin-top: 0.25em;",
          onclick = sprintf("$('#%s').modal('show');", ns("help_modal")),
          icon("question circle outline", style = "font-size: 1.2em;")
        )
      )
    ),
    
    # Help Modal
    div(
      id = ns("help_modal"),
      class = "ui modal small",
      
      div(class = "header", 
          icon("question circle"),
          " How to Use Scenario Builder"),
      
      div(
        class = "content",
        
        h4(style = sprintf("color: %s;", colors$primary_dark), "Purpose"),
        p("Configure which analog products to include in your analysis and model the impact of launch timing delays."),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Steps"),
        tags$ol(
          style = sprintf("color: %s; line-height: 1.8;", colors$text_secondary),
          tags$li(tags$strong("Set Therapeutic Focus"), " - Check/uncheck Solid Tumors and Hematology to filter by tumor type"),
          tags$li(tags$strong("Set Minimum Peak Revenue"), " - Filter to analogs above a revenue threshold"),
          tags$li(tags$strong("Click 'Apply Selection'"), " - Confirms your analog set and syncs to Executive Brief"),
          tags$li(tags$strong("Adjust Launch Delay"), " - Use the slider to model 0-4 quarters of delay"),
          tags$li(tags$strong("Review Revenue at Risk"), " - See cumulative revenue impact of the delay")
        ),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Tips"),
        tags$ul(
          style = sprintf("color: %s;", colors$text_muted),
          tags$li("The table shows a ", tags$strong("preview"), " of matching analogs"),
          tags$li("Orange 'Changes pending' badge means you've changed filters but haven't applied"),
          tags$li("Green 'Selection applied' badge means Executive Brief reflects your choices"),
          tags$li("Use the ", tags$strong("Sensitivity Check"), " to test if results are driven by the top-performing analog (by peak revenue)")
        )
      ),
      
      div(
        class = "actions",
        div(
          class = "ui primary button",
          onclick = sprintf("$('#%s').modal('hide');", ns("help_modal")),
          "Got it"
        )
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
          
          # Sensitivity Check (P1)
          div(
            style = sprintf(
              "margin-top: 1.5em; padding: 1em; background: %s; border-radius: 4px; border: 1px dashed %s;",
              colors$background, colors$border
            ),
            h4(
              style = sprintf("color: %s; margin: 0 0 0.75em 0; font-size: 0.95em;", colors$text_primary),
              icon("flask"),
              " Sensitivity Check"
            ),
            checkboxInput(
              ns("exclude_top_analog"),
              label = span(
                "Exclude top analog (by peak revenue)",
                tags$br(),
                tags$small(
                  style = sprintf("color: %s; font-weight: normal;", colors$text_muted),
                  "Test if results are driven by outlier"
                )
              ),
              value = FALSE,
              width = "100%"
            )
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
              "Revenue at Risk (Year 1)"
            ),
            div(
              style = sprintf("font-size: 1.8em; font-weight: bold; color: %s;", colors$primary),
              uiOutput(ns("revenue_at_risk_display"), inline = TRUE)
            ),
            p(
              style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.5em; margin-bottom: 0;", colors$text_muted),
              "Revenue foregone in first year post-launch"
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
      
      # P1: Sensitivity check - exclude top analog if requested
      exclude_top <- if (is.null(input$exclude_top_analog)) FALSE else input$exclude_top_analog
      if (exclude_top && nrow(result) > 0) {
        # Find and exclude the highest peak revenue analog
        top_analog <- result$product_name[which.max(result$peak_revenue_millions)]
        result <- result[result$product_name != top_analog, ]
      }
      
      result[!duplicated(result$product_name), ]
    })
    
    # ========================================================================
    # EAGER EVALUATION - Force table to render on startup ONLY
    # ========================================================================
    
    # Use observeEvent with once=TRUE to only fire at startup
    observeEvent(shared$startup_trigger, {
      # Force evaluation of filtered_analogs (this makes it "hot")
      # isolate() prevents this observe from re-running on filter changes
      isolate({
        fa <- filtered_analogs()
      })
    }, once = TRUE, ignoreInit = FALSE)
    
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
      
      # Handle NULL or empty cases
      if (is.null(applied) || length(applied) == 0) {
        return(div(
          style = sprintf(
            "display: inline-block; padding: 0.4em 0.8em; background: %s; color: white; border-radius: 4px; font-size: 0.85em;",
            colors$warning
          ),
          icon("exclamation triangle"),
          " Click 'Apply Selection'"
        ))
      }
      
      # Sort both vectors for reliable comparison
      current_sorted <- sort(as.character(current_filtered))
      applied_sorted <- sort(as.character(applied))
      
      # Check if selections match
      selections_match <- length(current_sorted) == length(applied_sorted) &&
        all(current_sorted == applied_sorted)
      
      if (selections_match) {
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
      trigger <- shared$startup_trigger
      solid <- input$solid_tumors
      heme <- input$hematology
      min_peak <- input$min_peak
      exclude_top <- input$exclude_top_analog
      
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
    # OUTPUT: Selection Rationale (P1 - dynamically enriched)
    # ========================================================================
    
    output$selection_rationale <- renderUI({
      analogs <- filtered_analogs()
      n <- nrow(analogs)
      
      if (is.null(analogs) || n == 0) {
        return(
          div(
            style = sprintf("color: %s;", colors$warning),
            icon("exclamation triangle"),
            " No analogs selected. Adjust criteria above."
          )
        )
      }
      
      # Get filter settings (with safe defaults)
      solid <- if (is.null(input$solid_tumors)) TRUE else input$solid_tumors
      heme <- if (is.null(input$hematology)) TRUE else input$hematology
      min_peak_val <- if (is.null(input$min_peak)) "0" else input$min_peak
      delay_q <- if (is.null(input$delay_quarters)) 2 else input$delay_quarters
      exclude_top <- if (is.null(input$exclude_top_analog)) FALSE else input$exclude_top_analog
      
      # Find which analog would be excluded (compute from original data)
      excluded_analog_name <- tryCatch({
        if (exclude_top) {
          # Rebuild the pre-exclusion dataset
          base_data <- app_data$analogs
          if (!solid) base_data <- base_data[base_data$tumor_class != "Solid", ]
          if (!heme) base_data <- base_data[base_data$tumor_class != "Heme", ]
          if (min_peak_val != "0") {
            min_rev <- as.numeric(min_peak_val)
            base_data <- base_data[base_data$peak_revenue_millions >= min_rev, ]
          }
          if (nrow(base_data) > 0) {
            base_data$product_name[which.max(base_data$peak_revenue_millions)]
          } else {
            "N/A"
          }
        } else {
          NULL
        }
      }, error = function(e) "N/A")
      
      # Calculate dynamic stats (with defensive checks)
      n_solid <- sum(analogs$tumor_class == "Solid", na.rm = TRUE)
      n_heme <- sum(analogs$tumor_class == "Heme", na.rm = TRUE)
      
      # Approval year range (defensive)
      year_range_text <- tryCatch({
        approval_years <- as.numeric(format(as.Date(analogs$approval_date), "%Y"))
        approval_years <- approval_years[!is.na(approval_years)]
        if (length(approval_years) == 0) {
          "N/A"
        } else {
          year_min <- min(approval_years)
          year_max <- max(approval_years)
          if (year_min == year_max) as.character(year_min) else paste0(year_min, "–", year_max)
        }
      }, error = function(e) "N/A")
      
      # Median peak revenue (defensive)
      median_peak_revenue <- tryCatch({
        med <- median(analogs$peak_revenue_millions, na.rm = TRUE)
        if (is.na(med) || is.infinite(med)) 0 else med
      }, error = function(e) 0)
      
      # Build criteria description
      criteria_parts <- c()
      if (solid && heme) {
        criteria_parts <- c(criteria_parts, "all tumor types")
      } else if (solid) {
        criteria_parts <- c(criteria_parts, "solid tumors only")
      } else if (heme) {
        criteria_parts <- c(criteria_parts, "hematology only")
      }
      
      if (min_peak_val != "0") {
        min_val <- as.numeric(min_peak_val)
        if (min_val >= 1000) {
          criteria_parts <- c(criteria_parts, paste0("peak ≥$", min_val/1000, "B"))
        } else {
          criteria_parts <- c(criteria_parts, paste0("peak ≥$", min_val, "M"))
        }
      }
      
      # Build output elements separately for cleaner structure
      summary_div <- div(
        style = sprintf("color: %s; margin-bottom: 0.75em;", colors$text_primary),
        strong(n), " analogs selected: ",
        paste(criteria_parts, collapse = ", ")
      )
      
      stats_div <- div(
        style = sprintf(
          "display: flex; flex-wrap: wrap; gap: 1em; padding: 0.75em; background: %s; border-radius: 4px; font-size: 0.9em;",
          colors$background
        ),
        div(
          style = sprintf("color: %s;", colors$text_secondary),
          icon("chart pie", style = "margin-right: 0.25em;"),
          strong(n_solid), " Solid / ", strong(n_heme), " Heme"
        ),
        div(
          style = sprintf("color: %s;", colors$text_secondary),
          icon("calendar", style = "margin-right: 0.25em;"),
          "Approved: ", strong(year_range_text)
        ),
        div(
          style = sprintf("color: %s;", colors$text_secondary),
          icon("chart line", style = "margin-right: 0.25em;"),
          "Median Peak: ", strong(
            if (median_peak_revenue >= 1000) {
              paste0("$", round(median_peak_revenue/1000, 1), "B")
            } else {
              paste0("$", round(median_peak_revenue), "M")
            }
          )
        )
      )
      
      delay_div <- if (delay_q > 0) {
        div(
          style = sprintf("color: %s; margin-top: 0.5em; font-size: 0.9em;", colors$text_muted),
          icon("clock outline"),
          " Delay scenario: ", strong(delay_q), " quarter(s)"
        )
      } else {
        NULL
      }
      
      sensitivity_div <- if (exclude_top && !is.null(excluded_analog_name)) {
        div(
          style = sprintf(
            "margin-top: 0.75em; padding: 0.5em 0.75em; background: %s; border-radius: 4px; font-size: 0.85em;",
            "#FFF3CD"
          ),
          icon("flask", style = sprintf("color: %s;", colors$warning)),
          span(
            style = sprintf("color: %s;", colors$warning),
            " Sensitivity mode: Excluded ", strong(excluded_analog_name), " (top analog by peak revenue)"
          )
        )
      } else {
        NULL
      }
      
      # Combine all elements
      tagList(summary_div, stats_div, delay_div, sensitivity_div)
    })
    
    # ========================================================================
    # FORCE OUTPUTS TO RENDER (fix for CSS-based tabs)
    # ========================================================================
    
    outputOptions(output, "analog_preview_table", suspendWhenHidden = FALSE)
    outputOptions(output, "revenue_at_risk_display", suspendWhenHidden = FALSE)
    outputOptions(output, "analog_count_badge", suspendWhenHidden = FALSE)
    outputOptions(output, "selection_status", suspendWhenHidden = FALSE)
    outputOptions(output, "selection_rationale", suspendWhenHidden = FALSE)
    
  })
}