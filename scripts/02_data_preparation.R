# 02_data_preparation.R
# Process extracted SEC revenue data into app-ready format
#
# Prerequisites:
# - Completed data/raw/sec_product_revenue.csv (from manual extraction)
# - data/raw/analog_metadata.csv (already created)
#
# Outputs:
# - data/processed/oncology_analogs.rds
# - data/processed/launch_curves.rds

cat("
╔══════════════════════════════════════════════════════════════════════════════╗
║              Launch Curve Forecaster - Data Preparation                      ║
╚══════════════════════════════════════════════════════════════════════════════╝
\n")

# ============================================================================
# LOAD PACKAGES
# ============================================================================

library(readr)
library(dplyr)
library(tidyr)

# ============================================================================
# CONFIGURATION
# ============================================================================

# File paths
paths <- list(
  metadata_raw = "data/raw/analog_metadata.csv",
  revenue_raw = "data/raw/sec_product_revenue.csv",
  analogs_out = "data/processed/oncology_analogs.rds",
  curves_out = "data/processed/launch_curves.rds"
)

# Ensure output directory exists
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# ============================================================================
# LOAD RAW DATA
# ============================================================================

cat("Loading raw data...\n")

# Load metadata
if (!file.exists(paths$metadata_raw)) {
  stop("Metadata file not found: ", paths$metadata_raw)
}
metadata <- read_csv(paths$metadata_raw, show_col_types = FALSE)
cat(sprintf("  ✓ Metadata: %d products\n", nrow(metadata)))

# Load revenue data
if (!file.exists(paths$revenue_raw)) {
  cat("\n")
  cat("  ⚠ Revenue data not found: ", paths$revenue_raw, "\n")
  cat("  \n")
  cat("  To proceed, you need to:\n")
  cat("  1. Complete manual SEC revenue extraction\n")
  cat("  2. Save as: data/raw/sec_product_revenue.csv\n")
  cat("  3. Re-run this script\n")
  cat("  \n")
  cat("  See scripts/01_data_collection.R for guidance.\n")
  cat("\n")
  
  # Create placeholder data for development
  cat("Creating placeholder data for development...\n")
  
  # Placeholder analogs
  analogs_placeholder <- metadata |>
    mutate(
      approval_date = as.Date(paste0(fda_approval_year, "-09-01")),
      peak_revenue_millions = NA_real_,
      years_to_peak = NA_integer_
    ) |>
    select(
      product_name,
      company,
      approval_date,
      tumor_class,
      indication = indication_primary,
      moa_class,
      sec_filing_type,
      notes
    )
  
  # Placeholder curves (empty)
  curves_placeholder <- data.frame(
    product_name = character(),
    fiscal_year = integer(),
    years_since_launch = integer(),
    revenue_millions = numeric(),
    tumor_class = character()
  )
  
  # Save placeholders
  saveRDS(analogs_placeholder, paths$analogs_out)
  saveRDS(curves_placeholder, paths$curves_out)
  
  cat("  ✓ Placeholder data saved\n")
  cat("\n")
  cat("App will run with placeholder data.\n")
  cat("Complete SEC extraction to see real launch curves.\n")
  
  stop("Revenue data required. See instructions above.")
}

revenue <- read_csv(paths$revenue_raw, show_col_types = FALSE)
cat(sprintf("  ✓ Revenue: %d observations\n", nrow(revenue)))

# ============================================================================
# VALIDATE DATA
# ============================================================================

cat("\nValidating data...\n")

# Check all products in metadata have revenue data
products_metadata <- unique(metadata$product_name)
products_revenue <- unique(revenue$product_name)

missing_products <- setdiff(products_metadata, products_revenue)
if (length(missing_products) > 0) {
  warning("Products in metadata without revenue data: ", 
          paste(missing_products, collapse = ", "))
}

# Check for missing revenue values
missing_revenue <- revenue |>
  filter(is.na(revenue_usd_millions)) |>
  nrow()

if (missing_revenue > 0) {
  warning(sprintf("%d rows with missing revenue values", missing_revenue))
}

# Check for complete year coverage
coverage <- revenue |>
  filter(!is.na(revenue_usd_millions)) |>
  group_by(product_name) |>
  summarise(
    n_years = n(),
    years = paste(sort(unique(years_since_launch)), collapse = ","),
    .groups = "drop"
  )

cat("\nYear coverage by product:\n")
print(coverage)

# ============================================================================
# PROCESS ANALOG DATA
# ============================================================================

cat("\nProcessing analog data...\n")

# Calculate peak revenue and time to peak for each product
product_metrics <- revenue |>
  filter(!is.na(revenue_usd_millions)) |>
  group_by(product_name) |>
  summarise(
    peak_revenue_millions = max(revenue_usd_millions, na.rm = TRUE),
    year_of_peak = fiscal_year[which.max(revenue_usd_millions)],
    .groups = "drop"
  )

# Join with metadata
analogs <- metadata |>
  left_join(product_metrics, by = "product_name") |>
  mutate(
    approval_date = as.Date(fda_approval_date),  # first FDA approval
    years_to_peak = year_of_peak - fda_approval_year
  ) |>
  select(
    product_name,
    company,
    approval_date,
    fda_approval_year,
    tumor_class,
    indication = indication_primary,
    moa_class,
    peak_revenue_millions,
    years_to_peak,
    sec_filing_type,
    notes
  )

cat(sprintf("  ✓ Processed %d analogs\n", nrow(analogs)))

# ============================================================================
# PROCESS LAUNCH CURVES
# ============================================================================

cat("\nProcessing launch curves...\n")

# Join revenue with tumor class from metadata
curves <- revenue |>
  filter(!is.na(revenue_usd_millions)) |>
  left_join(
    metadata |> select(product_name, tumor_class),
    by = "product_name"
  ) |>
  select(
    product_name,
    company,
    fiscal_year,
    years_since_launch,
    revenue_millions = revenue_usd_millions,
    geography,
    tumor_class,
    source_filing,
    verification,
    notes
  ) |>
  arrange(product_name, years_since_launch)

cat(sprintf("  ✓ Processed %d curve observations\n", nrow(curves)))

# ============================================================================
# CALCULATE SUMMARY STATISTICS
# ============================================================================

cat("\nCalculating summary statistics...\n")

# By tumor class
tumor_summary <- curves |>
  group_by(tumor_class, years_since_launch) |>
  summarise(
    n_products = n_distinct(product_name),
    revenue_p25 = quantile(revenue_millions, 0.25, na.rm = TRUE),
    revenue_p50 = median(revenue_millions, na.rm = TRUE),
    revenue_p75 = quantile(revenue_millions, 0.75, na.rm = TRUE),
    revenue_mean = mean(revenue_millions, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nRevenue by tumor class and year (P50):\n")
tumor_summary |>
  select(tumor_class, years_since_launch, revenue_p50, n_products) |>
  pivot_wider(
    names_from = years_since_launch,
    values_from = c(revenue_p50, n_products),
    names_sep = "_Y"
  ) |>
  print()

# Overall percentiles
overall_summary <- curves |>
  group_by(years_since_launch) |>
  summarise(
    n_products = n_distinct(product_name),
    revenue_p25 = quantile(revenue_millions, 0.25, na.rm = TRUE),
    revenue_p50 = median(revenue_millions, na.rm = TRUE),
    revenue_p75 = quantile(revenue_millions, 0.75, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nOverall percentiles by year since launch:\n")
print(overall_summary)

# ============================================================================
# SAVE PROCESSED DATA
# ============================================================================

cat("\nSaving processed data...\n")

saveRDS(analogs, paths$analogs_out)
cat(sprintf("  ✓ Saved: %s\n", paths$analogs_out))

saveRDS(curves, paths$curves_out)
cat(sprintf("  ✓ Saved: %s\n", paths$curves_out))

# ============================================================================
# COPY TO APP DIRECTORY
# ============================================================================

cat("\nCopying to app directory...\n")

# Ensure app data directory exists
if (!dir.exists("app/data/processed")) {
  dir.create("app/data/processed", recursive = TRUE)
}

file.copy(paths$analogs_out, "app/data/processed/oncology_analogs.rds", overwrite = TRUE)
file.copy(paths$curves_out, "app/data/processed/launch_curves.rds", overwrite = TRUE)
# CSV fallbacks read by app/global.R when the RDS files are absent; keep in sync
write.csv(curves[, c("product_name", "years_since_launch", "revenue_millions", "tumor_class")],
          "app/data/processed/launch_curves.csv", row.names = FALSE)
write.csv(analogs[, intersect(names(analogs), names(read.csv("app/data/processed/oncology_analogs.csv", nrows = 1)))],
          "app/data/processed/oncology_analogs.csv", row.names = FALSE)

cat("  ✓ Copied to app/data/processed/\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                          Data Preparation Complete                             \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("\n")
cat(sprintf("Analogs:           %d products\n", nrow(analogs)))
cat(sprintf("  - Solid tumor:   %d\n", sum(analogs$tumor_class == "Solid")))
cat(sprintf("  - Hematologic:   %d\n", sum(analogs$tumor_class == "Heme")))
cat(sprintf("Curve observations: %d\n", nrow(curves)))
cat(sprintf("Years covered:      T=0 to T=%d\n", max(curves$years_since_launch)))
cat("\n")
cat("Next step: Run the app\n")
cat("  shiny::runApp('app/')\n")
cat("\n")
