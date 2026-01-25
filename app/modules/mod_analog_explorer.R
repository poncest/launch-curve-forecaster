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
      if (!app_data$is_placeholder && nrow(app_data$analogs) > 0) {
        choices <- setNames(
          app_data$analogs$product_name,
          paste0(app_data$analogs$product_name, " (", app_data$analogs$company, ")")
        )
        
        updateSelectInput(
          session,
          "selected_analog",
          choices = choices
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
      req(input$selected_analog)
      
      if (app_data$is_placeholder) return(NULL)
      
      app_data$analogs |>
        filter(product_name == input$selected_analog)
    })
    
    # ========================================================================
    # OUTPUTS: Primary Analog Info
    # ========================================================================
    
    output$primary_analog_name <- renderUI({
      if (is.null(primary_data()) || nrow(primary_data()) == 0) {
        "Select an analog"
      } else {
        primary_data()$product_name
      }
    })
    
    output$primary_peak <- renderUI({
      # Placeholder - will calculate from curves data
      "$2.1B"
    })
    
    output$primary_ttp <- renderUI({
      "12"
    })
    
    output$primary_y1 <- renderUI({
      "$450M"
    })
    
    output$primary_y3 <- renderUI({
      "$1.8B"
    })
    
    output$primary_characteristics <- renderUI({
      if (is.null(primary_data()) || nrow(primary_data()) == 0) {
        return(p("Select an analog to view characteristics"))
      }
      
      product <- primary_data()
      
      tags$ul(
        style = sprintf("color: %s;", colors$text_secondary),
        tags$li(paste0("Company: ", product$company)),
        tags$li(paste0("Indication: ", product$indication)),
        tags$li(paste0("Line of Therapy: ", product$line_of_therapy)),
        tags$li(paste0("Approval: ", format(product$approval_date, "%B %Y")))
      )
    })
    
    # ========================================================================
    # OUTPUT: Comparison Panel (conditional)
    # ========================================================================
    
    output$compare_panel <- renderUI({
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
        # Comparison analog details
        div(
          class = "ui segment",
          style = sprintf("border-top: 3px solid %s;", colors$secondary),
          
          h3(
            style = sprintf("color: %s;", colors$secondary),
            input$compare_analog
          ),
          
          # Similar structure to primary
          div(
            class = "ui four statistics mini",
            style = "margin: 1.5em 0;",
            
            div(
              class = "statistic",
              div(class = "value", "$1.5B"),
              div(class = "label", "Peak Revenue")
            ),
            div(
              class = "statistic",
              div(class = "value", "16"),
              div(class = "label", "Quarters to Peak")
            ),
            div(
              class = "statistic",
              div(class = "value", "$280M"),
              div(class = "label", "Year 1")
            ),
            div(
              class = "statistic",
              div(class = "value", "$1.2B"),
              div(class = "label", "Year 3")
            )
          ),
          
          h4(style = sprintf("color: %s;", colors$text_primary), "Characteristics"),
          tags$ul(
            style = sprintf("color: %s;", colors$text_secondary),
            tags$li("Company: Example Pharma"),
            tags$li("Indication: Solid tumor"),
            tags$li("Line of Therapy: 2L+"),
            tags$li("Approval: January 2019")
          )
        )
      }
    })
    
    # ========================================================================
    # OUTPUT: Comparison Chart
    # ========================================================================
    
    output$comparison_chart <- renderGirafe({
      
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
      
      # Placeholder chart
      p <- ggplot() +
        annotate(
          "text",
          x = 0.5, y = 0.5,
          label = "Launch curve comparison chart\n(Implementation pending data)",
          size = 5,
          color = colors$text_secondary
        ) +
        theme_void() +
        theme(plot.background = element_rect(fill = colors$card_bg, color = NA))
      
      girafe(ggobj = p, width_svg = 10, height_svg = 4)
    })
    
    # ========================================================================
    # OUTPUT: Context Table
    # ========================================================================
    
    output$context_table <- renderReactable({
      
      # Placeholder context data
      context_data <- data.frame(
        Factor = c(
          "Competitive Landscape",
          "Market Access",
          "Label Breadth",
          "Companion Diagnostic"
        ),
        `Primary Analog` = c(
          "First-in-class",
          "Rapid formulary",
          "Multiple indications",
          "Not required"
        ),
        `Comparison` = c(
          "--",
          "--",
          "--",
          "--"
        ),
        check.names = FALSE
      )
      
      reactable(
        context_data,
        striped = TRUE,
        highlight = TRUE,
        theme = reactableTheme(
          headerStyle = list(
            background = colors$background,
            color = colors$text_primary,
            fontWeight = "bold"
          )
        )
      )
    })
    
  })
}
