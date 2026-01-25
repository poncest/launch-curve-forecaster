# global.R
# Launch Curve Forecaster - Global Configuration
# This file loads BEFORE ui.R and server.R

# ============================================================================
# PACKAGES - Explicit loading (no tidyverse meta-package)
# ============================================================================

library(shiny)
library(shiny.semantic)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(scales)
library(ggplot2)
library(ggiraph)
library(reactable)
library(reactablefmtr)

# ============================================================================
# APP METADATA
# ============================================================================

app_info <- list(
  title = "Oncology Launch Curve Forecaster",
  subtitle = "Decision Support for VP-Level Launch Planning",
  version = "0.1.0",
  author = "Steven Ponce",
  
  # Canonical positioning statement
  positioning = paste(
    "This framework supports VP-level launch decisions by quantifying how",
    "uncertainty in uptake timing and analog selection translates into",
    "revenue risk and investment trade-offs."
  ),
  
  # What this does NOT do (AD-level boundary setting)
  limitations = c(
    "Does not predict whether a specific launch will succeed",
    "Does not recommend specific investment levels",
    "Does not model competitive response timing",
    "Does not estimate NPV or financial returns",
    "Does not replace clinical or regulatory judgment"
  )
)

# ============================================================================
# COLOR PALETTE
# ============================================================================

colors <- list(
  # Primary - Professional blue (pharma-appropriate)
  primary = "#0077B6",
  primary_dark = "#023E8A",
  primary_light = "#90E0EF",
  
  # Secondary - Teal accent

  secondary = "#006B75",
  secondary_light = "#48A9A6",
  
  # Semantic colors
  success = "#107C10",
  warning = "#CA5010",
  danger = "#D13438",
  
  # Scenario colors (for charts)
  scenario_base = "#0077B6",
  scenario_optimistic = "#107C10",
  scenario_conservative = "#CA5010",
  
  # Neutrals
  text_primary = "#323130",
  text_secondary = "#605E5C",
  text_muted = "#A19F9D",
  background = "#FAFAFA",
  card_bg = "#FFFFFF",
  border = "#EDEBE9"
)

# ============================================================================
# CHART THEME
# ============================================================================

theme_launch <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      # Text
      text = element_text(color = colors$text_primary),
      plot.title = element_text(
        face = "bold",
        size = rel(1.2),
        color = colors$primary_dark,
        margin = margin(b = 10)
      ),
      plot.subtitle = element_text(
        color = colors$text_secondary,
        margin = margin(b = 15)
      ),
      plot.caption = element_text(
        color = colors$text_muted,
        size = rel(0.8),
        hjust = 0
      ),
      
      # Axes
      axis.title = element_text(
        color = colors$text_secondary,
        size = rel(0.9)
      ),
      axis.text = element_text(color = colors$text_secondary),
      axis.line = element_line(color = colors$border),
      
      # Grid
      panel.grid.major = element_line(color = colors$border, linewidth = 0.5),
      panel.grid.minor = element_blank(),
      
      # Legend
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = rel(0.9)),
      
      # Background
      plot.background = element_rect(fill = colors$background, color = NA),
      panel.background = element_rect(fill = colors$card_bg, color = NA),
      
      # Margins
      plot.margin = margin(15, 15, 15, 15)
    )
}

# ============================================================================
# DATA LOADING
# ============================================================================

# Load processed data (created by scripts/02_data_preparation.R)
# These files must exist before running the app

load_app_data <- function(app_dir = NULL) {
  
 # Determine the correct data path
 if (!is.null(app_dir)) {
    data_path <- file.path(app_dir, "data/processed/")
 } else if (dir.exists("data/processed")) {
    data_path <- "data/processed/"
  } else if (dir.exists("app/data/processed")) {
    data_path <- "app/data/processed/"
  } else {
    data_path <- "data/processed/"  # Fallback
  }
  
  # Check if data exists
  required_files <- c(
    "oncology_analogs.rds",
    "launch_curves.rds"
  )
  
  missing <- !file.exists(file.path(data_path, required_files))
  
  if (any(missing)) {
    warning(
      "Missing data files: ",
      paste(required_files[missing], collapse = ", "),
      "\nRun scripts/02_data_preparation.R first."
    )
    
    # Return placeholder data for development
    return(list(
      analogs = data.frame(
        product_name = character(),
        company = character(),
        approval_date = as.Date(character()),
        indication = character(),
        line_of_therapy = character()
      ),
      curves = data.frame(
        product_name = character(),
        quarters_since_launch = integer(),
        revenue_millions = numeric()
      ),
      is_placeholder = TRUE
    ))
  }
  
  # Load actual data
  list(
    analogs = readRDS(file.path(data_path, "oncology_analogs.rds")),
    curves = readRDS(file.path(data_path, "launch_curves.rds")),
    is_placeholder = FALSE
  )
}

# NOTE: app_data is loaded in app.R after app_dir is determined
# This allows the path resolution to work correctly
# app_data <- load_app_data()  # Called from app.R instead

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Format currency (inline, not as separate function to avoid scoping issues)
# Use directly in modules: paste0("$", round(value / 1e6, 1), "M")

# Format percentage (inline)
# Use directly in modules: paste0(round(value * 100, 1), "%")

# Safe reactive value extraction
safe_get <- function(x, default = NULL) {
  tryCatch(x, error = function(e) default)
}

# ============================================================================
# SCENARIO DEFINITIONS
# ============================================================================

scenarios <- list(
  base = list(
    name = "Base Case",
    description = "P50 estimate based on median analog performance",
    color = colors$scenario_base
  ),
  optimistic = list(
    name = "Optimistic",
    description = "P75 estimate reflecting favorable analog outcomes",
    color = colors$scenario_optimistic
  ),
  conservative = list(
    name = "Conservative",
    description = "P25 estimate reflecting challenging launch conditions",
    color = colors$scenario_conservative
  )
)

# ============================================================================
# TAB CONFIGURATION
# ============================================================================

tabs <- list(
  executive_brief = list(
    id = "executive_brief",
    title = "Executive Brief",
    icon = "dashboard",
    description = "VP-level summary with key decisions and trade-offs"
  ),
  scenario_builder = list(
    id = "scenario_builder",
    title = "Scenario Builder",
    icon = "sliders horizontal",
    description = "Configure analog selection and assumption parameters"
  ),
  analog_explorer = list(
    id = "analog_explorer",
    title = "Analog Explorer",
    icon = "chart line",
    description = "Examine individual analog launch curves and characteristics"
  ),
  methods = list(
    id = "methods",
    title = "Methods & Data",
    icon = "book",
    description = "Methodology, data sources, and limitations"
  )
)

# ============================================================================
# STARTUP MESSAGE
# ============================================================================

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                     Oncology Launch Curve Forecaster                          \n")
cat("                           Version ", app_info$version, "                      \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("\n")

if (app_data$is_placeholder) {
  cat("⚠ Running with placeholder data. Run data preparation scripts first.\n\n")
} else {
  cat("✓ Data loaded successfully\n")
  cat("  Analogs: ", nrow(app_data$analogs), "\n")
  cat("  Curve observations: ", nrow(app_data$curves), "\n\n")
}
