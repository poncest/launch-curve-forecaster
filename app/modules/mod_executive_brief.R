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
    # Header with help icon
    div(
      style = "margin-bottom: 1.5em;",
      div(
        style = "display: flex; justify-content: space-between; align-items: flex-start;",
        div(
          h2(
            style = sprintf("color: %s; margin-bottom: 0.25em;", colors$primary_dark),
            icon("dashboard"),
            "Executive Brief"
          ),
          p(
            style = sprintf("color: %s;", colors$text_secondary),
            "Key metrics, scenario comparison, and decision trade-offs"
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
          " How to Use Executive Brief"),
      
      div(
        class = "content",
        
        h4(style = sprintf("color: %s;", colors$primary_dark), "Purpose"),
        p("VP-level summary showing key metrics and scenario outcomes based on your analog selection and delay assumptions."),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Key Sections"),
        tags$ul(
          style = sprintf("color: %s; line-height: 1.8;", colors$text_secondary),
          tags$li(tags$strong("KPI Cards"), " - High-level metrics: analog count, Year-5 revenue (P50), cost of delay, median Year-1 revenue"),
          tags$li(tags$strong("Launch Trajectory Chart"), " - P25/P50/P75 revenue bands over Years 0-5"),
          tags$li(tags$strong("Decision Cards"), " - Launch timing impact and forecast range interpretation")
        ),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "How It Connects"),
        tags$ul(
          style = sprintf("color: %s;", colors$text_muted),
          tags$li("Metrics update when you ", tags$strong("Apply Selection"), " in Scenario Builder"),
          tags$li("Cost of Delay reflects your chosen delay scenario"),
          tags$li("P25/P50/P75 bands are calculated from your selected analog set")
        ),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Tip"),
        p(
          style = sprintf("color: %s;", colors$text_muted),
          "Hover over the (i) icons on each KPI card for metric-specific explanations."
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
            "text-align: center; padding: 1.5em 1em; border-top: 3px solid %s; min-height: 140px; position: relative;",
            colors$primary
          ),
          # Info icon with tooltip
          tags$span(
            style = sprintf("position: absolute; top: 10px; right: 10px; color: %s; cursor: help;", colors$text_muted),
            title = "Number of oncology products included in the analog set for forecasting",
            icon("info circle")
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$primary),
            uiOutput(ns("kpi_analogs"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em; text-transform: uppercase; letter-spacing: 0.5px;", colors$text_secondary),
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
            "text-align: center; padding: 1.5em 1em; border-top: 3px solid %s; min-height: 140px; position: relative;",
            colors$primary
          ),
          # Info icon with tooltip
          tags$span(
            style = sprintf("position: absolute; top: 10px; right: 10px; color: %s; cursor: help;", colors$text_muted),
            title = "Median (P50) Year-5 annual revenue across selected analogs: the fifth full year after launch, the last year observed for every analog (not a lifetime peak). Range shows P25-P75 bounds.",
            icon("info circle")
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$primary),
            uiOutput(ns("kpi_peak_revenue"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em; text-transform: uppercase; letter-spacing: 0.5px;", colors$text_secondary),
            uiOutput(ns("kpi_peak_label"), inline = TRUE)
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
            "text-align: center; padding: 1.5em 1em; border-top: 3px solid %s; min-height: 140px; position: relative;",
            colors$primary
          ),
          # Info icon with tooltip
          tags$span(
            style = sprintf("position: absolute; top: 10px; right: 10px; color: %s; cursor: help;", colors$text_muted),
            title = "Sales lost to the launch delay set in the Scenario Builder if the exclusivity end date is fixed: the delayed quarters come off the end of exclusivity, valued at the P50 Year-5 run rate (a lower bound, since analogs were still growing). The smaller figure is first-year sales that are only deferred.",
            icon("info circle")
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$primary),
            uiOutput(ns("kpi_revenue_at_risk"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em; text-transform: uppercase; letter-spacing: 0.5px;", colors$text_secondary),
            "Cost of Delay (Fixed Expiry)"
          ),
          div(
            style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.25em;", colors$text_muted),
            uiOutput(ns("kpi_risk_context"), inline = TRUE)
          )
        )
      ),
      
      # KPI 4: Time to Peak
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "text-align: center; padding: 1.5em 1em; border-top: 3px solid %s; min-height: 140px; position: relative;",
            colors$primary
          ),
          # Info icon with tooltip
          tags$span(
            style = sprintf("position: absolute; top: 10px; right: 10px; color: %s; cursor: help;", colors$text_muted),
            title = "Median revenue in the first full year after launch across selected analogs. This is the basis of the deferred-sales figure.",
            icon("info circle")
          ),
          div(
            style = sprintf("font-size: 2.5em; font-weight: bold; color: %s;", colors$primary),
            uiOutput(ns("kpi_time_to_peak"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.95em; margin-top: 0.5em; text-transform: uppercase; letter-spacing: 0.5px;", colors$text_secondary),
            uiOutput(ns("kpi_time_label"), inline = TRUE)
          ),
          div(
            style = sprintf("color: %s; font-size: 0.85em; margin-top: 0.25em;", colors$text_muted),
            uiOutput(ns("kpi_time_context"), inline = TRUE)
          )
        )
      )
    ),
    
    # ========================================================================
    # LAUNCH CURVE CHART (FULL WIDTH)
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "padding: 1.5em; margin-bottom: 1.5em;",
      
      h3(
        style = sprintf("color: %s; margin-bottom: 0.5em;", colors$primary_dark),
        "Launch Trajectory Scenarios"
      ),
      p(
        style = sprintf("color: %s; margin-bottom: 1em;", colors$text_muted),
        "P25/P50/P75 bands based on selected analog performance"
      ),
      
      # Interactive chart - full width
      girafeOutput(ns("launch_curve_chart"), height = "420px"),
      
      # Demand deferral assumption callout (P0 - must be impossible to miss)
      div(
        style = sprintf(
          "margin-top: 1em; padding: 0.75em 1em; background: %s; border-left: 3px solid %s; border-radius: 4px;",
          colors$background, colors$warning
        ),
        p(
          style = sprintf("color: %s; margin: 0; font-size: 0.9em;", colors$text_secondary),
          icon("info circle"),
          " ",
          strong("Key Assumption:"),
          " A delay usually does not move the exclusivity end date, so the delayed months are ",
          strong("lost at the end of exclusivity, near peak sales"),
          ", not just shifted. First-year sales that are only deferred are shown for comparison. ",
          "Share lost to earlier competitors and market access are not modeled."
        )
      )
    ),
    
    # ========================================================================
    # DECISION CARDS ROW (Two cards side by side below chart)
    # ========================================================================
    
    div(
      class = "ui two column stackable grid",
      style = "margin-bottom: 1.5em;",
      
      # Decision Box 1: Launch Timing
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "border-left: 4px solid %s; height: 100%%;",
            colors$warning
          ),
          
          h4(
            style = sprintf("color: %s; margin-bottom: 0.5em;", colors$primary_dark),
            icon("clock outline"),
            "Decision: Launch Timing"
          ),
          p(
            style = sprintf("color: %s; font-size: 0.95em; margin-bottom: 0.75em;", colors$text_secondary),
            strong("Trade-off:"), " Speed vs. readiness"
          ),
          
          div(
            style = sprintf(
              "background: %s; padding: 1em; border-radius: 4px;",
              colors$background
            ),
            p(
              style = sprintf("color: %s; margin: 0; font-size: 0.9em; line-height: 1.5;", colors$text_primary),
              uiOutput(ns("decision_timing"), inline = TRUE)
            )
          )
        )
      ),
      
      # Decision Box 2: Forecast Commitment
      div(
        class = "column",
        div(
          class = "ui segment",
          style = sprintf(
            "border-left: 4px solid %s; height: 100%%;",
            colors$primary
          ),
          
          h4(
            style = sprintf("color: %s; margin-bottom: 0.5em;", colors$primary_dark),
            icon("chart bar outline"),
            "Decision: Forecast Commitment"
          ),
          p(
            style = sprintf("color: %s; font-size: 0.95em; margin-bottom: 0.75em;", colors$text_secondary),
            strong("Trade-off:"), " Alignment vs. credibility risk"
          ),
          
          div(
            style = sprintf(
              "background: %s; padding: 1em; border-radius: 4px;",
              colors$background
            ),
            p(
              style = sprintf("color: %s; margin: 0; font-size: 0.9em; line-height: 1.5;", colors$text_primary),
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
      style = "margin-top: 1em;",
      
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
      base_data <- if (is.null(shared$selected_analogs) || length(shared$selected_analogs) == 0) {
        app_data$analogs
      } else {
        app_data$analogs |>
          filter(product_name %in% shared$selected_analogs)
      }
      
      # Ensure unique products (in case source data has duplicates)
      base_data |>
        distinct(product_name, .keep_all = TRUE)
    })
    
    # ========================================================================
    # REACTIVE: Calculated Metrics
    # ========================================================================
    
    metrics <- reactive({
      
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
        summarise(
          peak_revenue = max(revenue_millions, na.rm = TRUE),
          years_to_peak = years_since_launch[which.max(revenue_millions)],
          .groups = "drop"
        )
      
      # Get delay from shared (default to 2 quarters / 6 months if not set)
      delay_q <- if (!is.null(shared$delay_quarters)) shared$delay_quarters else 2
      
      # Calculate revenue at risk based on delay
      # Get Year 1 median revenue across selected analogs
      year1_data <- curves |>
        filter(years_since_launch == 1)
      
      year1_median <- if (nrow(year1_data) > 0) {
        median(year1_data$revenue_millions, na.rm = TRUE)
      } else {
        median(peaks$peak_revenue, na.rm = TRUE) * 0.3  # Fallback estimate
      }
      
      # Revenue at risk = delay quarters * (Year 1 revenue / 4)
      revenue_at_risk_calc <- delay_q * (year1_median / 4)
      year1_range_calc <- if (nrow(year1_data) > 0) {
        quantile(year1_data$revenue_millions, c(0.25, 0.75), na.rm = TRUE)
      } else c(0, 0)
      lost_calc <- delay_q / 4 * median(peaks$peak_revenue, na.rm = TRUE)

      # Product mode: scale the analogs' launch shapes (share of own Year 5)
      # to the expected Year-5 revenue entered in the Scenario Builder
      expected <- shared$expected_y5
      product_mode <- valid_expected(expected)
      if (product_mode) {
        y1_shape <- analog_shapes(curves)
        y1_shape <- y1_shape$shape[y1_shape$years_since_launch == 1]
        year1_median <- median(y1_shape, na.rm = TRUE) * expected
        year1_range_calc <- quantile(y1_shape, c(0.25, 0.75), na.rm = TRUE) * expected
        revenue_at_risk_calc <- delay_q * (year1_median / 4)
        lost_calc <- delay_q / 4 * expected
      }
      
      # Calculate percentiles
      list(
        n_analogs = nrow(selected_data()),
        peak_p50 = median(peaks$peak_revenue, na.rm = TRUE),
        peak_p25 = quantile(peaks$peak_revenue, 0.25, na.rm = TRUE),
        peak_p75 = quantile(peaks$peak_revenue, 0.75, na.rm = TRUE),
        revenue_at_risk = revenue_at_risk_calc,
        # If the exclusivity end date is fixed, a delay of d quarters removes d
        # quarters of sales at the end of exclusivity. Valued at the P50 Year-5
        # run rate: a lower bound, since every analog was still growing at Year 5.
        revenue_lost_fixed_expiry = lost_calc,
        product_mode = product_mode,
        expected_y5 = if (product_mode) expected else NA,
        year1_median = if (nrow(year1_data) > 0) year1_median else 0,
        year1_range = year1_range_calc,
        delay_quarters = delay_q,
        quarters_to_peak = round(median(peaks$years_to_peak, na.rm = TRUE) * 4),
        quarters_range = c(
          round(min(peaks$years_to_peak, na.rm = TRUE) * 4),
          round(max(peaks$years_to_peak, na.rm = TRUE) * 4)
        )
      )
    })
    
    # ========================================================================
    # KPI OUTPUTS
    # ========================================================================
    
    fmt_revenue <- function(val) {
      if (val >= 1000) paste0("$", round(val / 1000, 1), "B") else paste0("$", round(val), "M")
    }
    
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
    
    output$kpi_peak_label <- renderUI({
      if (isTRUE(metrics()$product_mode)) "Your Year-5 Revenue (Input)" else "Base Case Year-5 Revenue (P50)"
    })

    output$kpi_time_label <- renderUI({
      if (isTRUE(metrics()$product_mode)) "Implied Year-1 Revenue" else "Median Year-1 Revenue"
    })

    output$kpi_peak_revenue <- renderUI({
      m <- metrics()
      if (isTRUE(m$product_mode)) return(fmt_money(m$expected_y5))
      if (m$peak_p50 == 0) {
        "--"
      } else {
        # Inline formatting (avoiding helper function scoping issues)
        paste0("$", round(m$peak_p50 / 1000, 1), "B")
      }
    })
    
    output$kpi_peak_context <- renderUI({
      m <- metrics()
      if (isTRUE(m$product_mode)) {
        return(paste0("Analogs' P50 is ", fmt_money(m$peak_p50), "; Years 0-4 follow their launch shapes"))
      }
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
      if (is.null(m$revenue_lost_fixed_expiry) || m$revenue_lost_fixed_expiry == 0) {
        "--"
      } else {
        fmt_money(m$revenue_lost_fixed_expiry)
      }
    })
    
    output$kpi_risk_context <- renderUI({
      m <- metrics()
      delay_q <- m$delay_quarters
      if (is.null(delay_q) || delay_q == 0) {
        "No delay selected"
      } else {
        paste0(delay_q, "-quarter delay; $", format(round(m$revenue_at_risk), big.mark = ","),
               "M of Year-1 sales only deferred")
      }
    })
    
    output$kpi_time_to_peak <- renderUI({
      m <- metrics()
      if (m$year1_median == 0) "--" else fmt_revenue(m$year1_median)
    })
    
    output$kpi_time_context <- renderUI({
      m <- metrics()
      if (m$year1_median == 0) {
        "First full year after launch"
      } else {
        paste0("Range: ", fmt_revenue(m$year1_range[1]), " - ", fmt_revenue(m$year1_range[2]),
               " (basis for deferred sales)")
      }
    })
    
    # ========================================================================
    # DECISION TEXT OUTPUTS
    # ========================================================================
    
    output$decision_timing <- renderUI({
      m <- metrics()
      if (m$revenue_at_risk == 0 || is.null(m$delay_quarters) || m$delay_quarters == 0) {
        "Select a delay scenario in Scenario Builder to see timing analysis."
      } else {
        delay_months <- m$delay_quarters * 3
        paste0(
          "A ", m$delay_quarters, "-quarter (", delay_months, "-month) delay moves about $",
          format(round(m$revenue_at_risk), big.mark = ","), "M of first-year sales later. ",
          "If the exclusivity end date is fixed, it also removes the last ", delay_months,
          " months of exclusivity: at least ", fmt_money(m$revenue_lost_fixed_expiry),
          if (isTRUE(m$product_mode)) " at your Year-5 run rate." else " at the P50 Year-5 run rate.",
          " Share lost to earlier competitors would add to this."
        )
      }
    })
    
    output$decision_forecast <- renderUI({
      m <- metrics()
      if (isTRUE(m$product_mode)) {
        paste0(
          "Scaled to your Year-5 input of ", fmt_money(m$expected_y5), ", the analogs' median launch shape ",
          "implies ", fmt_money(m$year1_median), " in Year 1 (P25-P75 shapes: ", fmt_money(m$year1_range[1]),
          " to ", fmt_money(m$year1_range[2]), "). A Year-1 plan below the P25 shape implies a slower ",
          "start than three-quarters of the analogs."
        )
      } else if (m$peak_p50 == 0) {
        "Configure analogs in Scenario Builder to see forecast analysis."
      } else {
        paste0(
          "Committing to P50 forecast ($", round(m$peak_p50 / 1000, 1), "B Year-5 revenue) ",
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
        
        girafe(ggobj = p, width_svg = 10, height_svg = 5)
        
      } else {
        # Real chart with data
        # Filter to selected analogs
        curves <- app_data$curves |>
          filter(product_name %in% selected_data()$product_name)

        # Product mode: each analog's shape scaled to the user's Year-5 input
        m_now <- metrics()
        if (isTRUE(m_now$product_mode)) {
          curves <- analog_shapes(curves)
          curves$revenue_millions <- curves$shape * m_now$expected_y5
        }
        
        # Calculate percentile bands
        bands <- curves |>
          group_by(years_since_launch) |>
          summarise(
            p25 = quantile(revenue_millions, 0.25, na.rm = TRUE),
            p50 = quantile(revenue_millions, 0.50, na.rm = TRUE),
            p75 = quantile(revenue_millions, 0.75, na.rm = TRUE),
            .groups = "drop"
          )
        
        # Build the chart
        p <- ggplot() +
          # P25-P75 ribbon
          geom_ribbon(
            data = bands,
            aes(x = years_since_launch, ymin = p25, ymax = p75),
            fill = colors$primary_light,
            alpha = 0.3
          ) +
          # P50 line
          geom_line(
            data = bands,
            aes(x = years_since_launch, y = p50),
            color = colors$primary,
            linewidth = 1.5
          ) +
          # Individual analog lines (interactive)
          geom_line_interactive(
            data = curves,
            aes(
              x = years_since_launch,
              y = revenue_millions,
              group = product_name,
              tooltip = paste0(
                "<strong>", product_name, "</strong><br>",
                "Year ", years_since_launch, ": $",
                scales::comma(round(revenue_millions)), "M"
              ),
              data_id = product_name
            ),
            color = colors$text_muted,
            linewidth = 0.7,
            alpha = 0.5
          ) +
          # Labels
          labs(
            x = "Years Since Launch",
            y = if (isTRUE(m_now$product_mode)) "Projected revenue for your product ($M)" else "Revenue ($M)",
            caption = paste0(
              if (isTRUE(m_now$product_mode))
                paste0("Analog launch shapes scaled to your Year-5 input of ", fmt_money(m_now$expected_y5), "\n") else "",
              "Gray lines = individual analogs | Blue line = P50 median | Shaded area = P25-P75 range | ",
              "n = ", dplyr::n_distinct(curves$product_name), " analogs",
              if (dplyr::n_distinct(curves$product_name) < 5)
                " (with fewer than 5, P25/P75 interpolate between single products: read as a rough spread)" else ""
            )
          ) +
          scale_x_continuous(breaks = 0:5, limits = c(0, 5)) +
          scale_y_continuous(labels = scales::comma_format()) +
          theme_launch()
        
        girafe(
          ggobj = p,
          width_svg = 10,
          height_svg = 5,
          options = list(
            opts_hover(css = "stroke-width: 2; stroke-opacity: 1;"),
            opts_hover_inv(css = "opacity: 0.2;"),
            opts_tooltip(
              css = sprintf(
                "background: white; border: 1px solid %s; border-radius: 4px; padding: 8px 12px; font-size: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);",
                colors$border
              )
            )
          )
        )
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
          `Approval Date` = "--",
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
        # Real table - aggressive deduplication
        raw_data <- selected_data()
        
        # Create table data with explicit unique() as backup
        table_data <- data.frame(
          Product = raw_data$product_name,
          Company = raw_data$company,
          `Approval Date` = raw_data$approval_date,
          Indication = raw_data$indication,
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
        
        # Remove duplicates by Product name
        table_data <- table_data[!duplicated(table_data$Product), ]
        
        # Sort alphabetically
        table_data <- table_data[order(table_data$Product), ]
        
        # Debug: print to console
        message("Table rows after dedup: ", nrow(table_data))
        
        reactable(
          table_data,
          searchable = FALSE,
          pagination = FALSE,
          defaultPageSize = 10,
          striped = TRUE,
          highlight = TRUE,
          compact = TRUE,
          theme = reactableTheme(
            headerStyle = list(
              background = colors$background,
              color = colors$text_primary,
              fontWeight = "bold",
              borderBottom = sprintf("2px solid %s", colors$border)
            ),
            stripedColor = colors$background,
            cellPadding = "10px 14px"
          ),
          columns = list(
            Product = colDef(minWidth = 100),
            Company = colDef(minWidth = 100),
            `Approval Date` = colDef(minWidth = 100, align = "center"),
            Indication = colDef(minWidth = 150)
          )
        )
      }
    })
    
    # ========================================================================
    # FORCE OUTPUTS TO RENDER (fix for CSS-based tabs)
    # ========================================================================
    
    outputOptions(output, "kpi_analogs", suspendWhenHidden = FALSE)
    outputOptions(output, "kpi_peak_revenue", suspendWhenHidden = FALSE)
    outputOptions(output, "kpi_revenue_at_risk", suspendWhenHidden = FALSE)
    outputOptions(output, "kpi_time_to_peak", suspendWhenHidden = FALSE)
    outputOptions(output, "launch_curve_chart", suspendWhenHidden = FALSE)
    outputOptions(output, "analog_table", suspendWhenHidden = FALSE)
    # Small text outputs that depend on the selection: always render them so
    # they can never lag the headline KPIs, even where tab visibility
    # detection fails (hidden panes, embedded iframes)
    for (id in c("kpi_analogs_context", "kpi_peak_context", "kpi_risk_context",
                 "kpi_time_context", "decision_timing", "decision_forecast",
                 "kpi_peak_label", "kpi_time_label")) {
      outputOptions(output, id, suspendWhenHidden = FALSE)
    }
    
  })
}