# 01_data_collection.R
# SEC Revenue Data Collection Guide
# 
# This script provides:
# 1. Direct links to SEC EDGAR filings
# 2. Guidance on where to find product revenue
# 3. Template loading and validation
#
# IMPORTANT: Revenue data requires MANUAL extraction from SEC filings.
# This is intentional - it ensures data quality and creates audit trail.

cat("
╔══════════════════════════════════════════════════════════════════════════════╗
║               Launch Curve Forecaster - Data Collection Guide                ║
║                                                                              ║
║  This script guides manual extraction of product revenue from SEC filings.   ║
║  Estimated time: 3-4 hours for all 10 products × 6 years each.              ║
╚══════════════════════════════════════════════════════════════════════════════╝
\n")

# ============================================================================
# LOAD REQUIRED PACKAGES
# ============================================================================

library(readr)
library(dplyr)

# ============================================================================
# SEC EDGAR FILING LINKS
# ============================================================================

# Direct links to company SEC filing pages
sec_links <- list(
  
  # US Companies (10-K filers)
  Merck = list(
    company = "Merck",
    products = "Keytruda",
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000310158&type=10-K",
    ticker = "MRK",
    notes = "Search for 'KEYTRUDA' in Item 7 MD&A or Product Revenue tables"
  ),
  
  BMS = list(
    company = "Bristol-Myers Squibb",
    products = "Opdivo",
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000014272&type=10-K",
    ticker = "BMY",
    notes = "Search for 'OPDIVO' in Product Revenue section"
  ),
  
  Pfizer = list(
    company = "Pfizer",
    products = "Ibrance",
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000078003&type=10-K",
    ticker = "PFE",
    notes = "Search for 'IBRANCE' in Biopharmaceutical segment revenue"
  ),
  
  AbbVie = list(
    company = "AbbVie",
    products = c("Imbruvica", "Venclexta"),
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0001551152&type=10-K",
    ticker = "ABBV",
    notes = "Imbruvica: AbbVie reports their share (collaboration with J&J). Venclexta: collaboration with Roche"
  ),
  
  JNJ = list(
    company = "Johnson & Johnson",
    products = "Darzalex",
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000200406&type=10-K",
    ticker = "JNJ",
    notes = "Search for 'DARZALEX' in Pharmaceutical segment"
  ),
  
  # Foreign Companies (20-F filers)
  AstraZeneca = list(
    company = "AstraZeneca",
    products = c("Tagrisso", "Lynparza", "Calquence"),
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000901832&type=20-F",
    ticker = "AZN",
    notes = "20-F annual report. Product revenues in Operating Review section. Note: reported in USD"
  ),
  
  Roche = list(
    company = "Roche",
    products = "Tecentriq",
    sec_page = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0001140625&type=20-F",
    ticker = "RHHBY",
    notes = "20-F annual report. May need to convert from CHF to USD if not provided"
  )
)

# Print SEC links
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                              SEC EDGAR Filing Links                            \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n\n")

for (name in names(sec_links)) {
  info <- sec_links[[name]]
  cat(sprintf("【 %s 】\n", info$company))
  cat(sprintf("   Products: %s\n", paste(info$products, collapse = ", ")))
  cat(sprintf("   SEC Page: %s\n", info$sec_page))
  cat(sprintf("   Notes: %s\n\n", info$notes))
}

# ============================================================================
# EXTRACTION GUIDANCE
# ============================================================================

cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                            Extraction Guidance                                 \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n\n")

cat("
WHERE TO FIND PRODUCT REVENUE IN 10-K/20-F:

1. **Item 7: Management's Discussion and Analysis (MD&A)**
   - Usually has product-level revenue tables
   - Look for 'Product Revenues' or 'Net Revenues by Product'

2. **Notes to Financial Statements**
   - Note on Revenue Recognition
   - Note on Segment Information

3. **Segment Reporting**
   - Pharmaceutical / Biopharmaceutical segment
   - May break down by therapeutic area

WHAT TO EXTRACT:

- Product name (standardized)
- Fiscal year
- Revenue in USD millions
- Geography: 'WW' (worldwide) preferred, 'US' if WW unavailable
- Note any caveats (partial year, combination revenue, etc.)

COMMON ISSUES:

- **Partial year revenue**: Launch year may only have 3-6 months of sales
- **Combined products**: Some filings combine similar products
- **Currency conversion**: Foreign filers may report in local currency
- **Collaboration splits**: Imbruvica, Venclexta have revenue sharing

QUALITY CHECKS:

- Revenue should generally increase year-over-year for first 3-4 years
- Large products (Keytruda, Opdivo) should reach $5B+ by year 5
- Mid-size products should reach $1-3B by year 5
- If numbers look wrong, double-check the filing year
\n")

# ============================================================================
# LOAD AND DISPLAY TEMPLATE
# ============================================================================

cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                            Revenue Data Template                               \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n\n")

template_path <- "data/raw/sec_revenue_template.csv"

if (file.exists(template_path)) {
  template <- read_csv(template_path, show_col_types = FALSE)
  
  cat("Template loaded successfully.\n")
  cat(sprintf("- Total rows to fill: %d\n", nrow(template)))
  cat(sprintf("- Products: %d\n", n_distinct(template$product_name)))
  cat(sprintf("- Years per product: ~%d\n\n", nrow(template) / n_distinct(template$product_name)))
  
  # Show structure
  cat("Template columns:\n")
  cat(paste(" -", names(template), collapse = "\n"), "\n\n")
  
  # Show first few rows
  cat("First 6 rows:\n")
  print(head(template))
  
} else {
  cat("⚠ Template not found at:", template_path, "\n")
  cat("  Run this script from the project root directory.\n")
}

# ============================================================================
# EXTRACTION WORKFLOW
# ============================================================================

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("                          Recommended Workflow                                  \n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")

cat("
STEP 1: Open the template
  - File: data/raw/sec_revenue_template.csv
  - Open in Excel or Google Sheets for easier editing

STEP 2: Extract one company at a time
  - Start with Merck (Keytruda) - clearest disclosure
  - Open SEC filing for each year
  - Fill in revenue_usd_millions column
  - Add extraction_date and any notes

STEP 3: Quality check as you go
  - Revenue should trend upward in early years
  - Cross-check against press releases if unsure
  - Note any anomalies in the notes column

STEP 4: Save completed data
  - Save as: data/raw/sec_product_revenue.csv
  - Keep the template as backup

STEP 5: Run data preparation script
  - source('scripts/02_data_preparation.R')
  - This will validate and process the data

ESTIMATED TIME:
  - ~20-30 minutes per company
  - ~3-4 hours total for all 10 products
  - This is a one-time investment with high ROI
\n")

# ============================================================================
# VALIDATION FUNCTION (for after extraction)
# ============================================================================

validate_revenue_data <- function(data_path = "data/raw/sec_product_revenue.csv") {
  
  cat("\nValidating revenue data...\n\n")
  
  if (!file.exists(data_path)) {
    cat("⚠ Data file not found:", data_path, "\n")
    return(invisible(NULL))
  }
  
  data <- read_csv(data_path, show_col_types = FALSE)
  
  # Check for missing revenue
  missing_revenue <- data |>
    filter(is.na(revenue_usd_millions)) |>
    nrow()
  
  if (missing_revenue > 0) {
    cat(sprintf("⚠ Missing revenue values: %d rows\n", missing_revenue))
  } else {
    cat("✓ All revenue values populated\n")
  }
  
  # Check for complete coverage
  products <- unique(data$product_name)
  cat(sprintf("✓ Products found: %d\n", length(products)))
  
  # Check year coverage per product
  coverage <- data |>
    filter(!is.na(revenue_usd_millions)) |>
    group_by(product_name) |>
    summarise(
      years = n(),
      min_year = min(fiscal_year),
      max_year = max(fiscal_year),
      .groups = "drop"
    )
  
  cat("\nCoverage by product:\n")
  print(coverage)
  
  # Check for suspicious values
  suspicious <- data |>
    filter(
      revenue_usd_millions < 0 |
      revenue_usd_millions > 30000  # No single product exceeds $30B
    )
  
  if (nrow(suspicious) > 0) {
    cat("\n⚠ Suspicious values found (negative or > $30B):\n")
    print(suspicious)
  }
  
  cat("\nValidation complete.\n")
}

cat("
═══════════════════════════════════════════════════════════════════════════════
                              Ready to Extract                                  
═══════════════════════════════════════════════════════════════════════════════

After completing extraction, run:
  validate_revenue_data()

Then proceed to:
  source('scripts/02_data_preparation.R')
\n")
