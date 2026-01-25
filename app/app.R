# app.R
# Launch Curve Forecaster - Application Entry Point
#
# NOTE: Run this app using run_app.R from project root, or:
#   setwd("app")
#   shiny::runApp()

# Source global configuration
source("global.R")

# Load app data
app_data <- load_app_data(getwd())

# Source modules
source("modules/mod_executive_brief.R")
source("modules/mod_scenario_builder.R")
source("modules/mod_analog_explorer.R")
source("modules/mod_methods.R")

# Source UI and Server
source("ui.R")
source("server.R")

# Launch
shinyApp(ui = ui, server = server)