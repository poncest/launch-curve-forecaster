# mod_analog_explorer.R
# Analog Explorer Module - Individual Analog Deep Dive
#
# Purpose: Examine individual analog launch curves and characteristics
# Architecture: Button-triggered loading for reliable rendering

# ============================================================================
# MODULE UI
# ============================================================================

mod_analog_explorer_ui <- function(id) {
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
            icon("chart line"),
            "Analog Explorer"
          ),
          p(
            style = sprintf("color: %s;", colors$text_secondary),
            "Examine individual analog launch curves and performance characteristics"
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
          " How to Use Analog Explorer"),
      
      div(
        class = "content",
        
        h4(style = sprintf("color: %s;", colors$primary_dark), "Purpose"),
        p("Deep-dive into individual analog products to understand their launch trajectories and characteristics."),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Steps"),
        tags$ol(
          style = sprintf("color: %s; line-height: 1.8;", colors$text_secondary),
          tags$li(tags$strong("Select Primary Analog"), " - Choose the product you want to analyze"),
          tags$li(tags$strong("Select Comparison (optional)"), " - Add a second product to compare side-by-side"),
          tags$li(tags$strong("Click 'View Details'"), " - Loads metrics, charts, and context for your selection")
        ),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "What You'll See"),
        tags$ul(
          style = sprintf("color: %s;", colors$text_muted),
          tags$li(tags$strong("Key Metrics"), " - Year-5 revenue, cumulative revenue from launch to Year 5, Year 1 and Year 3 revenue"),
          tags$li(tags$strong("Characteristics"), " - Company, indication, tumor class, approval date"),
          tags$li(tags$strong("Launch Curve Chart"), " - Interactive chart showing revenue trajectory"),
          tags$li(tags$strong("Context Table"), " - Side-by-side comparison of selected analogs")
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
    # SELECTION PANEL
    # ========================================================================
    
    div(
      class = "ui segment",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("search"),
        "Select Analogs to Compare"
      ),
      
      div(
        class = "ui form",
        div(
          class = "three fields",
          
          # Primary analog dropdown
          div(
            class = "field",
            tags$label("Primary Analog"),
            selectInput(
              ns("primary_analog"),
              label = NULL,
              choices = c("Loading..." = ""),
              width = "100%"
            )
          ),
          
          # Comparison analog dropdown
          div(
            class = "field",
            tags$label("Compare To (optional)"),
            selectInput(
              ns("compare_analog"),
              label = NULL,
              choices = c("None" = ""),
              width = "100%"
            )
          ),
          
          # View button
          div(
            class = "field",
            tags$label(HTML("&nbsp;")),
            actionButton(
              ns("view_btn"),
              tagList(icon("eye"), " View Details"),
              class = "ui primary button fluid",
              style = sprintf("background: %s;", colors$primary)
            )
          )
        )
      ),
      
      # Instruction text
      p(
        style = sprintf("color: %s; font-size: 0.9em; margin-top: 1em;", colors$text_muted),
        icon("info circle"),
        " Select analogs and click 'View Details' to load launch curve data"
      )
    ),
    
    # ========================================================================
    # RESULTS PANEL (rendered after button click)
    # ========================================================================
    
    uiOutput(ns("results_panel"))
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

mod_analog_explorer_server <- function(id, app_data, shared) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ========================================================================
    # REACTIVE VALUES - Store current state
    # ========================================================================
    
    rv <- reactiveValues(
      loaded = FALSE,
      primary_name = NULL,
      compare_name = NULL
    )
    
    # ========================================================================
    # POPULATE DROPDOWNS ON LOAD
    # ========================================================================
    
    observe({
      if (!app_data$is_placeholder && nrow(app_data$analogs) > 0) {
        
        # Create named choices
        choices <- app_data$analogs$product_name
        names(choices) <- paste0(
          app_data$analogs$product_name, 
          " (", app_data$analogs$company, ")"
        )
        
        updateSelectInput(
          session, "primary_analog",
          choices = choices,
          selected = choices[1]
        )
        
        updateSelectInput(
          session, "compare_analog",
          choices = c("None" = "", choices)
        )
        
        # Show the default analog immediately instead of an empty panel
        isolate({
          if (!isTRUE(rv$loaded)) {
            rv$primary_name <- unname(choices[1])
            rv$compare_name <- NULL
            rv$loaded <- TRUE
          }
        })
      }
    })
    
    # ========================================================================
    # VIEW BUTTON CLICK - Load data
    # ========================================================================
    
    observeEvent(input$view_btn, {
      # Check if primary_analog is valid
      if (is.null(input$primary_analog) || input$primary_analog == "" || input$primary_analog == "Loading...") {
        showNotification("Please select an analog first", type = "warning")
        return()
      }
      
      rv$primary_name <- input$primary_analog
      rv$compare_name <- if (!is.null(input$compare_analog) && input$compare_analog != "") {
        input$compare_analog
      } else {
        NULL
      }
      rv$loaded <- TRUE
      
      showNotification(
        paste("Loading data for", rv$primary_name),
        type = "message",
        duration = 2
      )
    })
    
    # ========================================================================
    # HELPER: Get analog data
    # ========================================================================
    
    get_analog_data <- function(product_name) {
      if (is.null(product_name) || product_name == "") return(NULL)
      app_data$analogs[app_data$analogs$product_name == product_name, ]
    }
    
    get_analog_curves <- function(product_name) {
      if (is.null(product_name) || product_name == "") return(NULL)
      curves <- app_data$curves[app_data$curves$product_name == product_name, ]
      curves[order(curves$years_since_launch), ]
    }
    
    calc_metrics <- function(curves_df) {
      if (is.null(curves_df) || nrow(curves_df) == 0) {
        return(list(peak = NA, cumulative = NA, year1 = NA, year3 = NA))
      }
      
      year5_row <- curves_df[curves_df$years_since_launch == 5, ]
      year1_row <- curves_df[curves_df$years_since_launch == 1, ]
      year3_row <- curves_df[curves_df$years_since_launch == 3, ]
      
      list(
        # "peak" = Year-5 revenue: every analog is observed through year 5 only
        peak = if (nrow(year5_row) > 0) year5_row$revenue_millions[1] else NA,
        # Only when all five launch years are available (a gap would understate it)
        cumulative = if (all(1:5 %in% curves_df$years_since_launch))
          sum(curves_df$revenue_millions[curves_df$years_since_launch <= 5]) else NA,
        year1 = if (nrow(year1_row) > 0) year1_row$revenue_millions[1] else NA,
        year3 = if (nrow(year3_row) > 0) year3_row$revenue_millions[1] else NA
      )
    }
    
    format_revenue <- function(val) {
      if (is.na(val)) return("--")
      if (val >= 1000) paste0("$", round(val / 1000, 1), "B")
      else paste0("$", round(val), "M")
    }
    
    # ========================================================================
    # RESULTS PANEL - Main output
    # ========================================================================
    
    output$results_panel <- renderUI({
      # Don't show anything until button clicked
      if (!rv$loaded) {
        return(
          div(
            class = "ui segment placeholder",
            style = "margin-top: 1.5em; min-height: 300px; display: flex; align-items: center; justify-content: center;",
            div(
              style = sprintf("text-align: center; color: %s;", colors$text_muted),
              icon("chart line", style = "font-size: 3em; opacity: 0.5;"),
              br(), br(),
              "Select analogs above and click 'View Details' to see launch curves"
            )
          )
        )
      }
      
      # Get data for selected analogs
      primary_data <- get_analog_data(rv$primary_name)
      primary_curves <- get_analog_curves(rv$primary_name)
      primary_metrics <- calc_metrics(primary_curves)
      
      compare_data <- get_analog_data(rv$compare_name)
      compare_curves <- get_analog_curves(rv$compare_name)
      compare_metrics <- calc_metrics(compare_curves)
      
      # Build the results UI
      tagList(
        # Two column layout for analog cards
        div(
          class = "ui two column stackable grid",
          style = "margin-top: 1.5em;",
          
          # Primary analog card
          div(
            class = "column",
            div(
              class = "ui segment",
              style = sprintf("border-top: 3px solid %s;", colors$primary),
              
              h3(style = sprintf("color: %s;", colors$primary_dark), rv$primary_name),
              
              # Metrics
              div(
                class = "ui four statistics mini",
                style = "margin: 1.5em 0;",
                
                div(class = "statistic",
                    div(class = "value", format_revenue(primary_metrics$peak)),
                    div(class = "label", "Year-5 Revenue")),
                div(class = "statistic",
                    div(class = "value", format_revenue(primary_metrics$cumulative)),
                    div(class = "label", "Cumulative to Y5")),
                div(class = "statistic",
                    div(class = "value", format_revenue(primary_metrics$year1)),
                    div(class = "label", "Year 1")),
                div(class = "statistic",
                    div(class = "value", format_revenue(primary_metrics$year3)),
                    div(class = "label", "Year 3"))
              ),
              
              # Characteristics
              if (!is.null(primary_data) && nrow(primary_data) > 0) {
                tagList(
                  h4(style = sprintf("color: %s;", colors$text_primary), "Characteristics"),
                  tags$ul(
                    style = sprintf("color: %s;", colors$text_secondary),
                    tags$li(paste0("Company: ", primary_data$company)),
                    tags$li(paste0("Indication: ", primary_data$indication)),
                    tags$li(paste0("Tumor Class: ", primary_data$tumor_class)),
                    tags$li(paste0("Approval: ", format(as.Date(primary_data$approval_date), "%B %Y")))
                  )
                )
              }
            )
          ),
          
          # Comparison analog card (or placeholder)
          div(
            class = "column",
            if (is.null(rv$compare_name)) {
              div(
                class = "ui segment",
                style = sprintf(
                  "border-top: 3px solid %s; min-height: 300px; display: flex; align-items: center; justify-content: center;",
                  colors$border
                ),
                div(
                  style = sprintf("text-align: center; color: %s;", colors$text_muted),
                  icon("plus circle", style = "font-size: 2em; margin-bottom: 0.5em;"),
                  br(),
                  "Select a comparison analog and click 'View Details'"
                )
              )
            } else {
              div(
                class = "ui segment",
                style = sprintf("border-top: 3px solid %s;", colors$secondary),
                
                h3(style = sprintf("color: %s;", colors$secondary), rv$compare_name),
                
                # Metrics
                div(
                  class = "ui four statistics mini",
                  style = "margin: 1.5em 0;",
                  
                  div(class = "statistic",
                      div(class = "value", format_revenue(compare_metrics$peak)),
                      div(class = "label", "Year-5 Revenue")),
                  div(class = "statistic",
                      div(class = "value", format_revenue(compare_metrics$cumulative)),
                      div(class = "label", "Cumulative to Y5")),
                  div(class = "statistic",
                      div(class = "value", format_revenue(compare_metrics$year1)),
                      div(class = "label", "Year 1")),
                  div(class = "statistic",
                      div(class = "value", format_revenue(compare_metrics$year3)),
                      div(class = "label", "Year 3"))
                ),
                
                # Characteristics
                if (!is.null(compare_data) && nrow(compare_data) > 0) {
                  tagList(
                    h4(style = sprintf("color: %s;", colors$text_primary), "Characteristics"),
                    tags$ul(
                      style = sprintf("color: %s;", colors$text_secondary),
                      tags$li(paste0("Company: ", compare_data$company)),
                      tags$li(paste0("Indication: ", compare_data$indication)),
                      tags$li(paste0("Tumor Class: ", compare_data$tumor_class)),
                      tags$li(paste0("Approval: ", format(as.Date(compare_data$approval_date), "%B %Y")))
                    )
                  )
                }
              )
            }
          )
        ),
        
        # Chart segment
        div(
          class = "ui segment",
          style = "margin-top: 1.5em;",
          
          h3(style = sprintf("color: %s;", colors$primary_dark), "Launch Curve Comparison"),
          
          # P1 Guardrail: Prevent misinterpretation
          div(
            style = sprintf(
              "margin-bottom: 1em; padding: 0.75em 1em; background: %s; border-left: 3px solid %s; border-radius: 4px;",
              colors$background, colors$primary_light
            ),
            p(
              style = sprintf("color: %s; margin: 0; font-size: 0.9em;", colors$text_secondary),
              icon("info circle"),
              " ",
              strong("Interpretation note:"),
              " No analog is treated as 'most representative.' The value of this framework lies in the ",
              strong("distribution across analogs"),
              ", not any single curve."
            )
          ),
          
          girafeOutput(ns("comparison_chart"), height = "400px")
        ),
        
        # Context table
        div(
          class = "ui segment",
          style = "margin-top: 1.5em;",
          
          h3(style = sprintf("color: %s;", colors$primary_dark), "Launch Context"),
          p(style = sprintf("color: %s;", colors$text_muted), 
            "Factors that may have influenced launch trajectory"),
          
          reactableOutput(ns("context_table"))
        )
      )
    })
    
    # ========================================================================
    # CHART OUTPUT
    # ========================================================================
    
    output$comparison_chart <- renderGirafe({
      req(rv$loaded)
      
      # Get curves
      primary_curves <- get_analog_curves(rv$primary_name)
      
      if (is.null(primary_curves) || nrow(primary_curves) == 0) {
        p <- ggplot() +
          annotate("text", x = 0.5, y = 0.5, label = "No data available", 
                   size = 5, color = colors$text_muted) +
          theme_void()
        return(girafe(ggobj = p, width_svg = 10, height_svg = 4))
      }
      
      # Build chart data
      chart_data <- primary_curves
      chart_data$analog_type <- "Primary"
      chart_data$product_label <- rv$primary_name
      
      # Add comparison if exists
      if (!is.null(rv$compare_name)) {
        compare_curves <- get_analog_curves(rv$compare_name)
        if (!is.null(compare_curves) && nrow(compare_curves) > 0) {
          compare_curves$analog_type <- "Comparison"
          compare_curves$product_label <- rv$compare_name
          chart_data <- rbind(chart_data, compare_curves)
        }
      }
      
      # Colors
      line_colors <- setNames(c(colors$primary, colors$secondary)[seq_along(unique(chart_data$product_label))],
                              unique(chart_data$product_label))
      
      # Build plot
      p <- ggplot(chart_data, aes(x = years_since_launch, y = revenue_millions, color = product_label)) +
        geom_line_interactive(
          # Per-point tooltips would split the line into one group per point,
          # so the line gets a per-product tooltip and explicit grouping
          aes(
            group = product_label,
            data_id = product_label,
            tooltip = product_label
          ),
          linewidth = 1.5
        ) +
        geom_point_interactive(
          aes(
            data_id = product_label,
            tooltip = sprintf("%s\nYear %d: $%sM", product_label, years_since_launch,
                              scales::comma(revenue_millions))
          ),
          size = 3
        ) +
        scale_color_manual(values = line_colors, name = "") +
        scale_x_continuous(breaks = 1:5, labels = paste0("Y", 1:5)) +
        scale_y_continuous(labels = scales::dollar_format(scale = 1, suffix = "M")) +
        labs(
          title = "Launch Curve Trajectory",
          subtitle = "Annual revenue by years since launch",
          x = "Launch year (12-month periods from FDA approval)",
          y = "Annual Revenue"
        ) +
        theme_launch()
      
      girafe(
        ggobj = p,
        width_svg = 10,
        height_svg = 4,
        options = list(
          opts_hover(css = "stroke-width: 3;"),
          opts_tooltip(css = "background: white; padding: 8px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.2);")
        )
      )
    })
    
    # ========================================================================
    # CONTEXT TABLE
    # ========================================================================
    
    output$context_table <- renderReactable({
      req(rv$loaded)
      
      primary_data <- get_analog_data(rv$primary_name)
      compare_data <- get_analog_data(rv$compare_name)
      
      if (is.null(primary_data) || nrow(primary_data) == 0) {
        return(reactable(data.frame(Message = "No data available")))
      }
      
      # Build comparison table
      factors <- c("Company", "Tumor Class", "Initial Indication", "Approval Year", "Year-5 Revenue")
      
      primary_vals <- c(
        primary_data$company,
        primary_data$tumor_class,
        primary_data$indication,
        format(as.Date(primary_data$approval_date), "%Y"),
        format_revenue(primary_data$peak_revenue_millions)
      )
      
      if (!is.null(compare_data) && nrow(compare_data) > 0) {
        compare_vals <- c(
          compare_data$company,
          compare_data$tumor_class,
          compare_data$indication,
          format(as.Date(compare_data$approval_date), "%Y"),
          format_revenue(compare_data$peak_revenue_millions)
        )
        
        table_data <- data.frame(
          Factor = factors,
          Primary = primary_vals,
          Comparison = compare_vals,
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
        names(table_data)[2] <- rv$primary_name
        names(table_data)[3] <- rv$compare_name
      } else {
        table_data <- data.frame(
          Factor = factors,
          Value = primary_vals,
          stringsAsFactors = FALSE
        )
        names(table_data)[2] <- rv$primary_name
      }
      
      reactable(
        table_data,
        striped = TRUE,
        highlight = TRUE,
        theme = reactableTheme(
          headerStyle = list(
            background = colors$background,
            color = colors$text_primary,
            fontWeight = "bold"
          )
        ),
        columns = list(
          Factor = colDef(
            style = list(fontWeight = "bold"),
            minWidth = 120
          )
        )
      )
    })
    
    # ========================================================================
    # FORCE OUTPUT TO RENDER (fix for CSS-based tabs)
    # ========================================================================
    
    # This tells Shiny to render outputs even when the tab appears "hidden"
    outputOptions(output, "results_panel", suspendWhenHidden = FALSE)
    outputOptions(output, "comparison_chart", suspendWhenHidden = FALSE)
    outputOptions(output, "context_table", suspendWhenHidden = FALSE)
    
  })
}