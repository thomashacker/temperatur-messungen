#' Oberflächentemperatur im Zeitverlauf: Boden und Wand, begrünt vs. unbegrünt
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Zwei Liniendiagramme (Boden und Wand) im Stil der Lufttemperatur-Grafik, je eine
#' Linie pro Straße, ganzer Zeitverlauf mit Tag/Nacht-Hintergrund.
#' Grundlage: Auswahl 2, 4, 5, 7. Autor: Hannah Balle

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
# Boden = Mittel der Punkte 1, 2, 3; Wand = Punkt 4. Stundenmittel je Straße.
auswahl_stationen <- c(2, 4, 5, 7)
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")

mess <- Daten %>%
  filter(station_order %in% auswahl_stationen) %>%
  mutate(
    strasse = factor(if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
                     levels = names(farben_strasse)),
    Boden   = rowMeans(cbind(manual_Ts_1, manual_Ts_2, manual_Ts_3), na.rm = TRUE),
    Wand    = manual_Ts_4,
    stunde  = floor_date(beginn_local_parsed, "hour")
  ) %>%
  select(stunde, strasse, Boden, Wand) %>%
  pivot_longer(c(Boden, Wand), names_to = "oberflaechentyp", values_to = "Ts") %>%
  filter(!is.na(Ts)) %>%
  group_by(oberflaechentyp, strasse, stunde) %>%
  summarise(Ts = mean(Ts, na.rm = TRUE), .groups = "drop")

# --- Tag-Rechtecke (05–22 Uhr je Kalendertag) -----------------------------
tzone <- tz(mess$stunde)
tage  <- seq(as.Date(min(mess$stunde), tz = tzone),
             as.Date(max(mess$stunde), tz = tzone), by = "day")
tag_rechtecke <- tibble(
  xmin = as.POSIXct(paste(tage, "05:00:00"), tz = tzone),
  xmax = as.POSIXct(paste(tage, "22:00:00"), tz = tzone)
)
zeitbereich <- range(mess$stunde, na.rm = TRUE)
# Gemeinsame y-Achse über Boden und Wand, damit beide Grafiken vergleichbar sind.
y_bereich <- range(mess$Ts, na.rm = TRUE)

# --- Plot-Funktion (wie Lufttemperatur-Grafik) ----------------------------
plotte_ts <- function(typ, titel) {
  df <- filter(mess, oberflaechentyp == typ)
  ggplot() +
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
    labs(title = titel, subtitle = "Auswahl 2, 4, 5, 7",
         x = "Zeit", y = "Oberflächentemperatur (°C)",
         caption = "Hintergrund: hellgelb = Tag, weiß = Nacht") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold"),
          plot.subtitle = element_text(colour = "grey40"),
          axis.title = element_text(size = 14), axis.text = element_text(size = 11),
          legend.position = "bottom")
}

# --- Beide Grafiken erzeugen und speichern --------------------------------
ggsave("../plots/oberflaeche_zeitverlauf_boden.png", plotte_ts("Boden", "Oberflächentemperatur Boden"),
       width = 10, height = 5.5, dpi = 200, bg = "white")
ggsave("../plots/oberflaeche_zeitverlauf_wand.png", plotte_ts("Wand", "Oberflächentemperatur Wand"),
       width = 10, height = 5.5, dpi = 200, bg = "white")

cat("FERTIG. Zwei Grafiken gespeichert in ../plots/ (oberflaeche_zeitverlauf_boden, _wand)\n")
