# app.R
# Launch Curve Forecaster - Application Entry Point
#
# ARCHITECTURE NOTE:
# We use EXPLICIT source() calls instead of relying on R/ folder auto-sourcing.
# This is critical because:
#   1. Files in R/ folder are sourced BEFORE global.R
#   2. Our modules depend on objects defined in global.R (colors, app_info, etc.)
#   3. Explicit sourcing gives us control over loading order
#
# Loading order:
#   1. global.R (packages, constants, data)
#   2. modules/*.R (UI and server functions)
#   3. utils/*.R (helper functions)
#   4. ui.R (main UI - uses module UI functions)
#   5. server.R (main server - calls module servers)
#   6. shinyApp() launches

# ============================================================================
# DETERMINE APP DIRECTORY
# ============================================================================

# Get the directory where this app.R file lives
# This works whether you run from project root or app/ directory
app_dir <- if (file.exists("app.R")) {


  # We're already in the app/ directory
 getwd()
} else if (file.exists("app/app.R")) {
  # We're in the project root
  file.path(getwd(), "app")
} else {
  # Fallback: try to find it
  stop("Cannot locate app directory. Run from project root or app/ folder.")
}

# ============================================================================
# SOURCE GLOBAL CONFIGURATION FIRST
# ============================================================================

source(file.path(app_dir, "global.R"))

# ============================================================================
# LOAD APP DATA (after global.R defines load_app_data function)
# ============================================================================

app_data <- load_app_data(app_dir)

# ============================================================================
# SOURCE MODULES (after global.R so colors, app_info are available)
# ============================================================================

source(file.path(app_dir, "modules/mod_executive_brief.R"))
source(file.path(app_dir, "modules/mod_scenario_builder.R"))
source(file.path(app_dir, "modules/mod_analog_explorer.R"))
source(file.path(app_dir, "modules/mod_methods.R"))

# ============================================================================
# SOURCE UTILITY FUNCTIONS (if any)
# ============================================================================

# source(file.path(app_dir, "utils/chart_helpers.R"))
# source(file.path(app_dir, "utils/format_helpers.R"))

# ============================================================================
# SOURCE UI AND SERVER
# ============================================================================

source(file.path(app_dir, "ui.R"))
source(file.path(app_dir, "server.R"))

# ============================================================================
# LAUNCH APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
