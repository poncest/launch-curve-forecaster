# Oncology Launch Curve Forecaster

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white) ![Shiny](https://img.shields.io/badge/Shiny-1A162D?style=for-the-badge&logo=rstudio&logoColor=white) ![Framework](https://img.shields.io/badge/Framework-Appsilon-0B6E6E?style=for-the-badge) ![Status](https://img.shields.io/badge/Status-Active-2ECC71?style=for-the-badge) ![License](https://img.shields.io/badge/License-MIT-A8E10C?style=for-the-badge)

**A governance-first decision support framework for pharmaceutical launch planning**

------------------------------------------------------------------------

## Overview

This project presents a decision support framework for pre-launch planning that quantifies how uncertainty in uptake timing and analog selection translates into **revenue risk and forecast trade-offs**.

The framework is designed for commercial launch planning contexts where leaders must reason under uncertainty, evaluate assumptions transparently, and communicate trade-offs clearly across functions.

**Intended Use Context**

-   **Decision Window:** Pre-launch planning (12–18 months from approval)
-   **Domain:** Oncology therapeutics (solid tumors and hematologic malignancies)
-   **Typical Users:** Commercial, brand, and planning leaders involved in launch readiness and forecasting discussions

------------------------------------------------------------------------

## Live Dashboard

🔗 **Interactive Shiny dashboard:**\
[Launch Curve Forecaster](https://0l6jpd-steven-ponce.shinyapps.io/launch_curve_forecaster/) (ShinyApps.io)

📝 **Case study write-up:** [Launch Curve Forecaster: a governance-first case study](https://stevenponce.netlify.app/projects/standalone_visualizations/sa_2026-01-28.html)

> **Data correction (October 2026).** All 60 revenue values were re-checked against company reports; 35 changed and 55 are now verified against a primary source (status per value below). The original dataset had Tecentriq in Swiss francs labeled as US dollars, an Imbruvica series that mixed two definitions, and several values that did not match the filings (for example Calquence 2019: $164M reported vs $372M stored). Each value carries its source and verification status in `data/raw/sec_product_revenue.csv`.

------------------------------------------------------------------------

## Core Decision Question

> **What is the revenue at risk if launch timing shifts under uncertainty?**

This framework supports that question by:

-   Structuring analog-based launch scenarios using a governance-first methodology
-   Quantifying the **cost of a launch delay** under configurable assumptions: sales lost at the end of exclusivity when the expiry date is fixed, versus first-year sales that are only deferred
-   Supporting P25 / P50 / P75 forecast trade-off discussions across stakeholders
-   Documenting assumptions, exclusions, and sensitivities transparently for audit and review

------------------------------------------------------------------------

## Key Capabilities

| Capability | Implementation |
|----|----|
| Governance-first analog selection | Inclusion criteria locked before examining outcomes |
| Revenue-at-risk quantification | Year 1 impact from configurable delay scenarios |
| Sensitivity testing | Option to exclude the top-performing analog (by Year-5 revenue) |
| Dynamic selection rationale | Live statistics: solid/heme count, approval-year range, median Year-5 revenue |
| Transparent methodology | Assumptions, limitations, and exclusions clearly documented |

------------------------------------------------------------------------

## What This Framework Does

✅ Structures analog-based launch scenario analysis\
✅ Quantifies revenue ranges from analog variation (P25 / P50 / P75)\
✅ Supports structured trade-off conversations under uncertainty\
✅ Documents assumptions and limitations transparently\
✅ Provides sensitivity checks to test analytical robustness

------------------------------------------------------------------------

## What This Framework Does *Not* Do

❌ Predict whether a specific launch will succeed\
❌ Recommend specific investment or resourcing levels\
❌ Model competitive response or market access dynamics\
❌ Estimate NPV or financial returns\
❌ Replace clinical, regulatory, or strategic judgment

**By design:**\
NPV and market access modeling are excluded because they require company-specific inputs that would compromise generalizability. Revenue scenarios are treated as **foundational inputs**, not final financial outputs.

------------------------------------------------------------------------

## Dashboard Preview

### Executive Brief

![Executive Brief](screenshots/executive_brief.png) *High-level summary with key metrics (analog count, Year-5 revenue range, cost of delay, median Year-1 revenue), scenario comparison chart, and decision framing.*

### Scenario Builder

![Scenario Builder](screenshots/scenario_builder.png) *Configure analog selection criteria, test delay scenarios, and examine dynamic selection rationale with live statistics and sensitivity checks.*

### Analog Explorer

![Analog Explorer](screenshots/analog_explorer.png) *Examine individual analog launch curves and performance characteristics, with guardrails against over-interpretation of any single analog.*

### Methods & Data

![Methods & Data](screenshots/methods.png) *Transparent documentation of methodology, data sources, assumptions, limitations, and explicitly excluded modeling domains.*

------------------------------------------------------------------------

## Methodology

### Analog Selection (Governance-First Approach)

Inclusion criteria are specified **before** examining outcome data to ensure defensible analysis:

-   **Therapeutic area:** Oncology (solid tumors and/or hematology)
-   **Launch window:** FDA approval 2013–2017
-   **Data availability:** Product-level revenue reported by the owner for Years 1–5

Two optional filters use outcomes (excluding the top analog, and a minimum Year-5 revenue). Because they look at results, they are offered as **sensitivity checks**, not selection criteria.

**Alignment:** Year 0 is the calendar year of first FDA approval, so it covers anywhere from 10 days (Opdivo) to about 11 months (Ibrance) on market; Year-0 values are not comparable across analogs, and Years 1–5 can be offset by up to about 11 months.

------------------------------------------------------------------------

### Scenario Construction

Percentile bands are derived from observed analog performance:

-   **P50 (Base Case):** Median analog trajectory
-   **P75 (Upper Range):** Upper quartile performance
-   **P25 (Lower Range):** Lower quartile performance

> **Important:** These represent observed analog ranges, not statistical confidence intervals.

> **Year-5 revenue, not peak:** every analog is observed from its approval year through the fifth full year after launch, and all were still growing at Year 5. Revenue figures therefore describe Year-5 revenue, not a lifetime peak.

------------------------------------------------------------------------

### Revenue-at-Risk Calculation

```         
Lost if exclusivity end is fixed = delay_quarters / 4 × P50 Year-5 revenue   (lower bound; analogs still growing at Year 5)
Deferred first-year sales       = delay_quarters × (median Year-1 revenue / 4)
```

**Product mode (optional).** Enter the Year-5 revenue you expect for your own product in the Scenario Builder, for example from a patient-based forecast. Each analog's curve is divided by its own Year-5 revenue to give its launch *shape*, and the shapes are scaled to your figure. The analogs then inform how fast revenue ramps, not how large it gets, and the cost of delay uses your numbers:

```
Implied Year-t revenue = expected Year-5 revenue × P50 analog shape at Year t
```

The deferred figure is a Year-1 average-quarter approximation; the lost figure is a lower bound, since every analog was still growing at Year 5.

------------------------------------------------------------------------

## Key Assumptions Documented

-   **Exclusivity:** A delay usually leaves the exclusivity end date unchanged, so delayed months are lost at the end of exclusivity; the deferred view is shown for comparison. Share lost to earlier competitors is not modeled
-   **Label expansion bias:** Some analogs experienced post-launch indication expansion, creating potential upward bias
-   **Era effects:** The analogs cover FDA approvals from 2013 to 2017 only; launches after 2018 face different conditions

------------------------------------------------------------------------

## Data Sources

| Source | Purpose | Access |
|----|----|----|
| Company annual reports and full-year results releases | Worldwide product sales by fiscal year (SEC 10-K and 8-K filings; AstraZeneca and Roche results announcements) | Source URL per value in `data/raw/sec_product_revenue.csv` |
| Federal Reserve (FRED series AEXSZUS) | Annual average CHF/USD rate, to convert Roche's Tecentriq sales | [FRED](https://fred.stlouisfed.org/series/AEXSZUS) |
| FDA Drug Approvals | Approval dates (T=0), indications | [FDA.gov](https://www.fda.gov/drugs) |

**Definitions where reporting differs:** Imbruvica = US sales (Pharmacyclics, then AbbVie) + J&J ex-US sales; Opdivo = BMS-reported, excluding Ono's territories (Japan, Korea, Taiwan); Tecentriq converted from CHF.

**Data status:** 55 of 60 values verified against a primary source. Imbruvica 2015 is an estimate (no filing covers April 1–May 25, 2015, around AbbVie's acquisition of Pharmacyclics). Ibrance 2015–2016 are not yet traced to a primary source. Launch-year sales are not reported for Lynparza (approved December 2014) and Venclexta (April 2016).

All data used is publicly available. No proprietary or confidential information is included.

------------------------------------------------------------------------

## Analog Set (10 Oncology Products)

The framework includes established oncology launches with disclosed product-level revenue:

-   **Solid tumors:** Keytruda, Opdivo, Ibrance, Tagrisso, Lynparza, Tecentriq
-   **Hematology:** Imbruvica, Darzalex, Venclexta, Calquence

------------------------------------------------------------------------

## Technology Stack

| Component     | Technology                   |
|---------------|------------------------------|
| Language      | R (4.3+)                     |
| Framework     | Shiny (modular architecture) |
| UI components | shiny.semantic (Appsilon)    |
| Visualization | ggplot2, ggiraph             |
| Tables        | reactable                    |
| Deployment    | shinyapps.io                 |

------------------------------------------------------------------------

## Design Principles

-   **Governance-first thinking** — lock criteria before examining outcomes
-   **Transparency over performance** — document assumptions and limitations
-   **Appropriate restraint** — clearly state what the tool does *not* do
-   **Decision support, not automation** — inform judgment, do not prescribe
-   **Executive communication** — lead with insights, support with data

------------------------------------------------------------------------

## Limitations

-   Reporting definitions differ slightly by company (see Data Sources)
-   Year 0 covers different lengths of time on market across analogs
-   Selection bias: the stated criteria would admit more launches than the ten included (e.g. Kisqali, Zejula, Ninlaro); the ten are commercially prominent, so the bands likely overstate a typical launch
-   Opdivo excludes Ono's territories (Japan, Korea, Taiwan), so its curve understates global sales
-   Label expansion can introduce upward bias in Year-5 revenues
-   Earlier analogs may not fully reflect current launch environments
-   Revenue-at-risk calculation is simplified (not a full DCF model)
-   Competitive dynamics and market access are not modeled

------------------------------------------------------------------------

## Author

**Steven Ponce**\
Senior Manager, Clinical Analytics & Centralized Monitoring \| R & Shiny

-   🔗 Portfolio: [stevenponce.netlify.app](https://stevenponce.netlify.app)
-   🐙 GitHub: [\@poncest](https://github.com/poncest)
-   💼 LinkedIn: [stevenponce](https://www.linkedin.com/in/stevenponce)

------------------------------------------------------------------------

## License

Released under the MIT License.

------------------------------------------------------------------------

## Disclaimer

This project is a **portfolio case study** intended to demonstrate analytical framing, governance, and decision-support design using publicly available data.

It is **not intended for real-world commercial decision-making** and is not affiliated with any pharmaceutical company. Product names are used for analytical illustration only.

------------------------------------------------------------------------

**Version:** 1.2.0\
**Last updated:** October 2026
