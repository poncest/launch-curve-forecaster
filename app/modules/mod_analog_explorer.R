# mod_analog_explorer.R
# Analog Explorer Module - Individual Analog Deep Dive
#
# Purpose: Examine individual analog launch curves and characteristics
# Use Case: Understanding WHY analogs performed as they did

# ============================================================================
# MODULE UI
# ============================================================================

mod_analog_explorer_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Header
    div(
      style = "margin-bottom: 1.5em;",
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
    
    # ========================================================================
    # ANALOG SELECTION
    # ========================================================================
    
    div(
      class = "ui segment",
      
      div(
        class = "ui form",
        div(
          class = "two fields",
          
          div(
            class = "field",
            tags$label("Select Analog"),
            selectInput(
              ns("selected_analog"),
              label = NULL,
              choices = c("Load data first..." = ""),
              width = "100%"
            )
          ),
          
          div(
            class = "field",
            tags$label("Compare To"),
            selectInput(
              ns("compare_analog"),
              label = NULL,
              choices = c("None" = "", "Load data first..." = ""),
              width = "100%"
            )
          )
        )
      )
    ),
    
    # ========================================================================
    # ANALOG DETAIL CARDS
    # ========================================================================
    
    div(
      class = "ui two column stackable grid",
      style = "margin-top: 1.5em;",
      
      # Left: Primary analog
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf("border-top: 3px solid %s;", colors$primary),
          
          h3(
            style = sprintf("color: %s;", colors$primary_dark),
            uiOutput(ns("primary_analog_name"), inline = TRUE)
          ),
          
          # Key metrics
          div(
            class = "ui four statistics mini",
            style = "margin: 1.5em 0;",
            
            div(
              class = "statistic",
              div(class = "value", uiOutput(ns("primary_peak"), inline = TRUE)),
              div(class = "label", "Peak Revenue")
            ),
            div(
              class = "statistic",
              div(class = "value", uiOutput(ns("primary_ttp"), inline = TRUE)),
              div(class = "label", "Quarters to Peak")
            ),
            div(
              class = "statistic",
              div(class = "value", uiOutput(ns("primary_y1"), inline = TRUE)),
              div(class = "label", "Year 1")
            ),
            div(
              class = "statistic",
              div(class = "value", uiOutput(ns("primary_y3"), inline = TRUE)),
              div(class = "label", "Year 3")
            )
          ),
          
          # Characteristics
          h4(style = sprintf("color: %s;", colors$text_primary), "Characteristics"),
          uiOutput(ns("primary_characteristics"))
        )
      ),
      
      # Right: Comparison analog (conditional)
      div(
        class = "column",
        uiOutput(ns("compare_panel"))
      )
    ),
    
    # ========================================================================
    # LAUNCH CURVE COMPARISON CHART
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        "Launch Curve Comparison"
      ),
      
      girafeOutput(ns("comparison_chart"), height = "400px")
    ),
    
    # ========================================================================
    # CONTEXT TABLE
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        "Launch Context"
      ),
      p(
        style = sprintf("color: %s; margin-bottom: 1em;", colors$text_muted),
        "Factors that may have influenced launch trajectory"
      ),
      
      reactableOutput(ns("context_table"))
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

mod_analog_explorer_server <- function(id, app_data, shared) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ========================================================================
    # UPDATE: Analog Dropdown Choices
    # ========================================================================
    
    observe({
      # Depend on startup trigger
      shared$startup_trigger
      
      if (!app_data$is_placeholder && nrow(app_data$analogs) > 0) {
        choices <- setNames(
          app_data$analogs$product_name,
          paste0(app_data$analogs$product_name, " (", app_data$analogs$company, ")")
        )
        
        updateSelectInput(
          session,
          "selected_analog",
          choices = choices,
          selected = choices[1]  # Explicitly select first
        )
        
        updateSelectInput(
          session,
          "compare_analog",
          choices = c("None" = "", choices)
        )
      }
    })
    
    # ========================================================================
    # REACTIVE: Primary Analog Data
    # ========================================================================
    
    primary_data <- reactive({
      # Depend on startup trigger
      shared$startup_trigger
      
      # Use softer check - allow NULL but return NULL
      selected <- input$selected_analog
      if (is.null(selected) || selected == "" || selected == "Load data first...") {
        return(NULL)
      }
      
      if (app_data$is_placeholder) return(NULL)
      
      app_data$analogs |>
        filter(product_name == selected)
    })
    
    # ========================================================================
    # REACTIVE: Primary Analog Curves
    # ========================================================================
    
    primary_curves <- reactive({
      # Depend on startup trigger
      shared$startup_trigger
      
      selected <- input$selected_analog
      if (is.null(selected) || selected == "" || selected == "Load data first...") {
        return(NULL)
      }
      
      if (app_data$is_placeholder) return(NULL)
      
      app_data$curves |>
        filter(product_name == selected) |>
        arrange(years_since_launch)
    })
    
    # ========================================================================
    # REACTIVE: Comparison Analog Data
    # ========================================================================
    
    compare_data <- reactive({
      shared$startup_trigger
      if (is.null(input$compare_analog) || input$compare_analog == "") return(NULL)
      if (app_data$is_placeholder) return(NULL)
      
      app_data$analogs |>
        filter(product_name == input$compare_analog)
    })
    
    # ========================================================================
    # REACTIVE: Comparison Analog Curves
    # ========================================================================
    
    compare_curves <- reactive({
      shared$startup_trigger
      if (is.null(input$compare_analog) || input$compare_analog == "") return(NULL)
      if (app_data$is_placeholder) return(NULL)
      
      app_data$curves |>
        filter(product_name == input$compare_analog) |>
        arrange(years_since_launch)
    })
    
    # ========================================================================
    # HELPER: Calculate metrics from curves
    # ========================================================================
    
    calc_metrics <- function(curves_df) {
      if (is.null(curves_df) || nrow(curves_df) == 0) {
        return(list(
          peak = NA,
          quarters_to_peak = NA,
          year1 = NA,
          year3 = NA
        ))
      }
      
      peak_row <- curves_df[which.max(curves_df$revenue_millions), ]
      year1_row <- curves_df[curves_df$years_since_launch == 1, ]
      year3_row <- curves_df[curves_df$years_since_launch == 3, ]
      
      list(
        peak = max(curves_df$revenue_millions, na.rm = TRUE),
        quarters_to_peak = peak_row$years_since_launch * 4,
        year1 = if (nrow(year1_row) > 0) year1_row$revenue_millions else NA,
        year3 = if (nrow(year3_row) > 0) year3_row$revenue_millions else NA
      )
    }
    
    # ========================================================================
    # OUTPUTS: Primary Analog Info
    # ========================================================================
    
    output$primary_analog_name <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      
      if (is.null(primary_data()) || nrow(primary_data()) == 0) {
        "Select an analog"
      } else {
        primary_data()$product_name
      }
    })
    
    output$primary_peak <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      
      metrics <- calc_metrics(primary_curves())
      if (is.na(metrics$peak)) return("--")
      
      if (metrics$peak >= 1000) {
        paste0("$", round(metrics$peak / 1000, 1), "B")
      } else {
        paste0("$", round(metrics$peak), "M")
      }
    })
    
    output$primary_ttp <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      
      metrics <- calc_metrics(primary_curves())
      if (is.na(metrics$quarters_to_peak)) return("--")
      as.character(metrics$quarters_to_peak)
    })
    
    output$primary_y1 <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      
      metrics <- calc_metrics(primary_curves())
      if (is.na(metrics$year1)) return("--")
      
      if (metrics$year1 >= 1000) {
        paste0("$", round(metrics$year1 / 1000, 1), "B")
      } else {
        paste0("$", round(metrics$year1), "M")
      }
    })
    
    output$primary_y3 <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      
      metrics <- calc_metrics(primary_curves())
      if (is.na(metrics$year3)) return("--")
      
      if (metrics$year3 >= 1000) {
        paste0("$", round(metrics$year3 / 1000, 1), "B")
      } else {
        paste0("$", round(metrics$year3), "M")
      }
    })
    
    output$primary_characteristics <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      
      if (is.null(primary_data()) || nrow(primary_data()) == 0) {
        return(p("Select an analog to view characteristics"))
      }
      
      product <- primary_data()
      
      # Format approval date (handle character or Date)
      approval_fmt <- tryCatch({
        date_val <- as.Date(product$approval_date)
        format(date_val, "%B %Y")
      }, error = function(e) {
        as.character(product$approval_date)
      })
      
      tags$ul(
        style = sprintf("color: %s;", colors$text_secondary),
        tags$li(paste0("Company: ", product$company)),
        tags$li(paste0("Indication: ", product$indication)),
        tags$li(paste0("Tumor Class: ", product$tumor_class)),
        tags$li(paste0("Approval: ", approval_fmt))
      )
    })
    
    # ========================================================================
    # OUTPUT: Comparison Panel (conditional)
    # ========================================================================
    
    output$compare_panel <- renderUI({
      # Force dependencies
      shared$startup_trigger
      input$compare_analog
      
      if (is.null(input$compare_analog) || input$compare_analog == "") {
        # Empty state
        div(
          class = "ui segment",
          style = sprintf(
            "border-top: 3px solid %s; display: flex; align-items: center; justify-content: center; min-height: 300px;",
            colors$border
          ),
          div(
            style = sprintf("text-align: center; color: %s;", colors$text_muted),
            icon("plus circle", style = "font-size: 2em; margin-bottom: 0.5em;"),
            br(),
            "Select a comparison analog above"
          )
        )
      } else {
        # Get comparison data
        comp_product <- compare_data()
        comp_metrics <- calc_metrics(compare_curves())
        
        # Format metrics
        format_revenue <- function(val) {
          if (is.na(val)) return("--")
          if (val >= 1000) paste0("$", round(val / 1000, 1), "B")
          else paste0("$", round(val), "M")
        }
        
        format_quarters <- function(val) {
          if (is.na(val)) return("--")
          as.character(val)
        }
        
        # Comparison analog details
        div(
          class = "ui segment",
          style = sprintf("border-top: 3px solid %s;", colors$secondary),
          
          h3(
            style = sprintf("color: %s;", colors$secondary),
            input$compare_analog
          ),
          
          # Metrics from real data
          div(
            class = "ui four statistics mini",
            style = "margin: 1.5em 0;",
            
            div(
              class = "statistic",
              div(class = "value", format_revenue(comp_metrics$peak)),
              div(class = "label", "Peak Revenue")
            ),
            div(
              class = "statistic",
              div(class = "value", format_quarters(comp_metrics$quarters_to_peak)),
              div(class = "label", "Quarters to Peak")
            ),
            div(
              class = "statistic",
              div(class = "value", format_revenue(comp_metrics$year1)),
              div(class = "label", "Year 1")
            ),
            div(
              class = "statistic",
              div(class = "value", format_revenue(comp_metrics$year3)),
              div(class = "label", "Year 3")
            )
          ),
          
          h4(style = sprintf("color: %s;", colors$text_primary), "Characteristics"),
          if (!is.null(comp_product) && nrow(comp_product) > 0) {
            # Format approval date safely
            approval_fmt <- tryCatch({
              date_val <- as.Date(comp_product$approval_date)
              format(date_val, "%B %Y")
            }, error = function(e) {
              as.character(comp_product$approval_date)
            })
            
            tags$ul(
              style = sprintf("color: %s;", colors$text_secondary),
              tags$li(paste0("Company: ", comp_product$company)),
              tags$li(paste0("Indication: ", comp_product$indication)),
              tags$li(paste0("Tumor Class: ", comp_product$tumor_class)),
              tags$li(paste0("Approval: ", approval_fmt))
            )
          } else {
            tags$ul(
              style = sprintf("color: %s;", colors$text_muted),
              tags$li("Data not available")
            )
          }
        )
      }
    })
    
    # ========================================================================
    # OUTPUT: Comparison Chart
    # ========================================================================
    
    output$comparison_chart <- renderGirafe({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      input$compare_analog
      
      if (app_data$is_placeholder) {
        p <- ggplot() +
          annotate(
            "text",
            x = 0.5, y = 0.5,
            label = "Select analogs to compare launch curves",
            size = 5,
            color = colors$text_muted
          ) +
          theme_void() +
          theme(plot.background = element_rect(fill = colors$card_bg, color = NA))
        
        return(girafe(ggobj = p, width_svg = 10, height_svg = 4))
      }
      
      # Get primary curves
      primary <- primary_curves()
      
      if (is.null(primary) || nrow(primary) == 0) {
        p <- ggplot() +
          annotate(
            "text",
            x = 0.5, y = 0.5,
            label = "Select an analog to view launch curve",
            size = 5,
            color = colors$text_muted
          ) +
          theme_void() +
          theme(plot.background = element_rect(fill = colors$card_bg, color = NA))
        
        return(girafe(ggobj = p, width_svg = 10, height_svg = 4))
      }
      
      # Build chart data
      chart_data <- primary |>
        mutate(
          analog_type = "Primary",
          product_label = input$selected_analog
        )
      
      # Add comparison if selected
      compare <- compare_curves()
      if (!is.null(compare) && nrow(compare) > 0) {
        compare_df <- compare |>
          mutate(
            analog_type = "Comparison",
            product_label = input$compare_analog
          )
        chart_data <- bind_rows(chart_data, compare_df)
      }
      
      # Define colors
      line_colors <- c(
        "Primary" = colors$primary,
        "Comparison" = colors$secondary
      )
      
      # Create chart
      p <- ggplot(chart_data, aes(x = years_since_launch, y = revenue_millions, color = analog_type)) +
        geom_line_interactive(
          aes(
            data_id = product_label,
            tooltip = sprintf(
              "%s\nYear %d: $%s",
              product_label,
              years_since_launch,
              scales::comma(revenue_millions, suffix = "M")
            )
          ),
          linewidth = 1.5
        ) +
        geom_point_interactive(
          aes(
            data_id = product_label,
            tooltip = sprintf(
              "%s\nYear %d: $%s",
              product_label,
              years_since_launch,
              scales::comma(revenue_millions, suffix = "M")
            )
          ),
          size = 3
        ) +
        scale_color_manual(
          values = line_colors,
          name = ""
        ) +
        scale_x_continuous(
          breaks = 0:5,
          labels = paste0("Y", 0:5),
          expand = expansion(mult = 0.05)
        ) +
        scale_y_continuous(
          labels = function(x) {
            ifelse(x >= 1000, 
                   paste0("$", x/1000, "B"),
                   paste0("$", x, "M"))
          },
          expand = expansion(mult = 0.1)
        ) +
        labs(
          x = "Years Since Launch",
          y = "Annual Revenue"
        ) +
        theme_minimal(base_size = 12) +
        theme(
          plot.background = element_rect(fill = colors$card_bg, color = NA),
          panel.background = element_rect(fill = colors$card_bg, color = NA),
          panel.grid.major = element_line(color = colors$border, linewidth = 0.3),
          panel.grid.minor = element_blank(),
          axis.text = element_text(color = colors$text_secondary),
          axis.title = element_text(color = colors$text_primary),
          legend.position = "top",
          legend.text = element_text(color = colors$text_primary)
        )
      
      girafe(
        ggobj = p,
        width_svg = 10,
        height_svg = 4,
        options = list(
          opts_hover(css = "stroke-width: 3px;"),
          opts_tooltip(
            css = sprintf(
              "background-color: %s; color: %s; padding: 8px; border-radius: 4px; font-size: 12px;",
              colors$primary_dark, "white"
            )
          )
        )
      )
    })
    
    # ========================================================================
    # OUTPUT: Context Table
    # ========================================================================
    
    output$context_table <- renderReactable({
      # Force dependencies
      shared$startup_trigger
      input$selected_analog
      input$compare_analog
      
      primary <- primary_data()
      compare <- compare_data()
      primary_m <- calc_metrics(primary_curves())
      compare_m <- calc_metrics(compare_curves())
      
      # Helper to format revenue
      fmt_rev <- function(val) {
        if (is.null(val) || is.na(val)) return("--")
        if (val >= 1000) paste0("$", round(val / 1000, 1), "B")
        else paste0("$", round(val), "M")
      }
      
      # Build context data from available info
      if (is.null(primary) || nrow(primary) == 0) {
        context_data <- data.frame(
          Factor = "Select an analog to view context",
          `Primary Analog` = "--",
          check.names = FALSE
        )
      } else {
        # Safe date formatting
        fmt_date <- function(d) {
          tryCatch({
            format(as.Date(d), "%B %Y")
          }, error = function(e) as.character(d))
        }
        
        primary_col <- c(
          primary$company,
          primary$indication,
          primary$tumor_class,
          fmt_date(primary$approval_date),
          fmt_rev(primary_m$peak),
          fmt_rev(primary_m$year1),
          paste0(primary_m$quarters_to_peak, " quarters")
        )
        
        if (!is.null(compare) && nrow(compare) > 0) {
          compare_col <- c(
            compare$company,
            compare$indication,
            compare$tumor_class,
            fmt_date(compare$approval_date),
            fmt_rev(compare_m$peak),
            fmt_rev(compare_m$year1),
            paste0(compare_m$quarters_to_peak, " quarters")
          )
          
          context_data <- data.frame(
            Factor = c(
              "Company",
              "Indication",
              "Tumor Class",
              "FDA Approval",
              "Peak Revenue",
              "Year 1 Revenue",
              "Time to Peak"
            ),
            Primary = primary_col,
            Comparison = compare_col,
            check.names = FALSE
          )
          
          # Rename columns with product names
          names(context_data) <- c("Factor", input$selected_analog, input$compare_analog)
          
        } else {
          context_data <- data.frame(
            Factor = c(
              "Company",
              "Indication",
              "Tumor Class",
              "FDA Approval",
              "Peak Revenue",
              "Year 1 Revenue",
              "Time to Peak"
            ),
            Primary = primary_col,
            check.names = FALSE
          )
          
          # Rename column with product name
          names(context_data) <- c("Factor", input$selected_analog)
        }
      }
      
      reactable(
        context_data,
        striped = TRUE,
        highlight = TRUE,
        theme = reactableTheme(
          headerStyle = list(
            background = colors$background,
            color = colors$text_primary,
            fontWeight = "bold"
          ),
          stripedColor = colors$background
        ),
        columns = list(
          Factor = colDef(
            style = list(fontWeight = "bold", color = colors$text_primary),
            minWidth = 120
          )
        )
      )
    })
    
  })
}