# 04_deploy_checks.R
# Pre-deployment verification script
# Run this BEFORE deploying to shinyapps.io

cat("
╔══════════════════════════════════════════════════════════════════════════════╗
║                    Pre-Deployment Verification Checks                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
\n")

# Track pass/fail
checks_passed <- 0
checks_failed <- 0

# Helper function
check <- function(condition, pass_msg, fail_msg) {
  if (condition) {
    cat("✓ PASS:", pass_msg, "\n")
    checks_passed <<- checks_passed + 1
  } else {
    cat("✗ FAIL:", fail_msg, "\n")
    checks_failed <<- checks_failed + 1
  }
}

# ============================================================================
# CHECK 1: No .Rprofile in app directory
# ============================================================================

cat("\n--- Check 1: .Rprofile ---\n")
check(
  !file.exists("app/.Rprofile"),
  "No .Rprofile in app/ directory",
  ".Rprofile found in app/ - THIS WILL BREAK DEPLOYMENT! Delete it."
)

# ============================================================================
# CHECK 2: DESCRIPTION file exists and is valid
# ============================================================================

cat("\n--- Check 2: DESCRIPTION File ---\n")
check(
  file.exists("app/DESCRIPTION"),
  "DESCRIPTION file exists",
  "DESCRIPTION file missing - shinyapps.io won't detect dependencies!"
)

if (file.exists("app/DESCRIPTION")) {
  desc_content <- readLines("app/DESCRIPTION")
  
  # Check for Imports field
  has_imports <- any(grepl("^Imports:", desc_content))
  check(
    has_imports,
    "DESCRIPTION has 'Imports:' field",
    "DESCRIPTION missing 'Imports:' - use 'Imports:', not 'Depends:'"
  )
  
  # Check for key packages
  has_semantic <- any(grepl("shiny.semantic", desc_content))
  check(
    has_semantic,
    "shiny.semantic listed in dependencies",
    "shiny.semantic not found in DESCRIPTION"
  )
  
  # Check for trailing newline
  last_line <- desc_content[length(desc_content)]
  has_newline <- nchar(last_line) > 0
  check(
    has_newline,
    "DESCRIPTION has content on last line (will add newline)",
    "DESCRIPTION may have formatting issues"
  )
}

# ============================================================================
# CHECK 3: No R/ folder (to avoid auto-sourcing issues)
# ============================================================================

cat("\n--- Check 3: Folder Structure ---\n")
check(
  !dir.exists("app/R"),
  "No R/ folder in app/ (using modules/ instead - correct!)",
  "R/ folder exists - files will source BEFORE global.R! Move to modules/"
)

check(
  dir.exists("app/modules"),
  "modules/ folder exists",
  "modules/ folder missing"
)

# ============================================================================
# CHECK 4: No install.packages() in app code
# ============================================================================

cat("\n--- Check 4: No Runtime Installs ---\n")
r_files <- list.files("app/", pattern = "\\.R$", recursive = TRUE, full.names = TRUE)

install_commands <- sapply(r_files, function(f) {
  content <- readLines(f, warn = FALSE)
  any(grepl("install\\.packages|pak::|renv::restore", content))
})

check(
  !any(install_commands),
  "No install commands found in app code",
  paste("Install commands found in:", paste(names(install_commands)[install_commands], collapse = ", "))
)

# ============================================================================
# CHECK 5: .rscignore exists
# ============================================================================

cat("\n--- Check 5: .rscignore ---\n")
check(
  file.exists("app/.rscignore"),
  ".rscignore exists",
  ".rscignore missing - development files may be deployed"
)

if (file.exists("app/.rscignore")) {
  rscignore <- readLines("app/.rscignore", warn = FALSE)
  
  check(
    any(grepl("\\.Rprofile", rscignore)),
    ".Rprofile excluded in .rscignore",
    ".Rprofile not excluded - add it to .rscignore"
  )
  
  check(
    any(grepl("renv/", rscignore)),
    "renv/ excluded in .rscignore",
    "renv/ not excluded - add it to .rscignore"
  )
}

# ============================================================================
# CHECK 6: All modules exist
# ============================================================================

cat("\n--- Check 6: Module Files ---\n")
required_modules <- c(
  "app/modules/mod_executive_brief.R",
  "app/modules/mod_scenario_builder.R",
  "app/modules/mod_analog_explorer.R",
  "app/modules/mod_methods.R"
)

for (mod in required_modules) {
  check(
    file.exists(mod),
    paste("Found:", basename(mod)),
    paste("Missing:", mod)
  )
}

# ============================================================================
# CHECK 7: Core app files exist
# ============================================================================

cat("\n--- Check 7: Core App Files ---\n")
core_files <- c(
  "app/app.R",
  "app/global.R",
  "app/ui_main.R",
  "app/server_main.R",
  "app/DESCRIPTION",
  "app/data/processed/oncology_analogs.rds",
  "app/data/processed/launch_curves.rds",
  "app/data/processed/data_quality.rds"
)

# shinyapps.io runs ui.R/server.R instead of app.R if they exist, so they must not
for (f in c("app/ui.R", "app/server.R")) {
  check(
    !file.exists(f),
    paste0(f, " absent (would bypass app.R on shinyapps.io)"),
    paste0(f, " exists: shinyapps.io would bypass app.R; rename it")
  )
}

for (f in core_files) {
  check(
    file.exists(f),
    paste("Found:", basename(f)),
    paste("Missing:", f)
  )
}

# ============================================================================
# CHECK 8: Verify dependencies can be detected
# ============================================================================

cat("\n--- Check 8: Dependency Detection ---\n")
if (requireNamespace("rsconnect", quietly = TRUE)) {
  tryCatch({
    deps <- rsconnect::appDependencies("app/")
    
    required_pkgs <- c("shiny", "shiny.semantic", "dplyr", "ggplot2", "ggiraph", "reactable")
    detected <- required_pkgs %in% deps$Package
    
    for (i in seq_along(required_pkgs)) {
      check(
        detected[i],
        paste(required_pkgs[i], "detected"),
        paste(required_pkgs[i], "NOT detected - check DESCRIPTION")
      )
    }
  }, error = function(e) {
    cat("⚠ Could not check dependencies:", conditionMessage(e), "\n")
  })
} else {
  cat("⚠ rsconnect not installed - skipping dependency check\n")
}

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                              VERIFICATION SUMMARY                              \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("\n")
cat(sprintf("  ✓ Passed: %d\n", checks_passed))
cat(sprintf("  ✗ Failed: %d\n", checks_failed))
cat("\n")

if (checks_failed == 0) {
  cat("🎉 All checks passed! Ready to deploy.\n\n")
  cat("Deploy with:\n")
  cat("  rsconnect::deployApp('app/', appName = 'launch-curve-forecaster', forceUpdate = TRUE)\n")
} else {
  cat("⚠ Fix the failed checks before deploying.\n")
  cat("Review PROJECT_SETUP.md for guidance.\n")
}

cat("\n")
