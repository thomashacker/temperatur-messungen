#' Lufttemperatur: Begrünte vs. unbegrünte Straße
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Vergleich der beiden Straßen einmal mit ALLEN Stationen und einmal mit einer
#' AUSWAHL, aus der die stark besonnten Stationen (1, 3, 6, 8) entfernt wurden.
#' Erzeugt zwei Grafiken (gleicher Stil/Farben wie das Vorbild) und alle Kennzahlen.
#' Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)

# --- Daten laden ----------------------------------------------------------
# Portabler Datenpfad: die Datei campaign_2026.rds liegt NICHT im Repository
# (siehe README.md, Abschnitt Setup). Suchreihenfolge: 1) Umgebungsvariable
# CAMPAIGN_RDS, 2) ein data/-Ordner im Repo, 3) der CONTEXT-Ordner neben dem
# Repo. Skripte werden aus ihrem eigenen Ordner ausgeführt (wie die ggsave-Pfade).
datenpfad <- Sys.getenv("CAMPAIGN_RDS", unset = NA)
if (is.na(datenpfad) || !file.exists(datenpfad)) {
  kandidaten <- c("data/campaign_2026.rds", "../data/campaign_2026.rds",
                  "../../data/campaign_2026.rds", "../CONTEXT/campaign_2026.rds",
                  "../../CONTEXT/campaign_2026.rds", "../../../CONTEXT/campaign_2026.rds")
  datenpfad <- kandidaten[file.exists(kandidaten)][1]
}
if (is.na(datenpfad)) stop("campaign_2026.rds nicht gefunden. Siehe README.md (Setup).")
Messkampagne <- readRDS(datenpfad)
Daten <- Messkampagne$data

# --- Aufbereitung ---------------------------------------------------------
# Nur gültige Stationsbesuche verwenden (die 3 "missing_visit" fallen raus).
Daten <- filter(Daten, visit_status == "ok")

# Straßentyp aus der Stationsnummer ableiten:
# station_order 1–4 = begrünte Straße (Husemann), 5–8 = unbegrünte Straße (Hagenauer).
Daten <- Daten %>%
  mutate(strasse = case_when(
    station_order %in% 1:4 ~ "Begrünte Straße",
    station_order %in% 5:8 ~ "Unbegrünte Straße"
  ))

# Stationen, die stark der Sonne ausgesetzt waren und in der Auswahl entfallen.
# Übrig bleiben die repräsentativeren Stationen 2, 4, 5, 7.
auswahl_stationen <- c(2, 4, 5, 7)

# =========================================================================
#  TEIL A — GRAFIKEN (stündliche Mittelwerte je Straße)
# =========================================================================

# --- Stündliche Aggregation je Straße -------------------------------------
# Mittelt die Lufttemperatur pro Stunde je Straßentyp; optional nur auf
# ausgewählte station_order-Werte gefiltert (NULL = alle Stationen).
aggregiere_ta <- function(df, stationen = NULL) {
  if (!is.null(stationen)) df <- filter(df, station_order %in% stationen)
  df %>%
    mutate(stunde = floor_date(beginn_local_parsed, "hour")) %>%
    group_by(strasse, stunde) %>%
    summarise(Ta_mittel = mean(humve_meteo_Ta_mean, na.rm = TRUE), .groups = "drop")
}

Temp_alle    <- aggregiere_ta(Daten)
Temp_auswahl <- aggregiere_ta(Daten, auswahl_stationen)

# --- Tag-Rechtecke (05–22 Uhr je Kalendertag) -----------------------------
# Aus dem vollen Zeitbereich berechnet, damit beide Grafiken dieselbe x-Achse haben.
tzone <- tz(Temp_alle$stunde)
tage  <- seq(as.Date(min(Temp_alle$stunde), tz = tzone),
             as.Date(max(Temp_alle$stunde), tz = tzone), by = "day")
tag_rechtecke <- tibble(
  xmin = as.POSIXct(paste(tage, "05:00:00"), tz = tzone),
  xmax = as.POSIXct(paste(tage, "22:00:00"), tz = tzone)
)
zeitbereich <- range(Temp_alle$stunde, na.rm = TRUE)

# --- Gemeinsamer y-Bereich ------------------------------------------------
# Über beide Datensätze berechnet, damit die Temperaturachse identisch ist.
y_bereich <- range(c(Temp_alle$Ta_mittel, Temp_auswahl$Ta_mittel), na.rm = TRUE)

# --- Plot-Funktion (Linien + Punkte, Tag/Nacht-Hintergrund) ---------------
plotte_ta <- function(df, titel) {
  ggplot() +
    geom_rect(data = tag_rechtecke,
              aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = "Tag"),
              alpha = 0.5) +
    geom_line(data = df, aes(stunde, Ta_mittel, colour = strasse), linewidth = 1) +
    geom_point(data = df, aes(stunde, Ta_mittel, colour = strasse), size = 1.8) +
    scale_fill_manual(name = NULL, values = c("Tag" = "lightyellow"),
                      labels = "Tag (05–22 Uhr)") +
    scale_colour_manual(name = "Straßentyp",
                        values = c("Begrünte Straße"   = "forestgreen",
                                   "Unbegrünte Straße" = "gray60")) +
    scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
    scale_y_continuous(breaks = scales::breaks_width(2),
                       minor_breaks = scales::breaks_width(1)) +
    coord_cartesian(xlim = zeitbereich, ylim = y_bereich) +
    labs(title = titel, x = "Zeit", y = "Lufttemperatur (°C)",
         caption = "Hintergrund: hellgelb = Tag, weiß = Nacht") +
    theme_minimal() +
    theme(axis.title = element_text(size = 14), axis.text = element_text(size = 11))
}

plot_alle    <- plotte_ta(Temp_alle,    "Alle Stationen")
plot_auswahl <- plotte_ta(Temp_auswahl, "Auswahl: Stationen 2, 4, 5, 7 (ohne stark besonnte)")

# --- Grafiken speichern ---------------------------------------------------
ggsave("../plots/lufttemperatur_alle_stationen.png", plot_alle,
       width = 9, height = 5, dpi = 150, bg = "white")
ggsave("../plots/lufttemperatur_auswahl_stationen.png", plot_auswahl,
       width = 9, height = 5, dpi = 150, bg = "white")

# =========================================================================
#  TEIL B — STATISTIK
# =========================================================================

# --- Hilfsfunktion: deskriptive Kennzahlen je Vektor ----------------------
kennzahlen <- function(x) {
  tibble(
    n          = sum(!is.na(x)),
    min        = round(min(x, na.rm = TRUE), 2),
    max        = round(max(x, na.rm = TRUE), 2),
    mittelwert = round(mean(x, na.rm = TRUE), 2),
    median     = round(median(x, na.rm = TRUE), 2),
    sd         = round(sd(x, na.rm = TRUE), 2),
    IQR        = round(IQR(x, na.rm = TRUE), 2),
    spannweite = round(max(x, na.rm = TRUE) - min(x, na.rm = TRUE), 2)
  )
}

# --- Hilfsfunktion: Anzahl Ausreißer nach der 1,5·IQR-Regel ---------------
# Werte unterhalb Q25 - 1,5·IQR oder oberhalb Q75 + 1,5·IQR gelten als Ausreißer.
ausreisser_anzahl <- function(x) {
  q <- quantile(x, c(0.25, 0.75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  sum(x < q[1] - 1.5 * iqr | x > q[2] + 1.5 * iqr, na.rm = TRUE)
}

# --- Mittlere Differenz auf den STUNDENMITTELN (passend zur Grafik) --------
# Unbegrünt minus begrünt; positiv = unbegrünte Straße wärmer (Baumstraße kühler).
mittlere_differenz_stunde <- function(temp) {
  temp %>%
    pivot_wider(names_from = strasse, values_from = Ta_mittel) %>%
    summarise(diff = mean(`Unbegrünte Straße` - `Begrünte Straße`, na.rm = TRUE)) %>%
    pull(diff)
}

# --- Paarung pro Runde (methodisch ehrlicher, gegen Pseudoreplikation) -----
# Je Runde ein Mittelwert pro Straße -> die 40 Runden sind die Vergleichseinheiten.
paar_pro_runde <- function(df, stationen = NULL) {
  if (!is.null(stationen)) df <- filter(df, station_order %in% stationen)
  df %>%
    group_by(round_no, strasse) %>%
    summarise(m = mean(humve_meteo_Ta_mean, na.rm = TRUE), .groups = "drop") %>%
    pivot_wider(names_from = strasse, values_from = m)
}

# -------------------------------------------------------------------------
#  TEIL B1 — Alle Stationen vs. Auswahl: warum die Auswahl sinnvoller ist
# -------------------------------------------------------------------------
Daten_auswahl <- filter(Daten, station_order %in% auswahl_stationen)

cat("### TEIL B1: ALLE STATIONEN vs. AUSWAHL ###\n\n")

cat("== Kennzahlen je Straße — ALLE Stationen (Rohwerte je Besuch) ==\n")
kennz_alle_roh <- Daten %>% group_by(strasse) %>% reframe(kennzahlen(humve_meteo_Ta_mean))
print(kennz_alle_roh)

cat("\n== Kennzahlen je Straße — AUSWAHL 2,4,5,7 (Rohwerte je Besuch) ==\n")
kennz_auswahl_roh <- Daten_auswahl %>% group_by(strasse) %>% reframe(kennzahlen(humve_meteo_Ta_mean))
print(kennz_auswahl_roh)

cat("\n== Ausreißer (1,5·IQR-Regel) je Straße ==\n")
ausreisser_tab <- bind_rows(
  Daten         %>% group_by(strasse) %>% summarise(datensatz = "alle",    ausreisser = ausreisser_anzahl(humve_meteo_Ta_mean), n = sum(!is.na(humve_meteo_Ta_mean)), .groups = "drop"),
  Daten_auswahl %>% group_by(strasse) %>% summarise(datensatz = "auswahl", ausreisser = ausreisser_anzahl(humve_meteo_Ta_mean), n = sum(!is.na(humve_meteo_Ta_mean)), .groups = "drop")
)
print(ausreisser_tab)

cat("\n== Mittlere Differenz (unbegrünt - begrünt), Stundenmittel ==\n")
cat(sprintf("  ALLE Stationen : %+.3f °C\n", mittlere_differenz_stunde(Temp_alle)))
cat(sprintf("  AUSWAHL 2,4,5,7: %+.3f °C\n", mittlere_differenz_stunde(Temp_auswahl)))

# -------------------------------------------------------------------------
#  TEIL B2 — Statistik nur auf der Auswahl
# -------------------------------------------------------------------------
cat("\n\n### TEIL B2: STATISTIK NUR AUF DER AUSWAHL (2,4,5,7) ###\n\n")

cat("== Deskriptive Kennzahlen je Straße ==\n")
print(kennz_auswahl_roh)

# Gepaarter t-Test pro Runde
paar_auswahl <- paar_pro_runde(Daten, auswahl_stationen)
diff_auswahl <- paar_auswahl$`Unbegrünte Straße` - paar_auswahl$`Begrünte Straße`

cat(sprintf("\nMittlere Differenz pro Runde (unbegrünt - begrünt): %+.3f °C  (n = %d Runden)\n",
            mean(diff_auswahl, na.rm = TRUE), sum(!is.na(diff_auswahl))))

cat("\n== Gepaarter t-Test pro Runde (Auswahl) ==\n")
tt_auswahl <- t.test(paar_auswahl$`Unbegrünte Straße`, paar_auswahl$`Begrünte Straße`, paired = TRUE)
print(tt_auswahl)

cat("\n== Wilcoxon-Test (gepaart, Absicherung) ==\n")
wt_auswahl <- wilcox.test(paar_auswahl$`Unbegrünte Straße`, paar_auswahl$`Begrünte Straße`, paired = TRUE)
print(wt_auswahl)

# Zum Vergleich: gepaarter t-Test auf ALLEN Stationen
cat("\n== Zum Vergleich: gepaarter t-Test pro Runde (ALLE Stationen) ==\n")
paar_alle <- paar_pro_runde(Daten)
tt_alle <- t.test(paar_alle$`Unbegrünte Straße`, paar_alle$`Begrünte Straße`, paired = TRUE)
print(tt_alle)

cat("\nFERTIG. Grafiken gespeichert in ../plots/\n")
