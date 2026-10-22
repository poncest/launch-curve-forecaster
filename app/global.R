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

# ============================================================================
# APP METADATA
# ============================================================================

app_info <- list(
  title = "Oncology Launch Curve Forecaster",
  subtitle = "Decision Support for Commercial Launch Planning",
  version = "2.0.0",
  author = "Steven Ponce",
  
  # Canonical positioning statement
  positioning = paste(
    "This framework supports commercial launch decisions by quantifying how",
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

# Deep navy theme - differentiates from Microsoft (bright blue) and 
# Clinical Trial Forecaster (standard blue) while remaining pharma-appropriate

colors <- list(
  # Primary - Deep navy (professional, distinct)
  primary = "#1D3557",
  primary_dark = "#0D1B2A",
  primary_light = "#457B9D",
  
  # Secondary - Steel blue accent
  secondary = "#2A6F97",
  secondary_light = "#61A5C2",
  
  # Semantic colors
  success = "#2D6A4F",
  warning = "#E76F51",
  danger = "#9B2226",
  
  
  # Scenario colors (for charts)
  scenario_base = "#1D3557",
  scenario_optimistic = "#2D6A4F",
  scenario_conservative = "#E76F51",
  
  # Neutrals
  text_primary = "#1B1B1B",
  text_secondary = "#4A4A4A",
  text_muted = "#8D99AE",
  background = "#F8F9FA",
  card_bg = "#FFFFFF",
  border = "#DEE2E6"
)

# ============================================================================
# CHART THEME
# ============================================================================

theme_launch <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      # Text
      text = ggplot2::element_text(color = colors$text_primary),
      plot.title = ggplot2::element_text(
        face = "bold",
        size = ggplot2::rel(1.2),
        color = colors$primary_dark,
        margin = ggplot2::margin(b = 10)
      ),
      plot.subtitle = ggplot2::element_text(
        color = colors$text_secondary,
        margin = ggplot2::margin(b = 15)
      ),
      plot.caption = ggplot2::element_text(
        color = colors$text_muted,
        size = ggplot2::rel(0.8),
        hjust = 0
      ),
      
      # Axes
      axis.title = ggplot2::element_text(
        color = colors$text_secondary,
        size = ggplot2::rel(0.9)
      ),
      axis.text = ggplot2::element_text(color = colors$text_secondary),
      axis.line = ggplot2::element_line(color = colors$border),
      
      # Grid
      panel.grid.major = ggplot2::element_line(color = colors$border, linewidth = 0.5),
      panel.grid.minor = ggplot2::element_blank(),
      
      # Legend
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(0.9)),
      
      # Background
      plot.background = ggplot2::element_rect(fill = colors$card_bg, color = NA),
      panel.background = ggplot2::element_rect(fill = colors$card_bg, color = NA),
      
      # Margins
      plot.margin = ggplot2::margin(15, 15, 15, 15)
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
    data_path <- "data/processed/"
  }
  
  # Check if data exists (RDS preferred, CSV as fallback)
  analogs_file <- if (file.exists(file.path(data_path, "oncology_analogs.rds"))) {
    file.path(data_path, "oncology_analogs.rds")
  } else if (file.exists(file.path(data_path, "oncology_analogs.csv"))) {
    file.path(data_path, "oncology_analogs.csv")
  } else {
    NULL
  }
  
  curves_file <- if (file.exists(file.path(data_path, "launch_curves.rds"))) {
    file.path(data_path, "launch_curves.rds")
  } else if (file.exists(file.path(data_path, "launch_curves.csv"))) {
    file.path(data_path, "launch_curves.csv")
  } else {
    NULL
  }
  
  if (is.null(analogs_file) || is.null(curves_file)) {
    warning(
      "Missing data files in: ", data_path,
      "\nRun scripts/02_data_preparation.R first."
    )
    
    # Return placeholder data for development
    return(list(
      analogs = data.frame(
        product_name = character(),
        company = character(),
        approval_date = as.Date(character()),
        indication = character(),
        tumor_class = character()
      ),
      curves = data.frame(
        product_name = character(),
        years_since_launch = integer(),
        revenue_millions = numeric(),
        tumor_class = character()
      ),
      is_placeholder = TRUE
    ))
  }
  
  # Load actual data (handle both RDS and CSV)
  load_file <- function(filepath) {
    if (grepl("\\.rds$", filepath, ignore.case = TRUE)) {
      readRDS(filepath)
    } else {
      read.csv(filepath, stringsAsFactors = FALSE)
    }
  }
  
  # Load and deduplicate
  analogs_data <- load_file(analogs_file) |>
    dplyr::distinct(product_name, .keep_all = TRUE)
  
  curves_data <- load_file(curves_file)
  
  dq_file <- file.path(data_path, "data_quality.rds")
  list(
    analogs = analogs_data,
    curves = curves_data,
    data_quality = if (file.exists(dq_file)) readRDS(dq_file) else NULL,
    is_placeholder = FALSE
  )
}

# NOTE: app_data is loaded in app.R after app_dir is determined
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
# LOAD APP DATA
# ============================================================================

app_data <- load_app_data()

# Launch shapes: each analog's revenue as a share of its own Year-5 revenue,
# so curves of very different sizes can be compared and scaled to a new product
analog_shapes <- function(curves) {
  y5 <- curves[curves$years_since_launch == 5, c("product_name", "revenue_millions")]
  names(y5)[2] <- "year5"
  # Analogs with no Year-5 sales (withdrawn, e.g. Lartruvo) have no defined shape
  y5 <- y5[!is.na(y5$year5) & y5$year5 > 0, ]
  out <- merge(curves, y5, by = "product_name")
  out$shape <- out$revenue_millions / out$year5
  out[order(out$product_name, out$years_since_launch), ]
}

# Expected Year-5 revenue entered for the user's own product (NA = not given)
valid_expected <- function(x) !is.null(x) && length(x) == 1 && !is.na(x) && x > 0

# $M below $1B, $B (one decimal) above, e.g. fmt_money(2150) -> "$2.1B"
fmt_money <- function(x) {
  if (is.na(x)) return("--")
  if (abs(x) >= 1000) sprintf("$%.1fB", x / 1000) else paste0("$", format(round(x), big.mark = ","), "M")
}

# ----------------------------------------------------------------------------
# Data notes computed from the data (Methods tab)
# ----------------------------------------------------------------------------
local({
  cv <- app_data$curves
  an <- app_data$analogs
  dq <- app_data$data_quality

  parts <- character()
  if (!is.null(dq)) {
    st <- setNames(dq$raw_status$n, dq$raw_status$verification)
    n_reported <- sum(st[setdiff(names(st), c("not_reported", "not_located", "assumed_zero"))])
    parts <- c(parts, paste0(st[["verified"]], " of ", n_reported,
                             " reported values verified against the company's own report"))
    fl <- dq$raw_flags
    if (!is.null(fl) && any(fl$verification == "estimate"))
      parts <- c(parts, paste0(paste(fl$product_name[fl$verification == "estimate"],
                                     fl$fiscal_year[fl$verification == "estimate"], collapse = ", "),
                               " estimated (part of a quarter is not covered by any filing)"))
    if (!is.null(fl) && any(fl$verification == "unverified"))
      parts <- c(parts, paste0(paste(fl$product_name[fl$verification == "unverified"],
                                     fl$fiscal_year[fl$verification == "unverified"], collapse = ", "),
                               " not yet traced to a primary source"))
    if (any(names(st) %in% c("not_reported", "not_located")))
      parts <- c(parts, paste0(sum(st[names(st) %in% c("not_reported", "not_located")]),
                               " fiscal-year values not reported separately or not found"))
    if (nrow(dq$curve_gaps) > 0) {
      g <- dq$curve_gaps
      g <- tapply(g$years_since_launch, g$product_name, function(y) paste(y, collapse = " and "))
      parts <- c(parts, paste0("launch years missing as a result: ",
                               paste0(names(g), " (Year ", g, ")", collapse = ", ")))
    }
  }
  if ("verification" %in% names(cv) && any(cv$verification == "assumed_zero"))
    parts <- c(parts, paste0("sales after withdrawal taken as zero for ",
                             paste(unique(cv$product_name[cv$verification == "assumed_zero"]), collapse = ", ")))
  data_status_note <<- paste(parts, collapse = "; ")

  alignment_note <<- paste0(
    "Launch Year 1 is the 12 months after each drug's first FDA approval date, Year 2 the next 12 months, ",
    "and so on to Year 5. Companies report sales by fiscal year (April to March for Eisai and Takeda), so each ",
    "fiscal-year total is spread evenly over the days it covers and split across the launch years it overlaps. ",
    "This is an approximation: sales usually grow within a year, so the split slightly overstates early launch ",
    "years and understates later ones. It replaces calendar-year alignment, in which 'Year 0' ranged from ",
    "10 days to 11 months on market."
  )
})


# ============================================================================
# STARTUP MESSAGE (only in interactive sessions)
# ============================================================================

if (interactive()) {
  cat("\n")
  cat("═══════════════════════════════════════════════════════════════════════════════\n")
  cat("                     Oncology Launch Curve Forecaster                          \n")
  cat("                           Version ", app_info$version, "                      \n")
  cat("═══════════════════════════════════════════════════════════════════════════════\n")
  cat("\n")
}