# mod_methods.R
# Methods & Data Module - Methodology Documentation
#
# Purpose: Transparent documentation of methodology, data sources, and limitations
# This module is critical for AD-level positioning (shows professional judgment)

# ============================================================================
# MODULE UI
# ============================================================================

mod_methods_ui <- function(id) {
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
            icon("book"),
            "Methods & Data"
          ),
          p(
            style = sprintf("color: %s;", colors$text_secondary),
            "Methodology, data sources, assumptions, and limitations"
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
          " About Methods & Data"),
      
      div(
        class = "content",
        
        h4(style = sprintf("color: %s;", colors$primary_dark), "Purpose"),
        p("Transparent documentation of how this framework operates, where the data comes from, and what limitations apply."),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Sections"),
        tags$ul(
          style = sprintf("color: %s; line-height: 1.8;", colors$text_secondary),
          tags$li(tags$strong("Framework Overview"), " - High-level description of the analytical approach"),
          tags$li(tags$strong("Data Sources"), " - Where the analog data comes from (SEC filings, public reports)"),
          tags$li(tags$strong("Analog Inclusion Criteria"), " - Rules that determined which products qualified"),
          tags$li(tags$strong("Key Assumptions"), " - What the model assumes (and doesn't)"),
          tags$li(tags$strong("Limitations"), " - Boundaries of what this framework can and cannot do"),
          tags$li(tags$strong("Parameter Tables"), " - Reference data for model calculations")
        ),
        
        h4(style = sprintf("color: %s; margin-top: 1em;", colors$primary_dark), "Why This Matters"),
        p(
          style = sprintf("color: %s;", colors$text_muted),
          "Documenting methodology and limitations is essential for defensible analysis. ",
          "This section demonstrates transparency and professional judgment."
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
    # FRAMEWORK OVERVIEW
    # ========================================================================
    
    div(
      class = "ui segment",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("sitemap"),
        "Framework Overview"
      ),
      
      p(
        style = sprintf("color: %s; line-height: 1.7;", colors$text_secondary),
        app_info$positioning
      ),
      
      # Framework diagram
      div(
        style = sprintf(
          "margin: 1.5em 0; padding: 2em; background: %s; border-radius: 4px; text-align: center;",
          colors$background
        ),
        
        div(
          style = "display: flex; justify-content: center; align-items: center; flex-wrap: wrap; gap: 1em;",
          
          # Step 1
          div(
            style = sprintf(
              "padding: 1em 1.5em; background: %s; color: white; border-radius: 4px;",
              colors$primary
            ),
            icon("filter"),
            br(),
            "Analog Selection"
          ),
          
          div(style = sprintf("color: %s; font-size: 1.5em;", colors$text_muted), "→"),
          
          # Step 2
          div(
            style = sprintf(
              "padding: 1em 1.5em; background: %s; color: white; border-radius: 4px;",
              colors$primary
            ),
            icon("chart line"),
            br(),
            "Curve Extraction"
          ),
          
          div(style = sprintf("color: %s; font-size: 1.5em;", colors$text_muted), "→"),
          
          # Step 3
          div(
            style = sprintf(
              "padding: 1em 1.5em; background: %s; color: white; border-radius: 4px;",
              colors$primary
            ),
            icon("calculator"),
            br(),
            "Percentile Bands"
          ),
          
          div(style = sprintf("color: %s; font-size: 1.5em;", colors$text_muted), "→"),
          
          # Step 4
          div(
            style = sprintf(
              "padding: 1em 1.5em; background: %s; color: white; border-radius: 4px;",
              colors$success
            ),
            icon("clipboard check"),
            br(),
            "Decision Support"
          )
        )
      )
    ),
    
    # ========================================================================
    # DATA SOURCES
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("database"),
        "Data Sources"
      ),
      
      div(
        class = "ui three column stackable grid",
        style = "margin-top: 1em;",
        
        # Source 1: FDA
        div(
          class = "column",
          div(
            class = "ui segment",
            style = sprintf("border-top: 3px solid %s;", colors$primary),
            h4(
              style = sprintf("color: %s;", colors$primary_dark),
              "FDA Approvals"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em;", colors$text_secondary),
              "Drug approval dates and indication information from FDA's ",
              tags$a(href = "https://www.fda.gov/drugs", target = "_blank", "drug database"),
              "."
            ),
            tags$ul(
              style = sprintf("color: %s; font-size: 0.85em;", colors$text_muted),
              tags$li("Approval dates (T=0 for launch)"),
              tags$li("Indication scope"),
              tags$li("Accelerated approval status")
            )
          )
        ),
        
        # Source 2: SEC Filings
        div(
          class = "column",
          div(
            class = "ui segment",
            style = sprintf("border-top: 3px solid %s;", colors$secondary),
            h4(
              style = sprintf("color: %s;", colors$primary_dark),
              "SEC EDGAR Filings"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em;", colors$text_secondary),
              "Product-level annual revenue from 10-K and 20-F filings via ",
              tags$a(href = "https://www.sec.gov/edgar", target = "_blank", "SEC EDGAR"),
              "."
            ),
            tags$ul(
              style = sprintf("color: %s; font-size: 0.85em;", colors$text_muted),
              tags$li("Annual worldwide product revenue, by fiscal year"),
              tags$li("Geographic breakdown (when available)"),
              tags$li("Product-specific disclosures")
            )
          )
        ),
        
        # Source 3: Literature
        div(
          class = "column",
          div(
            class = "ui segment",
            style = sprintf("border-top: 3px solid %s;", colors$warning),
            h4(
              style = sprintf("color: %s;", colors$primary_dark),
              "Published Literature"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em;", colors$text_secondary),
              "Launch curve patterns and uptake dynamics from peer-reviewed sources."
            ),
            tags$ul(
              style = sprintf("color: %s; font-size: 0.85em;", colors$text_muted),
              tags$li("Oncology launch benchmarks"),
              tags$li("Market access timelines"),
              tags$li("Competitive dynamics")
            )
          )
        )
      )
    ),
    
    # ========================================================================
    # ANALOG SELECTION METHODOLOGY
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("filter"),
        "Analog Selection Methodology"
      ),
      
      p(
        style = sprintf("color: %s; line-height: 1.7;", colors$text_secondary),
        "Analog selection follows a governance-first approach: inclusion criteria are ",
        "specified ", strong("before"), " examining outcome data. This separation ensures ",
        "defensible analysis and prevents post-hoc rationalization."
      ),
      
      h4(
        style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
        "Inclusion Criteria"
      ),
      
      reactableOutput(ns("inclusion_criteria_table")),
      
      h4(
        style = sprintf("color: %s; margin-top: 1.5em;", colors$text_primary),
        "Exclusion Criteria"
      ),
      
      tags$ul(
        style = sprintf("color: %s;", colors$text_secondary),
        tags$li("Products with loss of exclusivity during observation period"),
        tags$li("Products with major safety withdrawals"),
        tags$li("Products with incomplete revenue disclosure"),
        tags$li("Biosimilars and generics")
      )
    ),
    
    # ========================================================================
    # KEY ASSUMPTIONS
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("exclamation triangle"),
        "Key Assumptions"
      ),
      
      p(
        style = sprintf("color: %s; line-height: 1.7; margin-bottom: 1em;", colors$text_secondary),
        "This framework relies on several simplifying assumptions. Users should ",
        "understand these limitations when interpreting results."
      ),
      
      div(
        class = "ui three column stackable grid",
        
        # Assumption 1
        div(
          class = "column",
          div(
            style = sprintf(
              "padding: 1em; background: %s; border-radius: 4px; height: 100%%;",
              colors$background
            ),
            h4(
              style = sprintf("color: %s; margin-bottom: 0.5em;", colors$warning),
              "Analog Relevance"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
              "Past analog performance is informative for future launches. ",
              "Market dynamics, pricing environment, and competitive landscape ",
              "may differ materially."
            )
          )
        ),
        
        # Assumption 2
        div(
          class = "column",
          div(
            style = sprintf(
              "padding: 1em; background: %s; border-radius: 4px; height: 100%%;",
              colors$background
            ),
            h4(
              style = sprintf("color: %s; margin-bottom: 0.5em;", colors$warning),
              "Revenue Attribution"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
              "Product-level revenue reflects launch performance. ",
              "Some products have revenue combined with other assets or ",
              "include ex-US sales not separately disclosed."
            )
          )
        ),
        
        # Assumption 3
        div(
          class = "column",
          div(
            style = sprintf(
              "padding: 1em; background: %s; border-radius: 4px; height: 100%%;",
              colors$background
            ),
            h4(
              style = sprintf("color: %s; margin-bottom: 0.5em;", colors$warning),
              "Scenario Independence"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
              "Delay and market access scenarios are modeled as independent shifts. ",
              "In reality, these factors may interact and compound."
            )
          )
        )
      ),
      
      # Second row of assumptions (Cross-cutting #7 and #8)
      div(
        class = "ui two column stackable grid",
        style = "margin-top: 1em;",
        
        # Assumption 4: Label Expansion Bias (Cross-cutting #7)
        div(
          class = "column",
          div(
            style = sprintf(
              "padding: 1em; background: %s; border-radius: 4px; height: 100%%;",
              colors$background
            ),
            h4(
              style = sprintf("color: %s; margin-bottom: 0.5em;", colors$warning),
              "Label Expansion Bias"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
              "Several analogs (Keytruda, Opdivo, Ibrance) received significant label expansions ",
              "post-launch, inflating observed Year-5 revenues. This creates potential ",
              strong("upward bias"),
              " in P50/P75 scenarios for products without similar expansion potential."
            )
          )
        ),
        
        # Assumption 5: Era Effects (Cross-cutting #8)
        div(
          class = "column",
          div(
            style = sprintf(
              "padding: 1em; background: %s; border-radius: 4px; height: 100%%;",
              colors$background
            ),
            h4(
              style = sprintf("color: %s; margin-bottom: 0.5em;", colors$warning),
              "Era Effects"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
              "Oncology launches post-2018 face different market conditions than 2013–2015 launches ",
              "(pricing pressure, biosimilar competition, value-based contracting). ",
              "Earlier analogs may not fully represent current launch dynamics."
            )
          )
        )
      )
    ),
    
    # ========================================================================
    # WHAT THIS DOES NOT DO
    # ========================================================================
    
    div(
      class = "ui segment",
      style = sprintf(
        "margin-top: 1.5em; border-left: 4px solid %s;",
        colors$danger
      ),
      
      h3(
        style = sprintf("color: %s;", colors$danger),
        icon("times circle"),
        "What This Framework Does NOT Do"
      ),
      
      p(
        style = sprintf("color: %s; line-height: 1.7; margin-bottom: 1em;", colors$text_secondary),
        "Setting clear boundaries is essential for appropriate use. This framework:"
      ),
      
      tags$ul(
        style = sprintf("color: %s; line-height: 1.8;", colors$text_secondary),
        lapply(app_info$limitations, function(limitation) {
          tags$li(
            icon("times", style = sprintf("color: %s;", colors$danger)),
            " ",
            limitation
          )
        })
      ),
      
      div(
        style = sprintf(
          "margin-top: 1em; padding: 1em; background: %s; border-radius: 4px;",
          colors$background
        ),
        p(
          style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_muted),
          icon("info circle"),
          " ",
          strong("Appropriate Use: "),
          "This framework is designed to structure conversations about launch ",
          "assumptions and quantify how those assumptions translate into revenue ranges. ",
          "It supports decision-making; it does not automate it."
        )
      ),
      
      # Design Decisions callout (Cross-cutting #9)
      div(
        style = sprintf(
          "margin-top: 1em; padding: 1em; background: %s; border-left: 3px solid %s; border-radius: 4px;",
          colors$background, colors$primary_light
        ),
        h4(
          style = sprintf("color: %s; margin: 0 0 0.5em 0;", colors$primary_dark),
          icon("lightbulb outline"),
          " Why These Exclusions?"
        ),
        p(
          style = sprintf("color: %s; font-size: 0.9em; margin: 0 0 0.5em 0;", colors$text_secondary),
          strong("NPV/Financial Returns: "),
          "Excluded by design because discount rates, cost assumptions, and terminal values ",
          "require company-specific inputs that would compromise the framework's generalizability. ",
          "Revenue scenarios provide the foundation; financial modeling is a downstream exercise."
        ),
        p(
          style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
          strong("Market Access Dynamics: "),
          "Excluded because payer mix, rebate structures, and formulary timing vary dramatically ",
          "by product, geography, and competitive context. Modeling these would require assumptions ",
          "that obscure rather than clarify the core launch timing trade-offs."
        )
      )
    ),
    
    # ========================================================================
    # TECHNICAL DETAILS
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("code"),
        "Technical Implementation"
      ),
      
      div(
        class = "ui two column stackable grid",
        style = "margin-top: 1em;",
        
        div(
          class = "column",
          h4(style = sprintf("color: %s;", colors$text_primary), "Technology Stack"),
          tags$ul(
            style = sprintf("color: %s;", colors$text_secondary),
            tags$li("R / Shiny for application framework"),
            tags$li("shiny.semantic for UI components"),
            tags$li("ggiraph for interactive visualizations"),
            tags$li("reactable for data tables"),
            tags$li("Deployed on shinyapps.io")
          )
        ),
        
        div(
          class = "column",
          h4(style = sprintf("color: %s;", colors$text_primary), "Data Processing"),
          tags$ul(
            style = sprintf("color: %s;", colors$text_secondary),
            tags$li("Annual revenue aligned to approval year (Year 0 = partial launch year; Year 1 = first full year)"),
            tags$li("Every analog is observed through Year 5, so the app reports Year-5 revenue rather than a lifetime peak; every analog was still growing at Year 5"),
            tags$li("Percentiles calculated across analog set"),
            tags$li("Revenue scaled to millions USD"),
            tags$li("All data from public sources")
          )
        )
      )
    ),
    
    # ========================================================================
    # REFERENCES
    # ========================================================================
    
    div(
      class = "ui segment",
      style = "margin-top: 1.5em;",
      
      h3(
        style = sprintf("color: %s;", colors$primary_dark),
        icon("bookmark"),
        "References"
      ),
      
      p(
        style = sprintf("color: %s; font-style: italic;", colors$text_muted),
        "Selected references informing methodology and assumptions:"
      ),
      
      tags$ol(
        style = sprintf("color: %s; line-height: 1.8;", colors$text_secondary),
        tags$li("FDA Drug Approval Database. U.S. Food and Drug Administration."),
        tags$li("SEC EDGAR Company Filings. U.S. Securities and Exchange Commission.")
      )
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

mod_methods_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ========================================================================
    # OUTPUT: Inclusion Criteria Table
    # ========================================================================
    
    output$inclusion_criteria_table <- renderReactable({
      
      criteria_data <- data.frame(
        Criterion = c(
          "Therapeutic Area",
          "Launch Window",
          "Revenue Threshold",
          "Data Availability"
        ),
        Specification = c(
          "Oncology (solid tumors and hematology)",
          "FDA approval 2013-2017",
          "Configurable minimum Year-5 revenue",
          "Product-level revenue disclosed in SEC filings"
        ),
        Rationale = c(
          "Focus on therapeutic area with established launch patterns",
          "Recent enough to be relevant, early enough for five full years of disclosed revenue",
          "Exclude niche products with limited comparability",
          "Ensures consistent measurement across analogs"
        ),
        stringsAsFactors = FALSE
      )
      
      reactable(
        criteria_data,
        striped = TRUE,
        highlight = TRUE,
        columns = list(
          Criterion = colDef(
            width = 150,
            style = list(fontWeight = "bold")
          ),
          Specification = colDef(width = 250),
          Rationale = colDef(minWidth = 200)
        ),
        theme = reactableTheme(
          headerStyle = list(
            background = colors$background,
            color = colors$text_primary,
            fontWeight = "bold"
          ),
          stripedColor = colors$background
        )
      )
    })
    
    # ========================================================================
    # FORCE OUTPUTS TO RENDER (fix for CSS-based tabs)
    # ========================================================================
    
    outputOptions(output, "inclusion_criteria_table", suspendWhenHidden = FALSE)
    
  })
}