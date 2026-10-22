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

-   **Therapeutic area:** Oncology treatments (solid tumors and/or hematology)
-   **Product type:** New molecular entity; CAR-T cell therapies excluded (their launches are paced by treatment-center certification and manufacturing slots)
-   **Launch window:** First FDA approval 2013–2017
-   **Data availability:** Sales reported separately by one owner for Years 1–5
-   **Withdrawn drugs are kept** (Lartruvo): dropping failed launches would bias the bands upward

All 56 candidates and the reason each was kept, dropped or ruled out of scope are in `data/raw/expansion/candidates.csv`: 30 included, 16 dropped (sales not reported separately, or ownership changed within the first five years), 10 out of scope (CAR-T, supportive care, imaging, reformulations).

Two optional filters use outcomes (excluding the top analog, and a minimum Year-5 revenue). Because they look at results, they are offered as **sensitivity checks**, not selection criteria.

**Alignment:** Launch Year 1 is the 12 months after each drug's first FDA approval date, Year 2 the next 12 months, and so on to Year 5. Companies report by fiscal year (April–March for Eisai and Takeda), so each fiscal-year total is spread evenly over the days it covers and split across the launch years it overlaps (`scripts/02_data_preparation.R`). Sales usually grow within a year, so this slightly overstates early launch years and understates later ones.

------------------------------------------------------------------------

### Scenario Construction

Percentile bands are derived from observed analog performance:

-   **P50 (Base Case):** Median analog trajectory
-   **P75 (Upper Range):** Upper quartile performance
-   **P25 (Lower Range):** Lower quartile performance

> **Important:** These represent observed analog ranges, not statistical confidence intervals.

> **Year-5 revenue, not peak:** every analog is observed for five years after approval. Most were still growing at Year 5 (Zydelig, Nerlynx, Rubraca and the withdrawn Lartruvo had already peaked), so revenue figures describe Year-5 revenue, not a lifetime peak.

------------------------------------------------------------------------

### Revenue-at-Risk Calculation

```         
Lost if exclusivity end is fixed = delay_quarters / 4 × P50 Year-5 revenue   (lower bound for analogs still growing at Year 5)
Deferred first-year sales       = delay_quarters × (median Year-1 revenue / 4)
```

**Product mode (optional).** Enter the Year-5 revenue you expect for your own product in the Scenario Builder, for example from a patient-based forecast. Each analog's curve is divided by its own Year-5 revenue to give its launch *shape*, and the shapes are scaled to your figure. The analogs then inform how fast revenue ramps, not how large it gets, and the cost of delay uses your numbers:

```
Implied Year-t revenue = expected Year-5 revenue × P50 analog shape at Year t
```

The deferred figure is a Year-1 average-quarter approximation; the lost figure is a lower bound for products still growing at Year 5. Lartruvo, with no Year-5 sales, has no defined shape and is left out of product mode.

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
-   Survivorship in the data, not the selection: 16 eligible drugs were dropped because their sales were not reported separately or their owner changed; these are mostly smaller launches, so the bands may still lean slightly high
-   Five launch years are missing (see Data status), so early-year percentiles rest on 26–29 analogs
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

**Version:** 2.0.0\
**Last updated:** October 2026
