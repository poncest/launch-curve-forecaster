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

> **Analog set expanded (October 2026).** The ten original analogs were all prominent launches, so the bands overstated a typical launch. Every new oncology molecular entity first approved by the FDA in 2013–2017 was screened (56 products) and the set grew to **30 analogs**, including modest launches and one withdrawn drug. P50 Year-5 revenue fell from about $4.3B to **$981M**. Launch years are now counted from each drug's exact approval date instead of the calendar year.

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
| Governance-first analog selection | Criteria fixed before outcomes are examined; the app records them in a downloadable scenario record (approval itself happens outside the app) |
| Delay exposure | Sales displaced at the end of exclusivity and first-year sales deferred, for a configurable delay |
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

![Executive Brief](screenshots/executive_brief.png) *High-level summary with key metrics (analog count, historical median Year-5 revenue and range, delay exposure, median Year-1 revenue), scenario comparison chart, and decision framing.*

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

-   **Therapeutic area:** Oncology treatments (solid tumors and/or hematology)
-   **Product type:** New molecular entity; CAR-T cell therapies excluded (their launches are paced by treatment-center certification and manufacturing slots)
-   **Launch window:** First FDA approval 2013–2017
-   **Data availability:** Sales reported separately by one owner for Years 1–5
-   **Withdrawn drugs are kept** (Lartruvo): dropping failed launches would bias the bands upward

All 56 candidates and the reason each was kept, dropped or ruled out of scope are in `data/raw/expansion/candidates.csv`: 30 included, 16 dropped (sales not reported separately, or ownership changed within the first five years), 10 out of scope (CAR-T, supportive care, imaging, reformulations).

Two optional filters use outcomes (excluding the top analog, and a minimum Year-5 revenue). Because they look at results, they are offered as **sensitivity checks**, not selection criteria.

**Scenario record.** The app supports governance rather than enforcing it: anyone can change the selection and see the results. The Scenario Builder therefore exports a dated Markdown record of the applied criteria, included and excluded products (with the reason for each exclusion), whether an outcome-based filter was on, the data version, the inputs and the results, plus a free-text rationale. The criteria are saved when Apply is clicked, so the record always describes the criteria behind its products and results; changes made in the controls but not applied are flagged, not mixed in. That record is what gets filed with the approval.

**Alignment:** Launch Year 1 is the 12 months after each drug's first FDA approval date, Year 2 the next 12 months, and so on to Year 5. Companies report by fiscal year (April–March for Eisai and Takeda), so each fiscal-year total is spread evenly over the days it covers and split across the launch years it overlaps (`scripts/02_data_preparation.R`). Sales usually grow within a year, so this slightly overstates early launch years and understates later ones.

------------------------------------------------------------------------

### Scenario Construction

Percentile bands are derived from observed analog performance:

-   **P50:** historical median of the selected analogs
-   **P25 / P75:** historical interquartile range

> **Important:** These describe the selected historical products. They are not confidence intervals, and P50 is not a 50% probability for a new product. The median curve joins each year's median, which can come from different products, so it summarizes the set rather than tracing a launch that happened. The chart shows how many analogs sit behind each year (26 to 30).

> **Year-5 revenue, not peak:** every analog is observed for five years after approval. Most were still growing at Year 5 (Zydelig, Nerlynx, Rubraca and the withdrawn Lartruvo had already peaked), so revenue figures describe Year-5 revenue, not a lifetime peak.

------------------------------------------------------------------------

### Delay Exposure Calculation

```         
Delay exposure (fixed exclusivity end) = delay_quarters / 4 × median Year-5 revenue
Deferred first-year sales       = delay_quarters × (median Year-1 revenue / 4)
```

**Product mode (optional).** Enter the Year-5 revenue you expect for your own product in the Scenario Builder, for example from a patient-based forecast. Each analog's curve is divided by its own Year-5 revenue to give its launch *shape*, and the shapes are scaled to your figure. The analogs then inform how fast revenue ramps, not how large it gets, and the cost of delay uses your numbers:

```
Implied Year-t revenue = expected Year-5 revenue × P50 analog shape at Year t
```

The deferred figure is a Year-1 average-quarter approximation. The exposure figure assumes the Year-5 run rate applies to the final quarters of exclusivity, often ten or more years after launch; sales then could be higher (continued growth) or lower (competition, label changes), so it is an exposure estimate, not a bound. A full comparison would value the delayed and on-time revenue paths over the same calendar horizon. Lartruvo, with no Year-5 sales, has no defined shape and is left out of product mode.

------------------------------------------------------------------------

## Key Assumptions Documented

-   **Exclusivity:** A delay usually leaves the exclusivity end date unchanged, so delayed months are lost at the end of exclusivity; the deferred view is shown for comparison. Share lost to earlier competitors is not modeled
-   **Label expansion bias:** Some analogs experienced post-launch indication expansion, creating potential upward bias
-   **Era effects:** The analogs cover FDA approvals from 2013 to 2017 only; launches after 2018 face different conditions

------------------------------------------------------------------------

## Data Sources

| Source | Purpose | Access |
|----|----|----|
| Company annual reports, results releases and investor materials | Worldwide product sales by fiscal year (SEC filings; European and Japanese company reports) | Source URL per value in `data/raw/sec_product_revenue.csv` (new analogs as reported, in `data/raw/expansion/revenue_new.csv`) |
| Federal Reserve (FRED) | Average exchange rates for the same period: CHF (AEXSZUS), EUR (AEXUSEU) annual; JPY (EXJPUS) monthly, averaged over April–March fiscal years | `data/raw/expansion/fx_rates.csv` |
| FDA Drug Approvals | Approval dates (T=0), indications | [FDA.gov](https://www.fda.gov/drugs) |

**Definitions where reporting differs:** Imbruvica = US sales (Pharmacyclics, then AbbVie) + J&J ex-US sales; Opdivo = BMS-reported, excluding Ono's territories (Japan, Korea, Taiwan); Nerlynx = Puma product revenue (mostly US; partners outside the US pay royalties); Bavencio = Merck KGaA sales (Pfizer's profit share is alliance revenue); Takeda figures include royalty and service income; Alecensa includes Japan sales from before FDA approval; Lartruvo sales after its April 2019 withdrawal taken as zero.

**Data status:** 166 of 169 reported values verified against the company's own report. Imbruvica 2015 is an estimate (no filing covers April 1–May 25, 2015, around AbbVie's acquisition of Pharmacyclics); Ibrance 2015–2016 are not yet traced to a primary source. Ten fiscal-year values were not reported separately or not found (mostly launch years), which leaves these launch years missing: Kadcyla and Gazyva Years 1–2, Xofigo and Venclexta Year 1, Lartruvo Year 3. Percentiles for each year use the analogs available for that year (26 to 30).

All data used is publicly available. No proprietary or confidential information is included.

------------------------------------------------------------------------

## Analog Set (30 Oncology Products)

Every 2013–2017 oncology new molecular entity that meets the criteria above:

-   **Solid tumors (20):** Keytruda, Opdivo, Ibrance, Tagrisso, Lynparza, Tecentriq, Kadcyla, Xofigo, Cyramza, Lenvima, Unituxin, Alecensa, Lartruvo, Rubraca, Kisqali, Bavencio, Alunbrig, Imfinzi, Nerlynx, Verzenio
-   **Hematology (10):** Imbruvica, Darzalex, Venclexta, Calquence, Pomalyst, Gazyva, Zydelig, Blincyto, Ninlaro, Empliciti

------------------------------------------------------------------------

## Reproduce

Requires R 4.3+ and the packages in `app/DESCRIPTION` (installed from CRAN; the project does not use renv).

```r
install.packages(c("shiny", "shiny.semantic", "dplyr", "tidyr", "purrr", "stringr",
                   "scales", "ggplot2", "ggiraph", "reactable", "readr"))
```

From the project root:

1.  `python3 scripts/03_merge_analog_expansion.py`: merge the sourced values in `data/raw/expansion/` into the raw files (only needed after editing those sourced values)
2.  `Rscript scripts/02_data_preparation.R`: build launch years and write `app/data/processed/`
3.  `Rscript scripts/04_deploy_checks.R`: check the app folder before deploying
4.  `shiny::runApp("app")`

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
-   Launch years are apportioned from fiscal-year totals assuming even sales within each year
-   16 eligible drugs were dropped because their sales were not reported separately or their owner changed. They include small launches (Farydak, Odomzo) and large ones (Tafinlar + Mekinist, Zejula), so the direction and size of any remaining bias are unknown
-   Worldwide sales are aligned to the US approval date: a drug sold elsewhere first (Alecensa in Japan from 2014) has higher early launch years, one launched outside the US later has lower ones
-   Five launch years are missing (see Data status), so early-year percentiles rest on 26–29 analogs
-   Opdivo excludes Ono's territories (Japan, Korea, Taiwan), so its curve understates global sales
-   Label expansion can introduce upward bias in Year-5 revenues
-   Earlier analogs may not fully reflect current launch environments
-   Delay exposure is a run-rate approximation, not a comparison of revenue paths or a DCF model
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

**Version:** 2.0.0\
**Last updated:** October 2026
