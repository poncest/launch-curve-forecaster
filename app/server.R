# server.R
# Launch Curve Forecaster - Main Server Logic

server <- function(input, output, session) {
  
  # ==========================================================================
  # SHARED REACTIVE VALUES
  # ==========================================================================
  
  # Initialize selected_analogs with all products (never starts as NULL)
  initial_analogs <- if (!app_data$is_placeholder) {
    app_data$analogs$product_name
  } else {
    character(0)
  }
  
  # Store user selections that need to be shared across modules
  shared <- reactiveValues(
    # Selected analogs (from scenario builder) - initialized with all products
    selected_analogs = initial_analogs,
    
    # Delay in quarters (default to 2 = 6 months)
    delay_quarters = 2,
    
    # Current scenario configuration
    scenario_config = list(
      delay_months = 0,
      market_access_scenario = "base",
      competitive_intensity = "moderate"
    ),
    
    # Calculated outputs (from scenario builder)
    scenario_outputs = NULL,
    
    # Startup trigger (set by JavaScript after page load)
    startup_complete = FALSE
  )
  
  # React to JavaScript startup trigger
  observeEvent(input$startup_trigger, {
    shared$startup_complete <- TRUE
  }, ignoreNULL = TRUE, once = TRUE)
  
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