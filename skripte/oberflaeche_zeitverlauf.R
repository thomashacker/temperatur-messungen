#' Oberflächentemperatur im Zeitverlauf: Boden und Wand, begrünt vs. unbegrünt
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Liniendiagramme (Boden und Wand) im Stil der Lufttemperatur-Grafik, je eine
#' Linie pro Straße, ganzer Zeitverlauf mit Tag/Nacht-Hintergrund.
#' Zwei Varianten (alle Stationen und Auswahl 2, 4, 5, 7), analog zu den übrigen
#' Skripten. Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

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
Daten <- filter(Messkampagne$data, visit_status == "ok")

# --- Aufbereitung ---------------------------------------------------------
# Straßentyp aus der Stationsnummer, Oberflächentyp aus den Handmessungen:
# Boden = Mittel der Punkte 1, 2, 3; Wand = Punkt 4.
auswahl_stationen <- c(2, 4, 5, 7)
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")

# Alle gültigen Besuche mit Straßentyp, Boden, Wand und Stunde.
besuche <- Daten %>%
  mutate(
    strasse = factor(if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
                     levels = names(farben_strasse)),
    Boden   = rowMeans(cbind(manual_Ts_1, manual_Ts_2, manual_Ts_3), na.rm = TRUE),
    Wand    = manual_Ts_4,
    stunde  = floor_date(beginn_local_parsed, "hour")
  ) %>%
  select(station_order, stunde, strasse, Boden, Wand)

# Stundenmittel je Straße für eine Stationsauswahl (NULL = alle Stationen).
stundenmittel <- function(stationen = NULL) {
  df <- if (is.null(stationen)) besuche else filter(besuche, station_order %in% stationen)
  df %>%
    pivot_longer(c(Boden, Wand), names_to = "oberflaechentyp", values_to = "Ts") %>%
    filter(!is.na(Ts)) %>%
    group_by(oberflaechentyp, strasse, stunde) %>%
    summarise(Ts = mean(Ts, na.rm = TRUE), .groups = "drop")
}

mess_alle    <- stundenmittel(NULL)
mess_auswahl <- stundenmittel(auswahl_stationen)

# --- Gemeinsame Achsen (aus beiden Varianten) -----------------------------
# Tag-Rechtecke (05–22 Uhr je Kalendertag) über den vollen Zeitbereich.
alle_stunden <- c(mess_alle$stunde, mess_auswahl$stunde)
tzone <- tz(alle_stunden)
tage  <- seq(as.Date(min(alle_stunden), tz = tzone),
             as.Date(max(alle_stunden), tz = tzone), by = "day")
tag_rechtecke <- tibble(
  xmin = as.POSIXct(paste(tage, "05:00:00"), tz = tzone),
  xmax = as.POSIXct(paste(tage, "22:00:00"), tz = tzone)
)
zeitbereich <- range(alle_stunden, na.rm = TRUE)
# Gemeinsame y-Achse über beide Varianten und beide Oberflächentypen.
y_bereich <- range(c(mess_alle$Ts, mess_auswahl$Ts), na.rm = TRUE)

# --- Plot-Funktion (wie Lufttemperatur-Grafik) ----------------------------
plotte_ts <- function(daten, typ, titel, untertitel, dateiname) {
  df <- filter(daten, oberflaechentyp == typ)
  p <- ggplot() +
    geom_rect(data = tag_rechtecke,
              aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = "Tag"),
              alpha = 0.5) +
    geom_line(data = df, aes(stunde, Ts, colour = strasse), linewidth = 1) +
    geom_point(data = df, aes(stunde, Ts, colour = strasse), size = 1.8) +
    scale_fill_manual(name = NULL, values = c("Tag" = "lightyellow"),
                      labels = "Tag (05–22 Uhr)") +
    scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
    scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
    scale_y_continuous(breaks = scales::breaks_width(2), minor_breaks = scales::breaks_width(1)) +
    coord_cartesian(xlim = zeitbereich, ylim = y_bereich) +
    labs(title = titel, subtitle = untertitel,
         x = "Zeit", y = "Oberflächentemperatur (°C)",
         caption = "Hintergrund: hellgelb = Tag, weiß = Nacht") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold"),
          plot.subtitle = element_text(colour = "grey40"),
          axis.title = element_text(size = 14), axis.text = element_text(size = 11),
          legend.position = "bottom")
  ggsave(paste0("../plots/", dateiname), p, width = 10, height = 5.5, dpi = 200, bg = "white")
}

# --- Vier Grafiken erzeugen (Boden/Wand x alle/Auswahl) -------------------
plotte_ts(mess_alle,    "Boden", "Oberflächentemperatur Boden", "Alle Stationen",
          "oberflaeche_zeitverlauf_boden_alle.png")
plotte_ts(mess_alle,    "Wand",  "Oberflächentemperatur Wand",  "Alle Stationen",
          "oberflaeche_zeitverlauf_wand_alle.png")
plotte_ts(mess_auswahl, "Boden", "Oberflächentemperatur Boden", "Auswahl 2, 4, 5, 7",
          "oberflaeche_zeitverlauf_boden_auswahl.png")
plotte_ts(mess_auswahl, "Wand",  "Oberflächentemperatur Wand",  "Auswahl 2, 4, 5, 7",
          "oberflaeche_zeitverlauf_wand_auswahl.png")

cat("FERTIG. Vier Grafiken gespeichert in ../plots/ (oberflaeche_zeitverlauf_{boden,wand}_{alle,auswahl})\n")
