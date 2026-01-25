# Oncology Launch Curve Forecaster

**Decision Support Framework for VP-Level Launch Planning**

[![R](https://img.shields.io/badge/R-4.3+-blue.svg)](https://www.r-project.org/) [![Shiny](https://img.shields.io/badge/Shiny-1.8+-green.svg)](https://shiny.rstudio.com/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

------------------------------------------------------------------------

## Overview

This framework supports VP-level launch decisions by quantifying how uncertainty in uptake timing and analog selection translates into revenue risk and investment trade-offs.

**Target Persona:** Brand VP / Commercial Lead\
**Decision Window:** Pre-launch (12-18 months from approval)\
**Domain:** Oncology therapeutics

------------------------------------------------------------------------

## Key Questions Addressed

| Decision | Trade-off | Quantified Consequence |
|----|----|----|
| **Launch Timing** | Speed vs. readiness | Cumulative revenue at risk (\$M) |
| **Forecast Commitment** | Alignment vs. credibility risk | P25/P50/P75 scenario ranges |
| **Analog Selection** | Breadth vs. relevance | Impact on forecast bounds |

------------------------------------------------------------------------

## What This Framework Does

✅ Structures analog-based launch scenario analysis\
✅ Quantifies revenue ranges from analog variation\
✅ Supports trade-off conversations with stakeholders\
✅ Documents assumptions transparently

## What This Framework Does NOT Do

❌ Predict whether a specific launch will succeed\
❌ Recommend specific investment levels\
❌ Model competitive response timing\
❌ Estimate NPV or financial returns\
❌ Replace clinical or regulatory judgment

------------------------------------------------------------------------

## Screenshots

### Executive Brief

VP-level summary with key metrics, scenario comparison, and decision trade-offs.

![Executive Brief](screenshots/executive_brief.png)

### Scenario Builder

Configure analog selection criteria and scenario parameters.

![Scenario Builder](screenshots/scenario_builder.png)

### Analog Explorer

Examine individual analog launch curves and performance characteristics.

![Analog Explorer](screenshots/analog_explorer.png)

### Methods & Data

Transparent methodology, data sources, and limitations documentation.

![Methods](screenshots/methods.png)

------------------------------------------------------------------------

## Data Sources

| Source | Purpose | Access |
|----|----|----|
| **FDA Drug Approvals** | Approval dates (T=0), indications | [FDA.gov](https://www.fda.gov/drugs) |
| **SEC EDGAR Filings** | Product-level revenue | [SEC EDGAR](https://www.sec.gov/edgar) |
| **Published Literature** | Launch curve patterns | PubMed, peer-reviewed sources |

All data is publicly available. No proprietary or confidential data is used.

------------------------------------------------------------------------

## Technology Stack

-   **Framework:** R / Shiny
-   **UI Components:** shiny.semantic (Appsilon)
-   **Visualizations:** ggiraph, ggplot2
-   **Tables:** reactable
-   **Deployment:** shinyapps.io

------------------------------------------------------------------------

## Project Structure

```         
launch-curve-forecaster/
├── app/                    # Shiny application (deployed)
│   ├── app.R               # Entry point
│   ├── global.R            # Configuration and data loading
│   ├── ui.R                # Main UI
│   ├── server.R            # Main server
│   ├── modules/            # Shiny modules
│   │   ├── mod_executive_brief.R
│   │   ├── mod_scenario_builder.R
│   │   ├── mod_analog_explorer.R
│   │   └── mod_methods.R
│   ├── data/processed/     # App data
│   └── www/                # Static assets
├── scripts/                # Development scripts (not deployed)
│   ├── 00_setup_packages.R
│   ├── 01_data_collection.R
│   └── 02_data_preparation.R
├── data/                   # Raw and processed data
│   ├── raw/
│   └── processed/
└── docs/                   # Documentation
```

------------------------------------------------------------------------

## Getting Started

### Prerequisites

-   R 4.3+
-   RStudio (recommended)

### Installation

1.  Clone the repository:

``` bash
git clone https://github.com/poncest/launch-curve-forecaster.git
cd launch-curve-forecaster
```

2.  Install packages:

``` r
source("scripts/00_setup_packages.R")
```

3.  Prepare data (after collecting from SEC filings):

``` r
source("scripts/01_data_collection.R")
source("scripts/02_data_preparation.R")
```

4.  Run the app:

``` r
shiny::runApp("app/")
```

------------------------------------------------------------------------

## Methodology

### Analog Selection (Governance-First Approach)

Inclusion criteria are specified **before** examining outcome data to ensure defensible analysis:

1.  **Therapeutic Area:** Oncology (solid tumors and hematology)
2.  **Line of Therapy:** Configurable (All, 1L, 2L+)
3.  **Launch Window:** FDA approval 2010-2024
4.  **Revenue Threshold:** Configurable minimum peak
5.  **Data Availability:** Product-level revenue in SEC filings

### Scenario Construction

Percentile bands (P25/P50/P75) are calculated from selected analog performance:

-   **P50 (Base Case):** Median analog trajectory
-   **P75 (Optimistic):** Upper quartile performance
-   **P25 (Conservative):** Lower quartile performance

These are **observed analog ranges**, not statistical confidence intervals.

------------------------------------------------------------------------

## Author

**Steven Ponce**\
Data Professional \| Pharmaceutical Analytics

-   [LinkedIn](https://www.linkedin.com/in/stevenponce/)
-   [GitHub](https://github.com/poncest)
-   [Portfolio](https://stevenponce.netlify.app/)

------------------------------------------------------------------------

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

------------------------------------------------------------------------

## Disclaimer

This is a portfolio project for demonstration purposes. It uses publicly available data and should not be used for actual commercial decisions. All analysis reflects publicly reported information only.

------------------------------------------------------------------------

*Built with lessons learned from Clinical Trial Forecaster, Apple ESG Dashboard, Microsoft Financial Dashboard, and Pharma R&D Simulator projects.*
