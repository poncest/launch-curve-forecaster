# ui.R
# Launch Curve Forecaster - Main UI Definition
# This file sources AFTER global.R, so colors, app_info, tabs are available

# ============================================================================
# MAIN UI
# ============================================================================

ui <- semanticPage(
  title = app_info$title,
  
  # Custom CSS and JavaScript
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    
    # JavaScript to trigger Shiny input after page loads
    tags$script(HTML("
      $(document).ready(function() {
        // Fire startup trigger after short delay to ensure Shiny is ready
        setTimeout(function() {
          Shiny.setInputValue('startup_trigger', Date.now());
        }, 50);
      });
    ")),
    
    tags$style(HTML(sprintf("
      :root {
        --color-primary: %s;
        --color-primary-dark: %s;
        --color-primary-light: %s;
        --color-success: %s;
        --color-warning: %s;
        --color-danger: %s;
        --color-text-primary: %s;
        --color-text-secondary: %s;
        --color-background: %s;
        --color-card-bg: %s;
        --color-border: %s;
      }
    ",
                            colors$primary,
                            colors$primary_dark,
                            colors$primary_light,
                            colors$success,
                            colors$warning,
                            colors$danger,
                            colors$text_primary,
                            colors$text_secondary,
                            colors$background,
                            colors$card_bg,
                            colors$border
    )))
  ),
  
  # ============================================================================
  # HEADER
  # ============================================================================
  
  div(
    class = "ui inverted segment",
    style = sprintf(
      "background: linear-gradient(135deg, %s, %s); margin: 0; border-radius: 0;",
      colors$primary_dark,
      colors$primary
    ),
    
    div(
      class = "ui container",
      style = "padding: 2em 0;",
      
      # Title row
      div(
        style = "display: flex; justify-content: space-between; align-items: center;",
        
        # Left: Title
        div(
          h1(
            app_info$title,
            style = "color: white; margin: 0; font-size: 1.8em;"
          ),
          p(
            app_info$subtitle,
            style = "color: rgba(255,255,255,0.85); margin: 0.5em 0 0 0; font-size: 1.1em;"
          )
        ),
        
        # Right: About button
        div(
          tags$button(
            class = "ui inverted basic button",
            onclick = "$('.ui.modal.about').modal('show');",
            icon("info circle"),
            " About"
          )
        )
      )
    )
  ),
  
  # ============================================================================
  # MAIN CONTENT WITH SIDEBAR
  # ============================================================================
  
  div(
    class = "ui container fluid",
    style = "margin-top: 2em; margin-bottom: 3em; padding: 0 3em;",
    
    div(
      class = "ui grid",
      
      # --------------------------------------------------------------------
      # SIDEBAR (3 columns wide - narrower for more content space)
      # --------------------------------------------------------------------
      
      div(
        class = "three wide column",
        style = "padding-right: 0.5em;",
        
        # Navigation menu
        div(
          class = "ui vertical fluid tabular menu",
          id = "main-nav",
          
          # Executive Brief tab
          a(
            class = "active item",
            `data-tab` = tabs$executive_brief$id,
            icon(tabs$executive_brief$icon),
            tabs$executive_brief$title
          ),
          
          # Scenario Builder tab
          a(
            class = "item",
            `data-tab` = tabs$scenario_builder$id,
            icon(tabs$scenario_builder$icon),
            tabs$scenario_builder$title
          ),
          
          # Analog Explorer tab
          a(
            class = "item",
            `data-tab` = tabs$analog_explorer$id,
            icon(tabs$analog_explorer$icon),
            tabs$analog_explorer$title
          ),
          
          # Methods tab
          a(
            class = "item",
            `data-tab` = tabs$methods$id,
            icon(tabs$methods$icon),
            tabs$methods$title
          )
        ),
        
        # Sidebar info card
        div(
          class = "ui segment",
          style = sprintf(
            "margin-top: 1.5em; border-left: 3px solid %s;",
            colors$primary
          ),
          
          h4(
            style = sprintf("color: %s; margin-bottom: 0.5em;", colors$primary_dark),
            icon("lightbulb outline"),
            "Decision Context"
          ),
          p(
            style = sprintf("color: %s; font-size: 0.9em; line-height: 1.5;", colors$text_secondary),
            "Pre-launch planning window (12-18 months). ",
            "Regulatory submission imminent. ",
            "Brand VP must recommend launch timing and forecast commitment ranges."
          )
        )
      ),
      
      # --------------------------------------------------------------------
      # MAIN CONTENT AREA (13 columns wide - more breathing room)
      # --------------------------------------------------------------------
      
      div(
        class = "thirteen wide stretched column",
        style = "padding-left: 1.5em;",
        
        # Executive Brief Tab
        div(
          class = "ui tab active",
          `data-tab` = tabs$executive_brief$id,
          mod_executive_brief_ui("executive_brief")
        ),
        
        # Scenario Builder Tab
        div(
          class = "ui tab",
          `data-tab` = tabs$scenario_builder$id,
          mod_scenario_builder_ui("scenario_builder")
        ),
        
        # Analog Explorer Tab
        div(
          class = "ui tab",
          `data-tab` = tabs$analog_explorer$id,
          mod_analog_explorer_ui("analog_explorer")
        ),
        
        # Methods Tab
        div(
          class = "ui tab",
          `data-tab` = tabs$methods$id,
          mod_methods_ui("methods")
        )
      )
    )
  ),
  
  # ============================================================================
  # FOOTER
  # ============================================================================
  
  tags$footer(
    style = sprintf("
      background: %s;
      color: white;
      padding: 2em 0;
      margin-top: 3em;
      position: relative;
      left: 50%%;
      right: 50%%;
      margin-left: -50vw;
      margin-right: -50vw;
      width: 100vw;
    ", colors$primary_dark),
    
    div(
      class = "ui container",
      div(
        class = "ui grid",
        
        div(
          class = "eight wide column",
          h4(style = "color: white;", "Oncology Launch Curve Forecaster"),
          p(
            style = "color: rgba(255,255,255,0.7); font-size: 0.9em;",
            "A decision-support framework for launch planning. ",
            "This tool does not predict outcomes—it quantifies how assumptions ",
            "translate into revenue risk."
          )
        ),
        
        div(
          class = "eight wide column",
          style = "text-align: right;",
          p(
            style = "color: rgba(255,255,255,0.7); font-size: 0.9em;",
            sprintf("Version %s", app_info$version),
            br(),
            "Created by Steven Ponce",
            br(),
            tags$a(
              href = "https://github.com/poncest",
              target = "_blank",
              style = "color: rgba(255,255,255,0.85);",
              icon("github"),
              " GitHub"
            ),
            " | ",
            tags$a(
              href = "https://www.linkedin.com/in/stevenponce/",
              target = "_blank",
              style = "color: rgba(255,255,255,0.85);",
              icon("linkedin"),
              " LinkedIn"
            )
          )
        )
      )
    )
  ),
  
  # ============================================================================
  # ABOUT MODAL
  # ============================================================================
  
  div(
    class = "ui modal about",
    
    div(class = "header", "About This Framework"),
    
    div(
      class = "content",
      
      h4(
        style = sprintf("color: %s;", colors$primary_dark),
        "Purpose"
      ),
      p(app_info$positioning),
      
      h4(
        style = sprintf("color: %s; margin-top: 1.5em;", colors$primary_dark),
        "What This Does NOT Do"
      ),
      tags$ul(
        style = sprintf("color: %s;", colors$text_secondary),
        lapply(app_info$limitations, function(x) tags$li(x))
      ),
      
      h4(
        style = sprintf("color: %s; margin-top: 1.5em;", colors$primary_dark),
        "Data Sources"
      ),
      tags$ul(
        style = sprintf("color: %s;", colors$text_secondary),
        tags$li("FDA drug approval database (approval dates)"),
        tags$li("Company annual reports and full-year results releases (product-level revenue; each value cited in the repository)")
      ),
      p(
        style = sprintf("color: %s;", colors$text_secondary),
        icon("file alternate outline"), " ",
        tags$a(href = "https://stevenponce.netlify.app/projects/standalone_visualizations/sa_2026-01-28.html",
               target = "_blank", "Read the case study write-up")
      ),
      
      h4(
        style = sprintf("color: %s; margin-top: 1.5em;", colors$primary_dark),
        "Disclaimer"
      ),
      p(
        style = sprintf("color: %s; font-style: italic;", colors$text_muted),
        "This is a portfolio project for demonstration purposes. ",
        "It uses publicly available data and should not be used for actual ",
        "commercial decisions. All analysis reflects publicly reported information."
      )
    ),
    
    div(
      class = "actions",
      div(
        class = "ui primary button",
        onclick = "$('.ui.modal.about').modal('hide');",
        "Close"
      )
    )
  ),
  
  # ============================================================================
  # TAB INITIALIZATION SCRIPT
  # ============================================================================
  
  tags$script(HTML("
    $(document).ready(function() {
      // Initialize Semantic UI tabs
      $('.tabular.menu .item').tab({
        onVisible: function(tabPath) {
          // Notify Shiny when a tab becomes visible
          Shiny.setInputValue('active_tab', tabPath, {priority: 'event'});
          // Tell Shiny this tab's outputs are now visible so suspended outputs re-render
          $('.ui.tab[data-tab=' + tabPath + ']').trigger('shown');
          console.log('Tab switched to: ' + tabPath);
        }
      });
      
      // Fire initial tab signal
      setTimeout(function() {
        Shiny.setInputValue('active_tab', 'executive_brief', {priority: 'event'});
      }, 100);
    });
  "))
)