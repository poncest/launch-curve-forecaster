"""Merge the 2013-2017 analog expansion into the raw files read by 02_data_preparation.R.

Inputs (sourced by hand, one row per reported value, with URL and status):
  data/raw/expansion/candidates.csv   every 2013-2017 oncology NME and its keep/drop decision
  data/raw/expansion/revenue_new.csv  reported product sales in the owner's currency
  data/raw/expansion/fx_rates.csv     FRED annual averages (CHF, EUR) and monthly JPY

Outputs (rewritten in place, original 10 analogs kept unchanged):
  data/raw/analog_metadata.csv
  data/raw/sec_product_revenue.csv    adds period_start / period_end columns

Run from the project root:  python3 scripts/03_merge_analog_expansion.py
"""
import csv
from datetime import date
from pathlib import Path

RAW = Path("data/raw")
EXP = RAW / "expansion"

NEW_META = {
    # product: (indication_primary, moa_class, filing type)
    "Kadcyla":   ("HER2+ metastatic breast cancer", "HER2 antibody-drug conjugate", "Roche Finance Report"),
    "Pomalyst":  ("Multiple myeloma (relapsed/refractory)", "Immunomodulatory drug", "8-K results release"),
    "Xofigo":    ("Prostate cancer (mCRPC, bone metastases)", "Alpha-emitting radiopharmaceutical", "Bayer investor materials"),
    "Gazyva":    ("CLL (first line)", "Anti-CD20 antibody", "Roche Finance Report"),
    "Cyramza":   ("Gastric/GEJ adenocarcinoma (second line)", "VEGFR2 antibody", "Results release"),
    "Zydelig":   ("CLL (relapsed), follicular lymphoma", "PI3K-delta inhibitor", "Results release"),
    "Blincyto":  ("B-cell ALL (relapsed/refractory)", "CD19xCD3 bispecific T-cell engager", "Results release"),
    "Lenvima":   ("Differentiated thyroid cancer (RAI-refractory)", "Multikinase inhibitor", "TSE results filing"),
    "Unituxin":  ("High-risk pediatric neuroblastoma", "Anti-GD2 antibody", "10-K / results release"),
    "Ninlaro":   ("Multiple myeloma (relapsed)", "Oral proteasome inhibitor", "Takeda databook"),
    "Empliciti": ("Multiple myeloma (relapsed)", "Anti-SLAMF7 antibody", "8-K results release"),
    "Alecensa":  ("ALK+ NSCLC (post-crizotinib)", "ALK inhibitor", "Roche Finance Report"),
    "Lartruvo":  ("Soft tissue sarcoma", "PDGFR-alpha antibody", "Results release"),
    "Rubraca":   ("BRCA-mutated ovarian cancer", "PARP inhibitor", "8-K results release"),
    "Kisqali":   ("HR+/HER2- advanced breast cancer", "CDK4/6 inhibitor", "6-K interim report"),
    "Bavencio":  ("Merkel cell carcinoma", "PD-L1 inhibitor", "Merck KGaA results release"),
    "Alunbrig":  ("ALK+ NSCLC (post-crizotinib)", "ALK inhibitor", "Takeda financial statements"),
    "Imfinzi":   ("Urothelial carcinoma (second line)", "PD-L1 inhibitor", "6-K results announcement"),
    "Nerlynx":   ("HER2+ early breast cancer (extended adjuvant)", "Pan-HER kinase inhibitor", "8-K results release"),
    "Verzenio":  ("HR+/HER2- advanced breast cancer", "CDK4/6 inhibitor", "Results release"),
}
META_NOTES = {
    "Lartruvo": "Withdrawn 2019 after the confirmatory trial failed; kept to avoid survivorship bias",
    "Alecensa": "Sold in Japan (Chugai) from 2014, before FDA approval; Roche totals include Japan",
    "Nerlynx": "Puma product revenue (mostly US); ex-US partners pay royalties",
    "Bavencio": "Merck KGaA books sales; Pfizer's profit share is alliance revenue",
}
FX_URL = {"CHF": "https://fred.stlouisfed.org/data/AEXSZUS",
          "EUR": "https://fred.stlouisfed.org/data/AEXUSEU",
          "JPY": "https://fred.stlouisfed.org/data/EXJPUS"}
JP_FISCAL = {"Eisai", "Takeda"}  # April-March fiscal years


def read(path):
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def fx_table():
    annual, monthly = {}, {}
    for r in read(EXP / "fx_rates.csv"):
        if r["frequency"] == "annual":
            annual[(r["currency"], int(r["period"]))] = float(r["rate"])
        else:
            monthly[r["period"]] = float(r["rate"])
    return annual, monthly


def to_usd(row, annual, monthly):
    """Return (usd_millions, rate_text) for a local-currency value."""
    cur, val, fy = row["currency"], row["revenue_local_millions"], int(row["fiscal_year"])
    if val == "":
        return "", ""
    v = float(val)
    if cur == "USD":
        return round(v, 1), ""
    if cur == "CHF":
        r = annual[("CHF", fy)]
        return round(v / r, 1), f"CHF {val}m converted at {r:.4f} CHF/USD (Fed annual average)"
    if cur == "EUR":
        r = annual[("EUR", fy)]
        return round(v * r, 1), f"EUR {val}m converted at {r:.4f} USD/EUR (Fed annual average)"
    if cur == "JPY":
        months = [f"{fy}-{m:02d}" for m in range(4, 13)] + [f"{fy + 1}-{m:02d}" for m in range(1, 4)]
        r = sum(monthly[m] for m in months) / 12
        return round(v / r, 1), (f"JPY {v / 100:,.0f}00m converted at {r:.2f} JPY/USD "
                                 f"(Fed monthly average, Apr {fy}-Mar {fy + 1})")
    raise ValueError(cur)


def main():
    cand = {r["product_name"]: r for r in read(EXP / "candidates.csv")}
    keep = [p for p, r in cand.items() if r["status"] == "candidate"]
    assert set(keep) == set(NEW_META), set(keep) ^ set(NEW_META)

    # --- metadata ---------------------------------------------------------
    meta = read(RAW / "analog_metadata.csv")
    meta_fields = list(meta[0].keys())
    meta = [m for m in meta if m["product_name"] not in NEW_META]
    for p in sorted(keep, key=lambda x: cand[x]["approval_date"]):
        c = cand[p]
        ind, moa, filing = NEW_META[p]
        meta.append({
            "product_name": p, "company": c["reporting_owner"],
            "fda_approval_year": c["approval_date"][:4], "fda_approval_date": c["approval_date"],
            "tumor_class": c["tumor_class"], "indication_primary": ind, "moa_class": moa,
            "sec_filing_type": filing, "sec_ticker": "", "notes": META_NOTES.get(p, ""),
        })
    with open(RAW / "analog_metadata.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=meta_fields, lineterminator="\n")
        w.writeheader()
        w.writerows(meta)

    # --- revenue ----------------------------------------------------------
    annual, monthly = fx_table()
    rev = read(RAW / "sec_product_revenue.csv")
    base_fields = [k for k in rev[0].keys() if k not in ("period_start", "period_end")]
    fields = base_fields + ["period_start", "period_end"]
    rev = [r for r in rev if r["product_name"] not in NEW_META]
    for r in rev:  # original analogs: calendar fiscal years
        r.setdefault("period_start", f"{r['fiscal_year']}-01-01")
        r.setdefault("period_end", f"{r['fiscal_year']}-12-31")
        if not r["period_start"]:
            r["period_start"], r["period_end"] = f"{r['fiscal_year']}-01-01", f"{r['fiscal_year']}-12-31"

    today = date.today().isoformat()
    for n in read(EXP / "revenue_new.csv"):
        p = n["product_name"]
        if p not in NEW_META:
            continue
        fy = int(n["fiscal_year"])
        usd, fx_note = to_usd(n, annual, monthly)
        if n["company"] in JP_FISCAL:
            start, end = f"{fy}-04-01", f"{fy + 1}-03-31"
        else:
            start, end = f"{fy}-01-01", f"{fy}-12-31"
        url = n["source_url"]
        if fx_note:
            url = f"{url} ; {FX_URL[n['currency']]}"
        notes = "; ".join(x for x in (fx_note, n["notes"]) if x)
        row = {
            "product_name": p, "company": n["company"], "fiscal_year": fy,
            "revenue_usd_millions": usd, "geography": n["geography"],
            "years_since_launch": fy - int(cand[p]["approval_date"][:4]),
            "source_filing": n["source_filing"], "extraction_date": today,
            "notes": notes, "source_url": url, "verification": n["verification"],
            "period_start": start, "period_end": end,
        }
        # Lartruvo: withdrawn in April 2019; the rest of 2019 carries no sales
        if p == "Lartruvo" and fy == 2019:
            rev.append({**row, "period_end": "2019-04-30"})
            rev.append({**row, "revenue_usd_millions": 0, "verification": "assumed_zero",
                        "period_start": "2019-05-01", "source_url": "",
                        "notes": "withdrawn from market April 2019"})
            continue
        rev.append(row)

    rev.sort(key=lambda r: (r["product_name"], r["period_start"]))
    with open(RAW / "sec_product_revenue.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, lineterminator="\n")
        w.writeheader()
        w.writerows(rev)
    print(f"metadata: {len(meta)} analogs; revenue: {len(rev)} rows")


if __name__ == "__main__":
    main()
