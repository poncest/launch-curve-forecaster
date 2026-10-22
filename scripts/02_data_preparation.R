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

# Check reported coverage by product
coverage <- revenue |>
  filter(!is.na(revenue_usd_millions)) |>
  group_by(product_name) |>
  summarise(
    n_values = n(),
    first = min(as.Date(period_start)),
    last = max(as.Date(period_end)),
    .groups = "drop"
  )

cat("\nReported coverage by product:\n")
print(coverage, n = Inf)

# ============================================================================
# LAUNCH YEARS FROM THE EXACT APPROVAL DATE
# ============================================================================
# Companies report sales by fiscal year (calendar year for most, April-March
# for Eisai and Takeda). Launch Year k is the 12 months starting k-1 years
# after first FDA approval. Each fiscal value is spread evenly over the days
# it covers (from the approval date, for the launch year) and apportioned to
# the launch years it overlaps. The even spread is an approximation: within a
# fast-growing year, sales are back-loaded, so early launch years are
# slightly overstated and later ones understated.
#
# Missing values: a launch year that overlaps an unreported period is left
# missing, except when the unreported period is the approval-year one and
# the overlap is 31 days or less (sales for those days are taken as zero).

n_launch_years <- 5
status_rank <- c(verified = 1, assumed_zero = 2, estimate = 3, unverified = 4)

add_months <- function(d, m) {
  as.Date(sapply(m, function(k) seq(d, by = paste(k, "months"), length.out = 2)[2]),
          origin = "1970-01-01")
}

launch_years_for <- function(prod, rev, approval) {
  rev <- rev |>
    mutate(
      start = pmax(as.Date(period_start), approval),
      end = as.Date(period_end) + 1,          # exclusive
      days = as.numeric(end - start)
    ) |>
    filter(days > 0)
  bounds <- add_months(approval, 12 * (0:n_launch_years))
  out <- vector("list", n_launch_years)
  for (k in seq_len(n_launch_years)) {
    a <- bounds[k]; b <- bounds[k + 1]
    ov <- pmax(0, as.numeric(pmin(rev$end, b) - pmax(rev$start, a)))
    use <- ov > 0
    if (!any(use) || max(rev$end) < b) {
      out[[k]] <- data.frame(launch_year = k, revenue = NA_real_, status = "not_covered",
                             fiscal_years = NA_character_, approx_zero_days = 0)
      next
    }
    r <- rev[use, ]; o <- ov[use]
    gap <- is.na(r$revenue_usd_millions)
    zero_ok <- gap & as.Date(r$period_start) <= approval & as.Date(r$period_end) >= approval & o <= 31
    if (any(gap & !zero_ok)) {
      val <- NA_real_; st <- "not_reported"
    } else {
      val <- sum(ifelse(gap, 0, r$revenue_usd_millions * o / r$days))
      sts <- r$verification[!gap]
      st <- names(status_rank)[max(match(sts, names(status_rank)), na.rm = TRUE)]
    }
    out[[k]] <- data.frame(launch_year = k, revenue = val, status = st,
                           fiscal_years = paste(unique(r$fiscal_year), collapse = "+"),
                           approx_zero_days = sum(o[zero_ok]))
  }
  bind_rows(out) |> mutate(product_name = prod)
}

approvals <- setNames(as.Date(metadata$fda_approval_date), metadata$product_name)
launch <- bind_rows(lapply(names(approvals), function(p) {
  launch_years_for(p, revenue[revenue$product_name == p, ], approvals[[p]])
}))

cat("\nLaunch-year revenue ($M):\n")
launch |>
  mutate(revenue = round(revenue)) |>
  select(product_name, launch_year, revenue) |>
  pivot_wider(names_from = launch_year, values_from = revenue, names_prefix = "Y") |>
  print(n = Inf)

# ============================================================================
# PROCESS ANALOG DATA
# ============================================================================

cat("\nProcessing analog data...\n")

product_metrics <- launch |>
  filter(!is.na(revenue)) |>
  group_by(product_name) |>
  summarise(
    # Year-5 revenue (column name kept from the earlier "peak" label)
    peak_revenue_millions = revenue[launch_year == n_launch_years][1],
    years_to_peak = launch_year[which.max(revenue)],
    .groups = "drop"
  )

analogs <- metadata |>
  left_join(product_metrics, by = "product_name") |>
  mutate(approval_date = as.Date(fda_approval_date)) |>  # first FDA approval
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

curves <- launch |>
  filter(!is.na(revenue)) |>
  left_join(metadata |> select(product_name, company, tumor_class), by = "product_name") |>
  transmute(
    product_name,
    company,
    years_since_launch = launch_year,
    revenue_millions = round(revenue, 1),
    tumor_class,
    fiscal_years,
    verification = status
  ) |>
  arrange(product_name, years_since_launch)

# Launch years that could not be computed (listed in the Methods tab)
curve_gaps <- launch |>
  filter(is.na(revenue)) |>
  select(product_name, years_since_launch = launch_year, reason = status)

cat(sprintf("  ✓ Processed %d curve observations (%d launch years missing)\n",
            nrow(curves), nrow(curve_gaps)))

# Reported values behind the curves, for the data-status note
raw_status <- revenue |>
  count(verification, name = "n")
raw_flags <- revenue |>
  filter(verification %in% c("estimate", "unverified")) |>
  select(product_name, fiscal_year, verification)

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

# Data-quality facts shown in the Methods tab
attr_info <- list(curve_gaps = curve_gaps, raw_status = raw_status, raw_flags = raw_flags)
saveRDS(attr_info, "data/processed/data_quality.rds")

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
file.copy("data/processed/data_quality.rds", "app/data/processed/data_quality.rds", overwrite = TRUE)
# CSV fallbacks read by app/global.R when the RDS files are absent; keep in sync
write.csv(curves[, c("product_name", "fiscal_years", "years_since_launch", "revenue_millions",
                     "tumor_class", "verification")],
          "app/data/processed/launch_curves.csv", row.names = FALSE)
write.csv(analogs[, c("product_name", "company", "approval_date", "tumor_class", "indication",
                      "peak_revenue_millions")],
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
cat(sprintf("Launch years:       1 to %d\n", max(curves$years_since_launch)))
cat("\n")
cat("Next step: Run the app\n")
cat("  shiny::runApp('app/')\n")
cat("\n")
