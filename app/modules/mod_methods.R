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
              tags$li("Initial indication")
            )
          )
        ),
        
        # Source 2: Company-reported revenue
        div(
          class = "column",
          div(
            class = "ui segment",
            style = sprintf("border-top: 3px solid %s;", colors$secondary),
            h4(
              style = sprintf("color: %s;", colors$primary_dark),
              "Company-Reported Revenue"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em;", colors$text_secondary),
              "Full-year worldwide product sales from each owner's annual report, full-year ",
              "results release or investor materials (SEC filings via ",
              tags$a(href = "https://www.sec.gov/edgar", target = "_blank", "SEC EDGAR"),
              "; European and Japanese company reports). Every value cites its source in ",
              tags$code("data/raw/sec_product_revenue.csv"), "."
            ),
            tags$ul(
              style = sprintf("color: %s; font-size: 0.85em;", colors$text_muted),
              tags$li("Annual worldwide product sales, by fiscal year"),
              tags$li("USD; CHF, EUR and JPY converted at Federal Reserve average rates for the same period"),
              tags$li("Re-sourced and verified October 2026")
            )
          )
        ),
        
        # Source 3: Definitions that differ by product
        div(
          class = "column",
          div(
            class = "ui segment",
            style = sprintf("border-top: 3px solid %s;", colors$warning),
            h4(
              style = sprintf("color: %s;", colors$primary_dark),
              "Definitions & Data Status"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em;", colors$text_secondary),
              "Where a product's reporting differs, the rule used or the exception is noted:"
            ),
            tags$ul(
              style = sprintf("color: %s; font-size: 0.85em;", colors$text_muted),
              tags$li("CHF, EUR and JPY figures (Roche, Bayer, Merck KGaA, Eisai, Takeda) converted at Federal Reserve average rates for the same period"),
              tags$li("Worldwide sales are aligned to the US approval date. Where a drug was sold elsewhere first (Alecensa in Japan from 2014), early launch years include those sales; where it launched outside the US later, they are lower than a simultaneous global launch"),
              tags$li("Nerlynx: Puma's product revenue (mostly US; partners outside the US pay royalties). Bavencio: Merck KGaA's sales. Takeda figures include royalty and service income"),
              tags$li("Imbruvica: US sales (Pharmacyclics, then AbbVie) plus J&J ex-US sales"),
              tags$li("Opdivo: BMS-reported, excluding Ono's territories (Japan, Korea, Taiwan), so it understates global sales"),
              tags$li(data_status_note)
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
        "defensible analysis and prevents post-hoc rationalization. The two filters in the ",
        "Scenario Builder that use outcomes (minimum Year-5 revenue, excluding the top analog) ",
        "are therefore sensitivity checks, not selection criteria."
      ),
      p(
        style = sprintf("color: %s; line-height: 1.7;", colors$text_secondary),
        strong("Complete set: "), "every new oncology molecular entity first approved by the FDA from 2013 ",
        "to 2017 was screened (56 products). 30 are included, among them modest launches and one withdrawn ",
        "drug (Lartruvo), so the bands describe typical launches rather than only blockbusters. ",
        "16 were dropped because their owner did not report their sales separately for every year, or because ",
        "ownership changed during the first five years; 10 were out of scope (CAR-T cell therapies, supportive-care ",
        "and imaging products, reformulations). Each decision and its reason is listed in ",
        tags$code("data/raw/expansion/candidates.csv"), ". An earlier version used ten prominent launches, ",
        "which put the P50 Year-5 revenue about four times higher."
      ),
      p(
        style = sprintf("color: %s; line-height: 1.7;", colors$text_secondary),
        strong("Remaining bias, direction unknown: "), "the 16 dropped drugs include small launches ",
        "(Farydak, Odomzo, Portrazza) and large ones (Tafinlar + Mekinist, Zejula), so dropping them could ",
        "push the bands either way, and the size of the effect is not known."
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
        tags$li("Products without separately reported revenue for Years 1-5, or whose owner changed within them"),
        tags$li("Supportive-care and imaging products, reformulations of approved drugs, biosimilars and generics"),
        tags$li("Withdrawn products are kept (Lartruvo): dropping launches that failed would bias the bands upward")
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
              "Values are company-reported worldwide product sales, which combine uptake, ",
              "price and label expansion. Reporting conventions differ slightly by company ",
              "(see Definitions & Data Status above)."
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
              "Launch-Year Alignment"
            ),
            p(
              style = sprintf("color: %s; font-size: 0.9em; margin: 0;", colors$text_secondary),
              alignment_note
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
              "The analogs cover FDA approvals from 2013 to 2017 only; launches after 2018 face different market conditions ",
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
            tags$li("Launch years counted from each drug's exact FDA approval date (Year 1 = first 12 months); fiscal-year sales split across launch years in proportion to days"),
            tags$li("Every analog is observed through Year 5, so the app reports Year-5 revenue rather than a lifetime peak; most analogs were still growing at Year 5"),
            tags$li("Percentiles calculated across analog set"),
            tags$li("Optional product mode: each analog's revenue divided by its own Year-5 revenue gives its launch shape; the shapes are scaled to the Year-5 revenue entered for your product, so analogs inform the ramp, not the size"),
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
          "Product Type",
          "Launch Window",
          "Data Availability"
        ),
        Specification = c(
          "Oncology treatments (solid tumors and hematology)",
          "New molecular entity; CAR-T cell therapies excluded",
          "First FDA approval 2013-2017",
          "Sales reported separately by one owner for Years 1-5"
        ),
        Rationale = c(
          "Focus on therapeutic area with established launch patterns",
          "CAR-T launches are paced by treatment-center certification and manufacturing slots, a different model",
          "Recent enough to be relevant, early enough for five years of disclosed revenue",
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