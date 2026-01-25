# server.R
# Launch Curve Forecaster - Main Server Logic

server <- function(input, output, session) {
  
  # ==========================================================================
  # SHARED REACTIVE VALUES
  # ==========================================================================
  
  # Store user selections that need to be shared across modules
  shared <- reactiveValues(
    # Selected analogs (from scenario builder)
    selected_analogs = NULL,
    
    # Current scenario configuration
    scenario_config = list(
      delay_months = 0,
      market_access_scenario = "base",
      competitive_intensity = "moderate"
    ),
    
    # Calculated outputs (from scenario builder)
    scenario_outputs = NULL
  )
  
  # ==========================================================================
  # MODULE SERVERS
  # ==========================================================================
  
  # Executive Brief module
  mod_executive_brief_server(
    id = "executive_brief",
    app_data = app_data,
    shared = shared
  )
  
  # Scenario Builder module
  mod_scenario_builder_server(
    id = "scenario_builder",
    app_data = app_data,
    shared = shared
  )
  
  # Analog Explorer module
  mod_analog_explorer_server(
    id = "analog_explorer",
    app_data = app_data,
    shared = shared
  )
  
  # Methods module
  mod_methods_server(
    id = "methods",
    app_data = app_data
  )
  
  # ==========================================================================
  # SESSION CLEANUP
  # ==========================================================================
  
  session$onSessionEnded(function() {
    # Cleanup if needed
  })
}
