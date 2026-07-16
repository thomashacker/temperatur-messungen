#' Lufttemperatur: begrünte vs. unbegrünte Straße (Boxplots)
#' Boxplots je Straße nach Stationsauswahl (alle vs. 2,4,5,7) und Tageszeit (Gesamt/Tag/Nacht).
#' Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

# --- Pfade (bei Bedarf anpassen) ---
datenpfad <- "../../CONTEXT/campaign_2026.rds"  # Kampagnendatei
plotpfad  <- "../plots/"                        # Zielordner der Grafiken

Messkampagne <- readRDS(datenpfad)
Daten <- filter(Messkampagne$data, visit_status == "ok")

# --- Aufbereitung (Werte je Besuch) ---------------------------------------
# Straßentyp aus der Stationsnummer: 1–4 begrünt (Husemann), 5–8 unbegrünt (Hagenauer).
# Lufttemperatur aus der mobilen Messung humve_meteo_Ta_mean (ein Wert je Besuch).
besuche <- Daten %>%
  mutate(
    strasse = if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
    Ta      = humve_meteo_Ta_mean,
    zeit    = beginn_local_parsed
  ) %>%
  select(round_no, station_order, strasse, zeit, Ta)

# Auswahl der stark besonnten Stationen ausschließen -> übrig: 2, 4, 5, 7.
auswahl_stationen <- c(2, 4, 5, 7)

# --- Aggregation auf Rundenebene ------------------------------------------
# Pro Runde und Straße die Stationen zu einem Wert mitteln; Runde = Beobachtungseinheit
# (n = 40 je Straße), vermeidet Pseudoreplikation und passt zum gepaarten t-Test.
aggregiere_runde <- function(df) {
  df %>%
    group_by(round_no, strasse) %>%
    summarise(
      Ta   = mean(Ta, na.rm = TRUE),
      zeit = mean(zeit),                          # mittlere Uhrzeit der Runde/Straße
      .groups = "drop"
    ) %>%
    mutate(
      Ta        = if_else(is.nan(Ta), NA_real_, Ta),
      stunde    = hour(zeit),
      tageszeit = if_else(stunde >= 5 & stunde < 22, "Tag", "Nacht")   # Tag = 05–22 Uhr
    ) %>%
    filter(!is.na(Ta))
}

# --- Datensatz für die Facetten aufspannen --------------------------------
# Zwei Dimensionen: (alle Stationen | Auswahl) x (Gesamt | Tag | Nacht).
mit_stationsset <- bind_rows(
  aggregiere_runde(besuche) %>% mutate(stationsset = "Alle Stationen"),
  aggregiere_runde(filter(besuche, station_order %in% auswahl_stationen)) %>%
    mutate(stationsset = "Auswahl 2, 4, 5, 7")
)

plot_df <- bind_rows(
  mit_stationsset %>% mutate(zeitfenster = "Gesamt"),
  mit_stationsset %>% filter(tageszeit == "Tag")   %>% mutate(zeitfenster = "Tag (05–22 Uhr)"),
  mit_stationsset %>% filter(tageszeit == "Nacht") %>% mutate(zeitfenster = "Nacht (22–05 Uhr)")
)

plot_df <- plot_df %>%
  mutate(
    strasse     = factor(strasse, levels = c("Begrünte Straße", "Unbegrünte Straße")),
    stationsset = factor(stationsset, levels = c("Alle Stationen", "Auswahl 2, 4, 5, 7")),
    zeitfenster = factor(zeitfenster,
                         levels = c("Gesamt", "Tag (05–22 Uhr)", "Nacht (22–05 Uhr)"))
  )

# --- Grafik: sechs einzelne Boxplot-Dateien ---
# Gemeinsame y-Achse über alle sechs Grafiken, damit sie direkt vergleichbar sind.
y_grenzen <- range(plot_df$Ta, na.rm = TRUE)
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")

# Erzeugt und speichert ein Boxplot-Feld als eigene PNG-Datei.
speichere_boxplot <- function(daten, untertitel, dateiname) {
  p <- ggplot(daten, aes(x = strasse, y = Ta, fill = strasse)) +
    geom_boxplot(width = 0.6, outlier.size = 0.8, alpha = 0.9, linewidth = 0.4) +
    scale_fill_manual(name = "Straßentyp", values = farben_strasse) +
    scale_y_continuous(breaks = scales::breaks_width(2), minor_breaks = scales::breaks_width(1)) +
    coord_cartesian(ylim = y_grenzen) +
    labs(title = "Lufttemperatur: begrünte vs. unbegrünte Straße",
         subtitle = untertitel,
         x = "Straßentyp", y = "Lufttemperatur (°C)",
         caption = "Ein Wert je Messrunde und Straße (Stationen gemittelt), n = 40 je Straße") +
    theme_minimal(base_size = 13) +
    theme(plot.title = element_text(face = "bold"),
          plot.subtitle = element_text(colour = "grey40"),
          legend.position = "bottom",
          panel.grid.major.y = element_line(colour = "grey85"),
          panel.grid.minor.y = element_line(colour = "grey92", linewidth = 0.3))
  ggsave(paste0(plotpfad, dateiname), p, width = 6.5, height = 5, dpi = 200, bg = "white")
}

# Die sechs Kombinationen: (Stationsauswahl) x (Tageszeit), je eine eigene Datei.
kombis <- list(
  list(ss = "Alle Stationen",     zf = "Gesamt",            datei = "lufttemperatur_boxplot_alle_gesamt.png"),
  list(ss = "Alle Stationen",     zf = "Tag (05–22 Uhr)",   datei = "lufttemperatur_boxplot_alle_tag.png"),
  list(ss = "Alle Stationen",     zf = "Nacht (22–05 Uhr)", datei = "lufttemperatur_boxplot_alle_nacht.png"),
  list(ss = "Auswahl 2, 4, 5, 7", zf = "Gesamt",            datei = "lufttemperatur_boxplot_auswahl_gesamt.png"),
  list(ss = "Auswahl 2, 4, 5, 7", zf = "Tag (05–22 Uhr)",   datei = "lufttemperatur_boxplot_auswahl_tag.png"),
  list(ss = "Auswahl 2, 4, 5, 7", zf = "Nacht (22–05 Uhr)", datei = "lufttemperatur_boxplot_auswahl_nacht.png")
)

for (k in kombis) {
  daten_feld <- filter(plot_df, stationsset == k$ss, zeitfenster == k$zf)
  untertitel <- paste0(k$ss, ", ", k$zf)
  speichere_boxplot(daten_feld, untertitel, k$datei)
}

# --- Statistik ---

# Mittlere Differenz: unbegrünt minus begrünt (positiv = begrünte Straße kühler).
differenz_tab <- plot_df %>%
  group_by(stationsset, zeitfenster, strasse) %>%
  summarise(mittel = mean(Ta), .groups = "drop") %>%
  pivot_wider(names_from = strasse, values_from = mittel) %>%
  mutate(differenz = round(`Unbegrünte Straße` - `Begrünte Straße`, 2),
         `Begrünte Straße` = round(`Begrünte Straße`, 2),
         `Unbegrünte Straße` = round(`Unbegrünte Straße`, 2))

cat("### Mittlere Lufttemperatur je Gruppe und Differenz (kühler = positiv) ###\n")
print(as.data.frame(differenz_tab), row.names = FALSE)

# --- Deskriptive Kennzahlen je Gruppe (Median und Co.) --------------------
kennz_tab <- plot_df %>%
  group_by(stationsset, zeitfenster, strasse) %>%
  summarise(n = n(),
            min = round(min(Ta), 1),
            Q25 = round(quantile(Ta, 0.25), 1),
            median = round(median(Ta), 1),
            mittel = round(mean(Ta), 1),
            Q75 = round(quantile(Ta, 0.75), 1),
            max = round(max(Ta), 1),
            sd = round(sd(Ta), 2),
            IQR = round(IQR(Ta), 1),
            .groups = "drop")
cat("\n### Deskriptive Kennzahlen je Gruppe (Median und Co.) ###\n")
print(as.data.frame(kennz_tab), row.names = FALSE)

# --- Gepaarter t-Test pro Runde, Auswahl 2,4,5,7 (je Runde ein Paar, unbegrünt vs. begrünt) ---
paar_test <- function(df) {
  w <- df %>% select(round_no, strasse, Ta) %>%
    pivot_wider(names_from = strasse, values_from = Ta)
  t.test(w$`Unbegrünte Straße`, w$`Begrünte Straße`, paired = TRUE)
}

cat("\n### Gepaarter t-Test pro Runde, Auswahl 2,4,5,7 ###\n")
for (zf in c("Gesamt", "Tag (05–22 Uhr)", "Nacht (22–05 Uhr)")) {
  cat("\n--", zf, "--\n")
  print(paar_test(filter(plot_df, stationsset == "Auswahl 2, 4, 5, 7", zeitfenster == zf)))
}

cat("\nFERTIG. Sechs Grafiken gespeichert in ../plots/ (lufttemperatur_boxplot_*.png)\n")
