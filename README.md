# Temperaturmessung 2026: Datenanalyse Stadtklima

Auswertung einer städtischen Messkampagne, die eine **begrünte (baumbestandene) Straße** mit einer
**unbegrünten Straße** vergleicht. Zentrale Frage: Bleibt die begrünte Straße kühler, und um wie
viel, bei der **Lufttemperatur** und der **Oberflächentemperatur**?

Die Kampagne umfasst 40 Messrunden über rund 40 Stunden (18. bis 20.06.2026) an 8 Stationen, davon
4 an der begrünten Straße (Husemann) und 4 an der unbegrünten (Hagenauer).

## Inhalt des Repositories

```
.
├── CLAUDE.md            # ausführliches Projekt-Briefing (Daten, Spalten, Konventionen)
├── README.md            # diese Datei
├── skripte/             # R-Skripte, je ein Skript pro Auswertung
│   ├── *.R              #   die Analyse
│   ├── *.md             #   der zugehörige deutsche Ergebnisbericht (gleicher Name)
│   └── wind_sidequest/  #   abgeschlossene Nebenuntersuchung Wind (kein klares Ergebnis)
└── plots/               # erzeugte Grafiken (PNG)
    └── wind_sidequest/  #   Grafiken der Wind-Nebenuntersuchung
```

Zu **jedem Skript** gehört eine gleichnamige `.md`-Datei mit dem Ergebnisbericht (verwendete Daten,
Methode, Kennzahlen, Kurzinterpretation, Begriffe).

### Die Auswertungen

| Skript | Inhalt |
|--------|--------|
| `lufttemperatur_strassenvergleich.R` | Lufttemperatur im Zeitverlauf, begrünt vs. unbegrünt, mit Statistik |
| `oberflaeche_boxplot.R` | Oberflächentemperatur (Boden/Wand) als Boxplots je Tageszeit, mit Kennzahlen |
| `oberflaeche_zeitverlauf.R` | Oberflächentemperatur (Boden, Wand) im Zeitverlauf |
| `einstrahlung_zeitverlauf.R` | Einstrahlung im Zeitverlauf (erklärt einen Ausreißer der Lufttemperatur) |
| `wind_sidequest/` | Nebenuntersuchung, ob der Wind einen Ausreißer erklärt (Ergebnis: nein) |

## Voraussetzungen

- **R** ab Version 4.5
- R-Pakete: `dplyr`, `tidyr`, `ggplot2`, `lubridate`, `scales` (alle in `tidyverse` enthalten)

Installation der Pakete:

```r
install.packages(c("dplyr", "tidyr", "ggplot2", "lubridate", "scales"))
# oder einfach: install.packages("tidyverse")
```

## Setup: Datendatei bereitstellen

Die Analyse braucht die Datei **`campaign_2026.rds`**. Sie ist **nicht Teil dieses Repositories**
(Forschungsdaten). Es gibt zwei Wege, sie den Skripten bekannt zu machen:

**Variante A (empfohlen): Ordner `data/`**

Lege die Datei unter `data/campaign_2026.rds` im Projektwurzelverzeichnis ab:

```
Abschlussbericht_FINAL/
└── data/
    └── campaign_2026.rds
```

Der Ordner `data/` ist per `.gitignore` vom Versionieren ausgeschlossen, die Daten landen also
nicht versehentlich im Repository.

**Variante B: Umgebungsvariable**

Setze `CAMPAIGN_RDS` auf den vollständigen Pfad der Datei:

```bash
export CAMPAIGN_RDS="/pfad/zu/campaign_2026.rds"
```

Jedes Skript sucht die Datei automatisch in dieser Reihenfolge: zuerst `CAMPAIGN_RDS`, dann ein
`data/`-Ordner, dann ein `CONTEXT/`-Ordner neben dem Repository. Wird nichts gefunden, bricht das
Skript mit einer klaren Meldung ab.

## Skripte ausführen

Wichtig: Die Skripte werden **aus ihrem eigenen Ordner** ausgeführt, weil die Grafiken über
relative Pfade (`../plots/`) gespeichert werden.

```bash
cd skripte
Rscript lufttemperatur_strassenvergleich.R
Rscript oberflaeche_boxplot.R
Rscript oberflaeche_zeitverlauf.R
Rscript einstrahlung_zeitverlauf.R

# Nebenuntersuchung Wind
cd wind_sidequest
Rscript wind_mischung_strassenvergleich.R
Rscript wind_effekt_strahlungskontrolle.R
```

Die Grafiken werden nach `plots/` geschrieben, die Kennzahlen erscheinen in der Konsole und stehen
zusammengefasst in der jeweiligen `.md`-Datei neben dem Skript.

## Hinweise zur Methode

- Straßenzuordnung über `station_order`: 1 bis 4 begrünt, 5 bis 8 unbegrünt.
- Viele Auswertungen zeigen zwei Varianten: **alle acht Stationen** und eine **Auswahl (2, 4, 5, 7)**
  ohne die stark besonnten Stationen.
- Statistische Vergleiche laufen **gepaart pro Runde**, um Pseudoreplikation zu vermeiden.
- Details zu Daten, Spalten und Konventionen stehen in `CLAUDE.md`.
