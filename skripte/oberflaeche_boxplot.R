#' Oberflächentemperatur: Boden vs. Wand, begrünte vs. unbegrünte Straße
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Boxplots der Oberflächentemperatur je Oberflächentyp (Boden/Wand) und Straße,
#' aufgeteilt nach Stationsauswahl (alle vs. 2,4,5,7) und Tageszeit (Gesamt/Tag/Nacht).
#' Prüft die Hypothese: Die Oberflächentemperatur der begrünten Straße ist tagsüber
#' niedriger als die der unbegrünten Straße.
#' Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

# --- Daten laden ----------------------------------------------------------
Messkampagne <- readRDS("/Users/edwardschmuhl/Desktop/Work/Forks/Hannah_Abschlussbericht_Temperaturmessung_2026/CONTEXT/campaign_2026.rds")
Daten <- filter(Messkampagne$data, visit_status == "ok")

# --- Aufbereitung (Werte je Besuch) ---------------------------------------
# Straßentyp aus der Stationsnummer: 1–4 begrünt (Husemann), 5–8 unbegrünt (Hagenauer).
# Oberflächentyp aus den vier Handmessungen:
#   Boden = Mittel der Punkte 1, 2, 3 (manual_Ts_1..3), Wand = Punkt 4 (manual_Ts_4).
# Je Besuch entsteht so EIN Boden- und EIN Wandwert.
besuche <- Daten %>%
  mutate(
    strasse = if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
    Boden   = rowMeans(cbind(manual_Ts_1, manual_Ts_2, manual_Ts_3), na.rm = TRUE),
    Boden   = if_else(is.nan(Boden), NA_real_, Boden),
    Wand    = manual_Ts_4,
    zeit    = beginn_local_parsed
  ) %>%
  select(round_no, station_order, strasse, zeit, Boden, Wand)

# Auswahl der stark besonnten Stationen ausschließen -> übrig: 2, 4, 5, 7.
auswahl_stationen <- c(2, 4, 5, 7)

# --- Aggregation auf RUNDENEBENE ------------------------------------------
# Kernentscheidung: pro Runde und Straße werden die Stationen zu EINEM Wert
# gemittelt. Damit ist die Runde die Beobachtungseinheit (n = 40 je Straße),
# nicht der Einzelbesuch. Das vermeidet Pseudoreplikation (die 2–4 Stationen
# einer Straße in derselben Runde sind keine unabhängigen Messungen) und ist
# konsistent mit dem gepaarten t-Test weiter unten.
aggregiere_runde <- function(df) {
  df %>%
    group_by(round_no, strasse) %>%
    summarise(
      Boden = mean(Boden, na.rm = TRUE),
      Wand  = mean(Wand,  na.rm = TRUE),
      zeit  = mean(zeit),                       # mittlere Uhrzeit der Runde/Straße
      .groups = "drop"
    ) %>%
    mutate(
      across(c(Boden, Wand), ~ if_else(is.nan(.), NA_real_, .)),
      stunde    = hour(zeit),
      tageszeit = if_else(stunde >= 5 & stunde < 22, "Tag", "Nacht")   # Tag = 05–22 Uhr
    ) %>%
    pivot_longer(c(Boden, Wand), names_to = "oberflaechentyp", values_to = "Ts") %>%
    filter(!is.na(Ts))
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

# Reihenfolge der Kategorien festlegen (für saubere Achsen/Facetten).
plot_df <- plot_df %>%
  mutate(
    oberflaechentyp = factor(oberflaechentyp, levels = c("Boden", "Wand")),
    strasse         = factor(strasse, levels = c("Begrünte Straße", "Unbegrünte Straße")),
    stationsset     = factor(stationsset, levels = c("Alle Stationen", "Auswahl 2, 4, 5, 7")),
    zeitfenster     = factor(zeitfenster,
                             levels = c("Gesamt", "Tag (05–22 Uhr)", "Nacht (22–05 Uhr)"))
  )

# =========================================================================
#  GRAFIK — sechs einzelne Boxplot-Dateien
# =========================================================================
# Gemeinsame y-Achse über alle sechs Grafiken, damit sie direkt vergleichbar sind.
y_grenzen <- range(plot_df$Ts, na.rm = TRUE)

# Funktion: erzeugt und speichert EIN Boxplot-Feld als eigene PNG-Datei.
# Der Haupttitel ist kurz und fest, der Untertitel nennt Stationsauswahl und Tageszeit.
speichere_boxplot <- function(daten, untertitel, dateiname) {
  p <- ggplot(daten, aes(x = oberflaechentyp, y = Ts, fill = strasse)) +
    geom_boxplot(position = position_dodge(width = 0.8),
                 outlier.size = 0.8, alpha = 0.9, linewidth = 0.4) +
    scale_fill_manual(name = "Straßentyp",
                      values = c("Begrünte Straße"   = "forestgreen",
                                 "Unbegrünte Straße" = "gray60")) +
    # Feineres y-Raster: beschriftete Hauptlinien alle 5 °C, feine Hilfslinien alle 1 °C.
    scale_y_continuous(breaks = scales::breaks_width(5),
                       minor_breaks = scales::breaks_width(1)) +
    coord_cartesian(ylim = y_grenzen) +
    labs(title = "Oberflächentemperatur: Boden vs. Wand",
         subtitle = untertitel,
         x = "Oberflächentyp", y = "Oberflächentemperatur (°C)",
         caption = "Ein Wert je Messrunde und Straße (Stationen gemittelt), n = 40 je Straße") +
    theme_minimal(base_size = 13) +
    theme(plot.title = element_text(face = "bold"),
          plot.subtitle = element_text(colour = "grey40"),
          legend.position = "bottom",
          panel.grid.major.y = element_line(colour = "grey85"),
          panel.grid.minor.y = element_line(colour = "grey92", linewidth = 0.3))
  ggsave(paste0("../plots/", dateiname), p, width = 6.5, height = 5, dpi = 200, bg = "white")
}

# Die sechs Kombinationen: (Stationsauswahl) x (Tageszeit), je eine eigene Datei.
kombis <- list(
  list(ss = "Alle Stationen",     zf = "Gesamt",            datei = "oberflaeche_boxplot_alle_gesamt.png"),
  list(ss = "Alle Stationen",     zf = "Tag (05–22 Uhr)",   datei = "oberflaeche_boxplot_alle_tag.png"),
  list(ss = "Alle Stationen",     zf = "Nacht (22–05 Uhr)", datei = "oberflaeche_boxplot_alle_nacht.png"),
  list(ss = "Auswahl 2, 4, 5, 7", zf = "Gesamt",            datei = "oberflaeche_boxplot_auswahl_gesamt.png"),
  list(ss = "Auswahl 2, 4, 5, 7", zf = "Tag (05–22 Uhr)",   datei = "oberflaeche_boxplot_auswahl_tag.png"),
  list(ss = "Auswahl 2, 4, 5, 7", zf = "Nacht (22–05 Uhr)", datei = "oberflaeche_boxplot_auswahl_nacht.png")
)

for (k in kombis) {
  daten_feld <- filter(plot_df, stationsset == k$ss, zeitfenster == k$zf)
  untertitel <- paste0(k$ss, ", ", k$zf)
  speichere_boxplot(daten_feld, untertitel, k$datei)
}

# =========================================================================
#  STATISTIK
# =========================================================================

# --- Mittlere Differenz: wie viel kühler ist die begrünte Straße? ---------
# Konvention: unbegrünt minus begrünt; positiv = begrünte Straße kühler.
differenz_tab <- plot_df %>%
  group_by(stationsset, zeitfenster, oberflaechentyp, strasse) %>%
  summarise(mittel = mean(Ts), .groups = "drop") %>%
  pivot_wider(names_from = strasse, values_from = mittel) %>%
  mutate(differenz = round(`Unbegrünte Straße` - `Begrünte Straße`, 2),
         `Begrünte Straße` = round(`Begrünte Straße`, 2),
         `Unbegrünte Straße` = round(`Unbegrünte Straße`, 2))

cat("### Mittlere Oberflächentemperatur je Gruppe und Differenz (kühler = positiv) ###\n")
print(as.data.frame(differenz_tab), row.names = FALSE)

# --- Deskriptive Kennzahlen je Gruppe -------------------------------------
# Vollständige Kennzahlen (Median und Co.) je Oberflächentyp und Straße.
# Q25/Q75 = unteres/oberes Viertel, IQR = deren Abstand (Streuung der mittleren 50 %).
kennz_tab <- plot_df %>%
  group_by(stationsset, zeitfenster, oberflaechentyp, strasse) %>%
  summarise(n = n(),
            min = round(min(Ts), 1),
            Q25 = round(quantile(Ts, 0.25), 1),
            median = round(median(Ts), 1),
            mittel = round(mean(Ts), 1),
            Q75 = round(quantile(Ts, 0.75), 1),
            max = round(max(Ts), 1),
            sd = round(sd(Ts), 2),
            IQR = round(IQR(Ts), 1),
            .groups = "drop")
cat("\n### Deskriptive Kennzahlen je Gruppe (Median und Co.) ###\n")
print(as.data.frame(kennz_tab), row.names = FALSE)

# --- Gepaarter t-Test pro Runde für die Kernhypothese (Tag) ---------------
# Getestet wird je Oberflächentyp auf der Auswahl, tagsüber: unbegrünt vs. begrünt.
# Die Daten liegen bereits auf Rundenebene vor, je Runde ein Paar (beide Straßen).
paar_test <- function(df) {
  w <- df %>%
    select(round_no, strasse, Ts) %>%
    pivot_wider(names_from = strasse, values_from = Ts)
  t.test(w$`Unbegrünte Straße`, w$`Begrünte Straße`, paired = TRUE)
}

tag_auswahl <- filter(plot_df, stationsset == "Auswahl 2, 4, 5, 7",
                      zeitfenster == "Tag (05–22 Uhr)")

cat("\n### Gepaarter t-Test pro Runde, TAG, Auswahl 2,4,5,7 ###\n")
cat("\n-- Boden --\n"); print(paar_test(filter(tag_auswahl, oberflaechentyp == "Boden")))
cat("\n-- Wand --\n");  print(paar_test(filter(tag_auswahl, oberflaechentyp == "Wand")))

cat("\nFERTIG. Sechs Grafiken gespeichert in ../plots/ (oberflaeche_boxplot_*.png)\n")
