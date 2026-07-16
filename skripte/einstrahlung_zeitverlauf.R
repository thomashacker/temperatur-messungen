#' Einstrahlung im Zeitverlauf: begrünte vs. unbegrünte Straße
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Zeigt, dass die Einstrahlung der unbegrünten Straße am 19.06. am frühen Nachmittag
#' plötzlich einbricht (durchziehende Wolke), was den 15-Uhr-Spike der Lufttemperatur
#' miterklärt. Gleiche Optik wie die Lufttemperatur-Grafik.
#' Zwei Varianten (alle Stationen und Auswahl 2, 4, 5, 7), analog zu den übrigen Skripten.
#' Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(lubridate)

# --- Daten laden ----------------------------------------------------------
Messkampagne <- readRDS("/Users/edwardschmuhl/Desktop/Work/Forks/Hannah_Abschlussbericht_Temperaturmessung_2026/CONTEXT/campaign_2026.rds")
Daten <- filter(Messkampagne$data, visit_status == "ok")

# --- Aufbereitung ---------------------------------------------------------
auswahl_stationen <- c(2, 4, 5, 7)
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")

# Alle gültigen Besuche mit Straßentyp, Zeit und Einstrahlung.
mess <- Daten %>%
  mutate(strasse = factor(if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
                          levels = names(farben_strasse)),
         zeit = beginn_local_parsed,
         ShortIn = humve_meteo_ShortIn_mean)

# --- Gemeinsame Achsen (aus ALLEN Stationen, damit beide Grafiken gleich sind) ---
# Tag-Rechtecke (05–22 Uhr je Kalendertag) über den vollen Zeitbereich.
tzone <- tz(mess$zeit)
tage  <- seq(as.Date(min(mess$zeit), tz = tzone),
             as.Date(max(mess$zeit), tz = tzone), by = "day")
tag_rechtecke <- tibble(
  xmin = as.POSIXct(paste(tage, "05:00:00"), tz = tzone),
  xmax = as.POSIXct(paste(tage, "22:00:00"), tz = tzone)
)
zeitbereich <- range(floor_date(mess$zeit, "hour"), na.rm = TRUE)
y_bereich   <- c(0, max(mess$ShortIn, na.rm = TRUE))   # gemeinsame y-Achse

# Zeitpunkt des Lufttemperatur-Spikes (19.06., 15 Uhr, Runde 22).
spike_zeit <- as.POSIXct("2026-06-19 15:00:00", tz = tzone)

# --- Plot-Funktion --------------------------------------------------------
# Linien = Stundenmittel je Straße (nur die geglätteten Linien, keine Einzelpunkte).
# Baut auf den gemeinsamen Achsen auf.
plotte_einstrahlung <- function(stationen, untertitel, dateiname) {
  df <- if (is.null(stationen)) mess else filter(mess, station_order %in% stationen)
  stunden <- df %>%
    mutate(stunde = floor_date(zeit, "hour")) %>%
    group_by(strasse, stunde) %>%
    summarise(ShortIn = mean(ShortIn, na.rm = TRUE), .groups = "drop")

  p <- ggplot() +
    geom_rect(data = tag_rechtecke,
              aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = "Tag"),
              alpha = 0.5) +
    geom_vline(xintercept = spike_zeit, linetype = "dashed", colour = "firebrick", linewidth = 0.6) +
    annotate("text", x = spike_zeit + 3600, y = 0.96 * y_bereich[2], hjust = 0,
             colour = "firebrick", size = 3.3,
             label = "Lufttemperatur-Spike\n(15 Uhr, Runde 22)") +
    geom_line(data = stunden, aes(stunde, ShortIn, colour = strasse), linewidth = 1) +
    geom_point(data = stunden, aes(stunde, ShortIn, colour = strasse), size = 1.8) +
    scale_fill_manual(name = NULL, values = c("Tag" = "lightyellow"), labels = "Tag (05–22 Uhr)") +
    scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
    scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
    scale_y_continuous(breaks = scales::breaks_width(100), minor_breaks = scales::breaks_width(50)) +
    coord_cartesian(xlim = zeitbereich, ylim = y_bereich) +
    labs(title = "Einstrahlung im Zeitverlauf", subtitle = untertitel,
         x = "Zeit", y = "Einstrahlung ShortIn (W/m²)",
         caption = "Linien: Stundenmittel je Straße. Hintergrund: hellgelb = Tag") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold"),
          plot.subtitle = element_text(colour = "grey40"),
          axis.title = element_text(size = 13), legend.position = "bottom")

  ggsave(paste0("../plots/", dateiname), p, width = 10, height = 5.5, dpi = 200, bg = "white")
}

# --- Beide Varianten erzeugen ---------------------------------------------
plotte_einstrahlung(NULL,
  "Alle Stationen; am 19.06. bricht die Einstrahlung der unbegrünten Straße nachmittags ein (Wolke)",
  "einstrahlung_zeitverlauf_alle.png")
plotte_einstrahlung(auswahl_stationen,
  "Auswahl 2, 4, 5, 7; am 19.06. bricht die Einstrahlung der unbegrünten Straße nachmittags ein (Wolke)",
  "einstrahlung_zeitverlauf_auswahl.png")

cat("FERTIG. Zwei Grafiken gespeichert in ../plots/ (einstrahlung_zeitverlauf_alle, _auswahl)\n")
