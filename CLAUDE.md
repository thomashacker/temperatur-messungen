# Abschlussbericht Temperaturmessung 2026 — Working Briefing

This file is the persistent context for this workspace. Read it first every session.
It condenses everything in `../CONTEXT/` so we can write focused analysis scripts without
re-exploring each time.

---

## 1. What this project is about

Urban-climate ("Stadtklima") measurement campaign comparing **a tree-lined street vs. a
bare street** in terms of temperature. The core research question:

> **Does the green (tree-lined) street stay cooler than the bare street, and by how much —
> for air temperature (Ta) and surface temperature (Ts)?**

Optionally the story is enriched with **wind**, **globe temperature / heat stress (WBGT)**,
radiation, humidity, and **shadow** (sun/shade geometry).

**The two streets (memorize this — it drives every grouping):**

| Stations | `station_order` | Street (nMetos name) | Trees? | German labels used in scripts |
|----------|-----------------|----------------------|--------|-------------------------------|
| st01–st04 | 1–4 | **Husemann**straße | **yes** | `Begrünte Straße` / `mit Bäumen` |
| st05–st08 | 5–8 | **Hagenauer**straße | **no**  | `Unbegrünte Straße` / `ohne Bäume` |

Positive difference convention throughout: **`ohne Bäume − mit Bäumen`** → positive means the
bare street is warmer (i.e. trees cool).

**Authors of the original scripts:** Hannah Balle (main), Adelina Petkova (`script1.R`).

---

## 2. Workspace layout

- **`Abschlussbericht/`** ← *this folder = our workspace.* New scripts, plots, and outputs go here.
- **`../CONTEXT/`** ← read-only source material: the frozen dataset, the original/legacy analysis
  scripts, raw logger files, existing plots, shadow rasters, and derived tables.
  Treat CONTEXT as reference — don't edit it; copy patterns out of it.

**Working convention (agreed):** one self-contained R script per plot/figure we want.
Each script loads the dataset, builds one figure (or a small tight set), and saves a PNG.

---

## 3. The dataset — `campaign_2026.rds`

Location: `../CONTEXT/campaign_2026.rds` (448 KB). This is the **frozen, analysis-ready output**
of an upstream pipeline (see §7). We consume it; we don't rebuild it.

```r
# Canonical loader for any new script in Abschlussbericht/
M <- readRDS("/Users/edwardschmuhl/Desktop/Work/Forks/Hannah_Abschlussbericht_Temperaturmessung_2026/CONTEXT/campaign_2026.rds")
d <- M$data          # <- the analysis table you want (320 rows × 90 cols)
```

> ⚠️ **Path gotcha:** every legacy script in CONTEXT hardcodes
> `~/Uni/Uni SoSe26/Datenanalyse_Stadtklima/campaign_2026.rds`, which does **not** exist on this
> machine. When reusing legacy code, always repoint the path to `../CONTEXT/campaign_2026.rds`.

`M` is a list with 8 components; **`M$data` is the one we normally use**. The others
(`station_visits`, `raw`, `logger_index`, `aggregated_logger_data`, `manual_data`, `metadata`,
`diagnostics`) are provenance/QA and rarely needed for plotting.

### `M$data`: 320 rows = 40 rounds × 8 stations

- **`round_no`** 1–40, **8 stations per round** → 320 visits. One row = one station visit.
- **Time window:** 2026-06-18 18:00 → 2026-06-20 09:47 **CEST** (~40 h, spans 2 nights + 1.5 days).
- Raw timestamps are **UTC**; convert with `lubridate::with_tz(x, "Europe/Berlin")` for local time.
- **3 rows are `visit_status == "missing_visit"`** (measurement columns are `NA`); 317 are `"ok"`.

---

## 4. Column dictionary (90 cols, grouped by prefix)

**Identity / time (use these for grouping & x-axes):**
- `visit_id`, `round_no`, `station`, `station_order`, `station_label` (`"Station 1"`…)
- `round_date_local` (Date), `beginn_local_parsed` / `ende_local_parsed` (**local** POSIXct),
  `logger_beginn_parsed` / `logger_ende_parsed` (**UTC** POSIXct), `logger_duration_min`
- `visit_status` (filter to `"ok"` for clean data)

**`humve_meteo_*` — mobile cart, the primary Ta/Ts source (1 value per visit):**
- `humve_meteo_Ta_mean` — **air temperature °C** (main variable; range 20.8–34.8)
- `humve_meteo_Ts_mean` — surface temp from radiometer °C (21.6–36.4)
- `humve_meteo_RH_mean` (humidity), `humve_meteo_NetRad_mean`, `humve_meteo_ShortIn_mean`,
  `humve_meteo_ShortOut_mean` (radiation)

**`humve_wind_*` / `humve_gill_*` — wind (Gill sonic anemometer):**
- `humve_wind_wind_speed_gill_mean` — **wind speed m/s** (0.1–3.1), `humve_wind_wind_dir_gill_vector_mean_direction`
- `humve_gill_u/v/w_mean`, variances/covariances, `humve_gill_Tv_mean` (turbulence; advanced)

**`humve_control_*`** — housekeeping (battery, logger case temp). Ignore for analysis.

**`nMetos_{hagenauer2,hagenauer11,husemann21,husemann30}_*` — 4 stationary weather stations
(2 per street), continuous reference:**
- `..._Ta_mean` (air temp), `..._RH_mean`, `..._Precip_sum`, plus battery/solar housekeeping.
- hagenauer2/11 = bare street; husemann21/30 = tree street.
- Used as the **stationary** counterpart to the **mobile** HuMVe measurements.

**`kestrel_*` — handheld heat-stress meter (⚠️ 61 NAs, only ~259 valid):**
- `kestrel_Tg_mean` — **globe temperature °C** (20.7–45.5, radiant heat load)
- `kestrel_WBGT_mean` — **WBGT heat-stress index** (19.2–31.1), `kestrel_Ta_mean`, `kestrel_Tw_mean`
  (wet bulb), `kestrel_Td_mean` (dew point), `kestrel_HeatIndex_mean`, `kestrel_wind_speed_mean`, etc.

**`manual_*` — ODK field protocol (manual readings per station):**
- **`manual_Ts_1..manual_Ts_4`** — 4 manual IR surface-temp spot readings per visit °C
  (18.8–47.4; the richest Ts signal — 4 points × 8 stations). Numeric in the rds, but legacy
  scripts still `as.numeric()` them defensively because they were once stored as text.
- `manual_cloud_cover_oktas`, `manual_pm25/pm10_min/max`, `manual_noise_min/max`.

---

## 5. Two "sources" of air temperature (important modeling choice)

Legacy analysis (`../CONTEXT/Datenanalyse_Temp.R`) splits Ta into:
- **mobil (HuMVe):** `humve_meteo_Ta_mean` — one value per station visit.
- **stationär (nMetos):** the 4 `nMetos_*_Ta_mean` columns, pivoted long.

Then both are combined and grouped by `trees_label` (mit/ohne Bäume). Surface temp (Ts) has two
flavors too: mobile radiometer `humve_meteo_Ts_mean` vs. manual IR `manual_Ts_1..4`.

---

## 6. Key findings already established (cite these; reproduce, don't re-derive blindly)

From `../CONTEXT/statistik_ergebnisse.txt` — **paired t-test per round (methodically honest;
avoids pseudoreplication)**:

| Variable | Mean diff (ohne − mit Bäumen) | 95% CI | p-value | Verdict |
|----------|-------------------------------|--------|---------|---------|
| **Air temp (Ta)** | **+0.50 °C** | [0.33, 0.67] | 5.4e-07 | bare street warmer, significant |
| **Surface temp (Ts)** | **+2.62 °C** | [1.71, 3.52] | 8.4e-07 | bare street much warmer, significant |

Descriptive means: Ta 25.4 (trees) vs 25.8 (bare); Ts 24.1 (trees) vs 26.8 (bare), and Ts spreads
far wider on the bare street (sd 6.0 vs 3.3; max 48.7 vs 41). **Surface temp shows the tree effect
much more strongly than air temp** — the headline result.

> Note: `Lufttemperatur_Skript.R` reports a smaller Ta difference (0.20/0.22 °C) — that's a
> *per-hour* aggregation over all stations, not the per-round paired mean (0.50 °C). Different
> aggregation, both valid; be explicit about which one a figure uses.

**Methodological caution baked into the legacy stats:** each point is visited 40× → naive t-tests
over-count independence (pseudoreplication/autocorrelation). Prefer **per-round paired** tests or
Wilcoxon as backup.

---

## 7. How the data was produced (context only — not run here)

`../CONTEXT/00_main.R` is the upstream 4-phase pipeline (Phase 0 setup → Phase 1 read raw →
Phase 2 QA → Phase 3 build campaign dataset → Phase 4 viz/export). It `source()`s a `prog/…`
tree and reads `data/Y2026/…` raw files that are **not present in this repo**, so `00_main.R`
is **not runnable here**. Its output is exactly the `campaign_2026.rds` we already have.

Raw instrument feeds (some copies present in CONTEXT):
- **HuMVe** mobile cart (CR1000/TOA5 logger) — meteo, wind, Gill sonic, control.
- **nMetos** stationary stations — `hagenauer2/11.txt`, `husemann21/30.txt` (⚠️ sensor swap
  mid-campaign 2026-06-10 for some).
- **Kestrel** heat-stress handheld CSV. **ODK** field protocol (`rawdata/odk_raw.rds`).

---

## 8. Existing scripts in CONTEXT (mine these for patterns)

| Script | What it does / reuse for |
|--------|--------------------------|
| `Datenanalyse_Temp.R` | **Best reference.** Ta extraction (mobil+stationär → long), tagesgang (diurnal) plots, per-street comparison, full stats block (kennzahlen, t-tests, Wilcoxon, Excel/txt export). |
| `Datenanalysee_Surface_Temp.R` | Surface temp (`manual_Ts_*`) → long/wide, **heatmap** (messpunkt × hour), Excel export `oberflaechentemperatur.xlsx`. |
| `Abschlussbericht_GPII/Lufttemperatur_Skript.R` | Clean Ta time-series plot with **day/night background rectangles** (05–22 = day), shared axes, per-street mean diff. Already path-fixed & verified running. |
| `Abschlussbericht_GPII/Lufttemperatur+Wind.R` | Ta combined with wind (uses `patchwork`, `ggridges`). |
| `Statistische_Analyse_GPII.R` | Long-format reshaping + Ta graphs + stats. |
| `Temp_Air.R` | Explorative Ta EDA (mobil + stationär), uses `univOutl` for outlier detection. |
| `script1.R` (A. Petkova) | Alternative take on the analysis. |
| `phase*_*.R`, `read_humve_func.R` | Upstream readers/QA (part of the pipeline, not for plotting). |

---

## 9. Existing outputs already in CONTEXT

- **Derived tables (CSV):** `ta_agg_diurnal.csv` (mean Ta by source/street/hour),
  `ta_agg_station.csv` (per-station stats), `ta_anom_station.csv` (station anomalies),
  `ta_delta_per_round.csv` (per-round street delta).
- **Excel:** `statistik_ergebnisse.xlsx` (+`.txt`), `oberflaechentemperatur.xlsx`.
- **Plots:** `plots/tagesgang_lufttemperatur.png`, `plots/tagesgang_strasse.png`,
  `plots/heatmap_oberflaeche_uhrzeit.png`, `plots/Ta_average`, plus `Ta_HuMVe*.png`,
  `Surface_Temp_Matrix.png`, `oberflächentemp.png`, and a `plots/unserious plots/` set.
- **`shadowmaps/`** — hourly **GeoTIFF** sun/shade rasters, `Shadow_2026_<DOY>_<HHMM><D|N>.tif`
  (DOY 169–171 = 18–20 Jun 2026; `D`=day, `N`=night). **Not yet used by any R script** — this is
  raw material for a future shadow/shade analysis (would need `terra`/`raster` + `sf`, not yet installed).

---

## 10. Environment & packages

R 4.5.1 (Apple Silicon). Installed and verified: **tidyverse** (dplyr, ggplot2, tidyr, readr,
stringr, lubridate, tibble, purrr), **rmarkdown/knitr**, **pandoc 3.10**, **TinyTeX** (PDF).
`scales` is included (via ggplot2).

**Not yet installed** — some legacy scripts need these; install on demand:
`writexl` (Excel export), `patchwork` (plot composition), `ggridges` (ridgeline), `gt` (tables),
`univOutl` (outlier detection). For shadow rasters later: `terra`, `sf`.

---

## 11. Conventions for new scripts (our workflow)

> **Current phase: ANALYSIS FIRST — no plots yet.** Focus on exploring/aggregating the data
> (tables, summaries, statistics, sanity checks). Do not build figures until explicitly asked.
> Priority variables: **air temperature (Ta)** and **surface temperature (Ts)**.

**Folder structure of this workspace:**
```
Abschlussbericht/
  CLAUDE.md          # diese Datei
  skripte/           # R-Skripte: EIN Skript pro Auswertung/Grafik
                     #   + je Skript eine gleichnamige .md mit den Ergebnissen
    wind_sidequest/  # abgeschlossene Nebenuntersuchung Wind (kein klares Ergebnis)
  plots/             # erzeugte Grafiken (PNG)
    wind_sidequest/  # Grafiken der Wind-Nebenuntersuchung
```

> **Hinweis Wind-Sidequest:** Die Untersuchung, ob der Wind den Mittags-Spike erklärt, liegt
> gebündelt in `skripte/wind_sidequest/` und `plots/wind_sidequest/`. Ergebnis: kein eigenständiger
> Windeffekt nachweisbar, der Schatten/die Einstrahlung ist die näherliegende Erklärung. Skripte dort
> speichern nach `../../plots/wind_sidequest/`.

**Core rules (see §12 for the full style guide):**
1. **One script per analysis/figure**, self-contained, saved in `skripte/`.
2. Load data with the canonical loader in §3 (absolute path to `../CONTEXT/campaign_2026.rds`).
3. Filter to `visit_status == "ok"` (or handle the 3 `missing_visit` NAs explicitly).
4. Derive street/trees grouping from `station_order` (§1) — don't hardcode station→street elsewhere.
5. Times: raw = UTC → `with_tz(..., "Europe/Berlin")` for anything shown to humans.
6. Be explicit about **which aggregation** (per-round paired vs per-hour) a number uses.
7. Plots (later phase): save to `plots/` with `ggsave(..., dpi = 150, bg = "white")`.
   Green street = green tones, bare street = brown/grey (legacy palette:
   `mit Bäumen = #2E7D32`, `ohne Bäume = #B0662A`; or forestgreen / gray60).

---

## 12. Script style guide (VERBINDLICH / mandatory)

Vorbild ist `../CONTEXT/Abschlussbericht_GPII/Lufttemperatur_Skript.R`. Ziel: **leicht
verständliche, kommentierte Skripte auf Deutsch**, jeweils mit einer **gleichnamigen
Ergebnis-`.md`**.

### 12.1 Sprache & Benennung
- **Alle Kommentare, Titel und Variablen-/Funktionsnamen auf Deutsch** (z. B. `aggregiere_ta()`,
  `tag_rechtecke`, `mittlere_differenz`, `zeitbereich`, `strassen_vergleich`).
- Datei- und Ordnernamen: `snake_case`, deutsch, beschreibend
  (z. B. `lufttemperatur_tagesgang.R`, `oberflaeche_kennzahlen.R`).
- Umlaute in Dateinamen vermeiden (`oberflaeche` statt `oberfläche`); im Fließtext/Kommentaren ok.

### 12.2 Skript-Aufbau (immer diese Reihenfolge)
1. **Kopf** (`#'`): Titel der Auswertung, Projekt, Autor, kurz was das Skript tut.
2. **`# --- Pakete ---`**: nur die wirklich genutzten `library()`-Aufrufe.
3. **`# --- Daten laden ---`**: kanonischer Loader (§3), Pfad auf `../CONTEXT/campaign_2026.rds`.
4. **`# --- Aufbereitung ---`**: Filter (`visit_status == "ok"`), Zeit lokal, Straßen-Zuordnung.
5. **`# --- Berechnung/Aggregation ---`**: klar benannte Schritte, ein Abschnitt pro Idee.
6. **`# --- Ergebnisse ---`**: Kennzahlen ausgeben (`print`/`cat`), sodass sie in die `.md` wandern.
- Abschnitte mit `# --- Titel ------------------------------------` trennen (wie im Vorbild).
- **Jeder nicht-triviale Block bekommt einen deutschen Kommentar, der das WARUM erklärt**, nicht
  nur das WAS. Lieber ein Satz zu viel als kryptischer Code.
- Kurze, reine Funktionen für wiederverwendbare Schritte (siehe `aggregiere_ta()` im Vorbild).

### 12.3 Pflicht: Ergebnis-`.md` je Rechen-/Statistik-Skript
Jedes Skript, das rechnet/aggregiert/testet, bekommt eine **`.md` mit demselben Basisnamen im
selben Ordner** (`skripte/lufttemperatur_tagesgang.R` → `skripte/lufttemperatur_tagesgang.md`).
**Komplett auf Deutsch, präzise, informativ, aber nicht überladen.** Feste Gliederung:

```markdown
# <Titel der Auswertung>

**Skript:** `skripte/<name>.R`
**Datum:** <JJJJ-MM-TT>

## Verwendete Daten
- Quelle: `campaign_2026.rds` → `M$data`
- Variablen: <z. B. humve_meteo_Ta_mean>
- Stationen/Straßen: <z. B. st01–08; begrünt vs. unbegrünt>
- Zeitraum/Filter: <z. B. 18.–20.06.2026; nur visit_status == "ok">
- Anzahl Werte (n): <…>

## Aggregation / Methode
- <Wie gruppiert und gerechnet: z. B. Mittelwert je Stunde je Straße;
  gepaarter t-Test pro Runde. Kurz und konkret.>

## Ergebnisse
- <Kennzahlen: n, min, max, Mittelwert, Median, sd, IQR – je nachdem was passt>
- <Differenzen/Testergebnisse: z. B. Δ = +2,62 °C; p = 8,4e-07>
- <ggf. kleine Tabelle>

## Kurzinterpretation (1–3 Sätze)
- <Was bedeutet das inhaltlich? Vorsichtig formulieren, Kampagnenzeitraum beachten.>

## Begriffe kurz erklärt
- <Jeden im Bericht verwendeten Fachbegriff in einem Satz allgemeinverständlich erklären,
  z. B. IQR-Regel, Standardabweichung, Median, gepaarter t-Test, p-Wert, Konfidenzintervall,
  Wilcoxon-Test, Pseudoreplikation. Nur die tatsächlich vorkommenden Begriffe aufführen.>

## Erzeugte Dateien
- <z. B. plots/lufttemperatur_tagesgang.png, falls vorhanden>
```

**Pflicht:** Jeder Bericht enthält den Abschnitt **„Begriffe kurz erklärt"**, der alle im Bericht
genutzten Fachbegriffe (Statistik und Fachsprache) je in einem einfachen Satz erläutert.

Zahlen deutsch formatieren, wo sinnvoll (Dezimalkomma im Fließtext), Einheiten immer angeben (°C,
m/s). Keine langen Konsolen-Dumps in die `.md`, nur die relevanten Kennzahlen.

**Keine Gedankenstriche im Fließtext.** In Berichtstexten keine Binde-/Gedankenstriche als
Satzzeichen (kein « – », kein « — », kein « - » als Einschub oder Aufzählung). Stattdessen Kommas,
Klammern, Doppelpunkte oder eigene Sätze verwenden. Ausnahmen: feste Fachbegriffe (`t-Test`,
`p-Wert`) und Zahlenbereiche (`05–22 Uhr`) behalten ihren Strich. Für Struktur lieber Tabellen und
kurze Absätze statt Spiegelstrich-Listen.

### 12.4 Konsistenz mit dem Projekt
- Vorzeichenkonvention **`ohne Bäume − mit Bäumen`** (positiv = unbegrünte Straße wärmer, §1).
- Bei Tests bevorzugt **gepaart pro Runde** (Pseudoreplikation vermeiden, §6).
- Immer angeben, **welche Aggregation** einer Zahl zugrunde liegt (per-Runde vs. per-Stunde).
