# 00_setup_packages.R
# One-time package installation for Launch Curve Forecaster
# Run this script ONCE during initial setup
# DO NOT include this in the app/ directory

# ============================================================================
# IMPORTANT: This script is for LOCAL DEVELOPMENT ONLY
# Never deploy install commands to shinyapps.io
# ============================================================================

cat("
╔══════════════════════════════════════════════════════════════════════════════╗
║                    Launch Curve Forecaster - Package Setup                   ║
║                                                                              ║
║  This script installs all required packages for local development.           ║
║  Run once per machine. Do not include in deployed app.                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
")

# Install pak if not available
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

# Define required packages
packages <- c(
  # Core Shiny

"shiny",
"shiny.semantic",
"bslib",
  
  # Data manipulation
"dplyr",
"tidyr",
"purrr",
"stringr",
"lubridate",
"scales",
  
  # Visualization
"ggplot2",
"ggiraph",
"reactable",
"reactablefmtr",
"plotly",
  
  # Data import
"readr",
"readxl",
"jsonlite",
  
  # Deployment
"rsconnect"
)

cat("\nInstalling packages...\n")
cat("This may take a few minutes on first run.\n\n")

# Install all packages
pak::pkg_install(packages)

# Verify installation
cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                           Installation Verification                            \n
")
cat("═══════════════════════════════════════════════════════════════════════════════\n")

installed <- sapply(packages, requireNamespace, quietly = TRUE)

if (all(installed)) {
  cat("\n✓ All packages installed successfully!\n\n")
} else {
  cat("\n✗ Some packages failed to install:\n")
  cat(paste("  -", packages[!installed], collapse = "\n"), "\n")
  cat("\nTry installing failed packages individually.\n\n")
}

# Print versions for key packages
cat("Key package versions:\n")
cat(sprintf("  shiny:          %s\n", packageVersion("shiny")))
cat(sprintf("  shiny.semantic: %s\n", packageVersion("shiny.semantic")))
cat(sprintf("  ggplot2:        %s\n", packageVersion("ggplot2")))
cat(sprintf("  ggiraph:        %s\n", packageVersion("ggiraph")))
cat(sprintf("  reactable:      %s\n", packageVersion("reactable")))

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("Setup complete. You can now run the app with: shiny::runApp('app/')
")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
