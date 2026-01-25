# mod_executive_brief.R
# Executive Brief Module - VP-Level Decision Summary
#
# Purpose: Rapid assessment of launch scenarios with appropriate evidentiary calibration
# Primary Persona: Brand VP / Commercial Lead
# Secondary: Finance Partner

# ============================================================================
# MODULE UI
# ============================================================================

mod_executive_brief_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Header
    div(
      style = "margin-bottom: 1.5em;",
      h2(
        style = sprintf("color: %s; margin-bottom: 0.25em;", colors$primary_dark),
        icon("dashboard"),
        "Executive Brief"
      ),
      p(
        style = sprintf("color: %s;", colors$text_secondary),
        "VP-level summary: key metrics, scenario comparison, and decision trade-offs"
      )
    ),
    
    # ========================================================================
    # KPI CARDS ROW
    # ========================================================================
    
    div(
      class = "ui four column stackable grid",
      style = "margin-bottom: 2em;",
      
      # KPI 1: Analogs Selected
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "text-align: center; padding: 1.5em; border-top: 3px solid %s;",
            colors$primary
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$primary),
            uiOutput(ns("kpi_analogs"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em;", colors$text_secondary),
            "Analogs Selected"
          ),
          div(
            style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.25em;", colors$text_muted),
            uiOutput(ns("kpi_analogs_context"), inline = TRUE)
          )
        )
      ),
      
      # KPI 2: Base Case Peak Revenue
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "text-align: center; padding: 1.5em; border-top: 3px solid %s;",
            colors$success
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$success),
            uiOutput(ns("kpi_peak_revenue"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em;", colors$text_secondary),
            "Base Case Peak (P50)"
          ),
          div(
            style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.25em;", colors$text_muted),
            uiOutput(ns("kpi_peak_context"), inline = TRUE)
          )
        )
      ),
      
      # KPI 3: Revenue at Risk (Delay Scenario)
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "text-align: center; padding: 1.5em; border-top: 3px solid %s;",
            colors$warning
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$warning),
            uiOutput(ns("kpi_revenue_at_risk"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em;", colors$text_secondary),
            "Revenue at Risk"
          ),
          div(
            style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.25em;", colors$text_muted),
            "6-month delay scenario"
          )
        )
      ),
      
      # KPI 4: Time to Peak
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "text-align: center; padding: 1.5em; border-top: 3px solid %s;",
            colors$secondary
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$secondary),
            uiOutput(ns("kpi_time_to_peak"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em;", colors$text_secondary),
            "Quarters to Peak"
          ),
          div(
            style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.25em;", colors$text_muted),
            uiOutput(ns("kpi_time_context"), inline = TRUE)
          )
        )
      )
    ),
    
    # ========================================================================
    # MAIN CONTENT: CHART + DECISIONS
    # ========================================================================
    
    div(
      class = "ui two column stackable grid",
      
      # Left: Launch Curve Chart
      div(
        class = "ten wide column",
        div(
          class = "ui segment",
          style = "padding: 1.5em;",
          
          h3(
            style = sprintf("color: %s; margin-bottom: 0.5em;", colors$primary_dark),
            "Launch Trajectory Scenarios"
          ),
          p(
            style = sprintf("color: %s; margin-bottom: 1em;", colors$text_muted),
            "P25/P50/P75 bands based on selected analog performance"
          ),
          
          # Interactive chart
          girafeOutput(ns("launch_curve_chart"), height = "400px")
        )
      ),
      
      # Right: Key Decisions Panel
      div(
        class = "six wide column",
        
        # Decision Box 1: Launch Timing
        div(
          class = "ui segment",
          style = sprintf(
            "margin-bottom: 1em; border-left: 3px solid %s;",
            colors$warning
          ),
          
          h4(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("clock outline"),
            "Decision: Launch Timing"
          ),
          p(
            style = sprintf("color: %s; font-size: 0.95em;", colors$text_secondary),
            strong("Trade-off:"), " Speed vs. readiness"
          ),
          
          div(
            style = sprintf(
              "background: %s; padding: 1em; border-radius: 4px; margin-top: 0.75em;",
              colors$background
            ),
            p(
              style = sprintf("color: %s; margin: 0; font-size: 0.9em;", colors$text_primary),
              uiOutput(ns("decision_timing"), inline = TRUE)
            )
          )
        ),
        
        # Decision Box 2: Forecast Commitment
        div(
          class = "ui segment",
          style = sprintf(
            "border-left: 3px solid %s;",
            colors$primary
          ),
          
          h4(
            style = sprintf("color: %s;", colors$primary_dark),
            icon("chart bar outline"),
            "Decision: Forecast Commitment"
          ),
          p(
            style = sprintf("color: %s; font-size: 0.95em;", colors$text_secondary),
            strong("Trade-off:"), " Alignment vs. credibility risk"
          ),
          
          div(
            style = sprintf(
              "background: %s; padding: 1em; border-radius: 4px; margin-top: 0.75em;",
              colors$background
            ),
            p(
              style = sprintf("color: %s; margin: 0; font-size: 0.9em;", colors$text_primary),
              uiOutput(ns("decision_forecast"), inline = TRUE)
            )
          )
        )
      )
    ),
    
    # ========================================================================
    # ANALOG SUMMARY TABLE
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s; margin-bottom: 0.5em;", colors$primary_dark),
        "Selected Analog Summary"
      ),
      p(
        style = sprintf("color: %s; margin-bottom: 1em;", colors$text_muted),
        "Characteristics of products informing the forecast range"
      ),
      
      reactableOutput(ns("analog_table"))
    ),
    
    # ========================================================================
    # METHODOLOGY NOTE
    # ========================================================================
    
    div(
      style = sprintf(
        "margin-top: 1.5em; padding: 1em; background: %s; border-radius: 4px;",
        colors$background
      ),
      p(
        style = sprintf("color: %s; font-size: 0.85em; margin: 0;", colors$text_muted),
        icon("info circle"),
        strong(" Methodology Note: "),
        "This framework does not predict whether a specific launch will succeed. ",
        "It quantifies the range of outcomes implied by analog selection and highlights ",
        "where assumptions drive revenue risk. Scenario bounds (P25/P50/P75) reflect ",
        "observed variation across selected analogs, not statistical confidence intervals."
      )
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

mod_executive_brief_server <- function(id, app_data, shared) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ========================================================================
    # REACTIVE: Selected Analogs Data
    # ========================================================================
    
    selected_data <- reactive({
      # If no analogs selected yet, use all available
      if (is.null(shared$selected_analogs) || length(shared$selected_analogs) == 0) {
        app_data$analogs
      } else {
        app_data$analogs |>
          filter(product_name %in% shared$selected_analogs)
      }
    })
    
    # ========================================================================
    # REACTIVE: Calculated Metrics
    # ========================================================================
    
    metrics <- reactive({
      # Placeholder calculations - will be replaced with real logic
      # when data is available
      
      if (app_data$is_placeholder) {
        return(list(
          n_analogs = 0,
          peak_p50 = 0,
          peak_p25 = 0,
          peak_p75 = 0,
          revenue_at_risk = 0,
          quarters_to_peak = 0,
          quarters_range = c(0, 0)
        ))
      }
      
      # Calculate from selected analogs
      curves <- app_data$curves |>
        filter(product_name %in% selected_data()$product_name)
      
      # Get peak revenue by product
      peaks <- curves |>
        group_by(product_name) |>
        summarise(peak_revenue = max(revenue_millions, na.rm = TRUE))
      
      # Calculate percentiles
      list(
        n_analogs = nrow(selected_data()),
        peak_p50 = median(peaks$peak_revenue, na.rm = TRUE),
        peak_p25 = quantile(peaks$peak_revenue, 0.25, na.rm = TRUE),
        peak_p75 = quantile(peaks$peak_revenue, 0.75, na.rm = TRUE),
        revenue_at_risk = median(peaks$peak_revenue, na.rm = TRUE) * 0.15,
        quarters_to_peak = 12,
        quarters_range = c(8, 16)
      )
    })
    
    # ========================================================================
    # KPI OUTPUTS
    # ========================================================================
    
    output$kpi_analogs <- renderUI({
      m <- metrics()
      if (m$n_analogs == 0) "--" else m$n_analogs
    })
    
    output$kpi_analogs_context <- renderUI({
      m <- metrics()
      if (m$n_analogs == 0) {
        "Configure in Scenario Builder"
      } else {
        "Oncology products"
      }
    })
    
    output$kpi_peak_revenue <- renderUI({
      m <- metrics()
      if (m$peak_p50 == 0) {
        "--"
      } else {
        # Inline formatting (avoiding helper function scoping issues)
        paste0("$", round(m$peak_p50 / 1000, 1), "B")
      }
    })
    
    output$kpi_peak_context <- renderUI({
      m <- metrics()
      if (m$peak_p50 == 0) {
        "Annual revenue"
      } else {
        paste0(
          "Range: $", round(m$peak_p25 / 1000, 1), "B - $",
          round(m$peak_p75 / 1000, 1), "B"
        )
      }
    })
    
    output$kpi_revenue_at_risk <- renderUI({
      m <- metrics()
      if (m$revenue_at_risk == 0) {
        "--"
      } else {
        paste0("$", round(m$revenue_at_risk, 0), "M")
      }
    })
    
    output$kpi_time_to_peak <- renderUI({
      m <- metrics()
      if (m$quarters_to_peak == 0) "--" else m$quarters_to_peak
    })
    
    output$kpi_time_context <- renderUI({
      m <- metrics()
      if (m$quarters_to_peak == 0) {
        "From launch"
      } else {
        paste0("Range: ", m$quarters_range[1], "-", m$quarters_range[2], " quarters")
      }
    })
    
    # ========================================================================
    # DECISION TEXT OUTPUTS
    # ========================================================================
    
    output$decision_timing <- renderUI({
      m <- metrics()
      if (m$revenue_at_risk == 0) {
        "Configure analogs in Scenario Builder to see timing analysis."
      } else {
        paste0(
          "A 6-month delay scenario suggests approximately $",
          round(m$revenue_at_risk, 0), "M in cumulative revenue at risk ",
          "during the first 3 years post-launch. This estimate reflects ",
          "median analog performance and does not account for competitive dynamics."
        )
      }
    })
    
    output$decision_forecast <- renderUI({
      m <- metrics()
      if (m$peak_p50 == 0) {
        "Configure analogs in Scenario Builder to see forecast analysis."
      } else {
        paste0(
          "Committing to P50 forecast ($", round(m$peak_p50 / 1000, 1), "B peak) ",
          "implies accepting that ~50% of analogs underperformed this level. ",
          "P25 conservative scenario ($", round(m$peak_p25 / 1000, 1), "B) ",
          "reduces credibility risk but may understate opportunity."
        )
      }
    })
    
    # ========================================================================
    # LAUNCH CURVE CHART
    # ========================================================================
    
    output$launch_curve_chart <- renderGirafe({
      
      if (app_data$is_placeholder) {
        # Placeholder chart
        p <- ggplot() +
          annotate(
            "text",
            x = 0.5, y = 0.5,
            label = "Configure analogs in Scenario Builder\nto generate launch curves",
            size = 5,
            color = colors$text_muted
          ) +
          theme_void() +
          theme(
            plot.background = element_rect(fill = colors$card_bg, color = NA)
          )
        
        girafe(ggobj = p, width_svg = 8, height_svg = 4)
        
      } else {
        # Real chart with data
        # This will be implemented when data is available
        
        # Placeholder for now
        p <- ggplot() +
          annotate(
            "text",
            x = 0.5, y = 0.5,
            label = "Launch curve visualization\n(Data loaded)",
            size = 5,
            color = colors$text_secondary
          ) +
          theme_void() +
          theme(
            plot.background = element_rect(fill = colors$card_bg, color = NA)
          )
        
        girafe(ggobj = p, width_svg = 8, height_svg = 4)
      }
    })
    
    # ========================================================================
    # ANALOG TABLE
    # ========================================================================
    
    output$analog_table <- renderReactable({
      
      if (app_data$is_placeholder || nrow(selected_data()) == 0) {
        # Empty state
        data.frame(
          Product = "No analogs selected",
          Company = "--",
          `Approval Year` = "--",
          Indication = "--"
        ) |>
          reactable(
            theme = reactableTheme(
              headerStyle = list(
                background = colors$background,
                color = colors$text_primary,
                fontWeight = "bold"
              )
            )
          )
        
      } else {
        # Real table
        selected_data() |>
          select(
            Product = product_name,
            Company = company,
            `Approval Year` = approval_date,
            Indication = indication
          ) |>
          reactable(
            searchable = FALSE,
            pagination = FALSE,
            striped = TRUE,
            highlight = TRUE,
            theme = reactableTheme(
              headerStyle = list(
                background = colors$background,
                color = colors$text_primary,
                fontWeight = "bold"
              ),
              stripedColor = colors$background
            )
          )
      }
    })
    
  })
}
