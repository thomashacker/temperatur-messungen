#' Wind und Durchmischung: begrünte vs. unbegrünte Straße
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Untersucht die Hypothese, dass die begrünte Straße windstiller und schlechter
#' durchmischt ist und deshalb die Luftkühlung gedämpft wird.
#' Grundlage: Auswahl 2, 4, 5, 7 (ohne stark besonnte Stationen).
#' Erzeugt drei Grafiken plus Kennzahlen. Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

# --- Daten laden ----------------------------------------------------------
Messkampagne <- readRDS("/Users/edwardschmuhl/Desktop/Work/Forks/Hannah_Abschlussbericht_Temperaturmessung_2026/CONTEXT/campaign_2026.rds")
Daten <- filter(Messkampagne$data, visit_status == "ok")

# --- Aufbereitung ---------------------------------------------------------
# Straßentyp, Uhrzeit, Tag/Nacht, Auswahl der Stationen und Mischungskennzahlen.
# TKE (turbulente kinetische Energie) = 0,5 * (Var_u + Var_v + Var_w), ein Maß für
# die Gesamtdurchmischung. Cov_wTv ist der turbulente Wärmefluss nach oben.
auswahl_stationen <- c(2, 4, 5, 7)

daten_auf <- Daten %>%
  mutate(
    strasse = if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
    stunde  = hour(beginn_local_parsed),
    tageszeit = if_else(stunde >= 5 & stunde < 22, "Tag", "Nacht"),
    wind = humve_wind_wind_speed_gill_mean,
    TKE  = 0.5 * (humve_gill_Var_u_variance + humve_gill_Var_v_variance + humve_gill_Var_w_variance),
    Var_w = humve_gill_Var_w_variance,
    Waermefluss = humve_gill_Cov_wTv_covariance
  )

sel <- filter(daten_auf, station_order %in% auswahl_stationen)

# Farben und Reihenfolge wie in den übrigen Grafiken.
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")
sel$strasse <- factor(sel$strasse, levels = names(farben_strasse))

# Hilfsband: Tag (05–22 Uhr) als hellgelber Hintergrund im Tagesgang.
tag_band <- annotate("rect", xmin = 5, xmax = 22, ymin = -Inf, ymax = Inf,
                     fill = "lightyellow", alpha = 0.45)

# =========================================================================
#  GRAFIK 1 (Kernbild) — Differenz über Differenz im Tagesgang
#  Oben die Temperatur-Differenz, unten die Wind-Differenz (begrünt minus unbegrünt).
# =========================================================================
diff_stunde <- sel %>%
  group_by(stunde, strasse) %>%
  summarise(Ta = mean(humve_meteo_Ta_mean, na.rm = TRUE),
            wind = mean(wind, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = strasse, values_from = c(Ta, wind)) %>%
  mutate(dTa   = `Ta_Begrünte Straße`   - `Ta_Unbegrünte Straße`,
         dWind = `wind_Begrünte Straße` - `wind_Unbegrünte Straße`) %>%
  select(stunde, dTa, dWind) %>%
  pivot_longer(c(dTa, dWind), names_to = "kennzahl", values_to = "wert") %>%
  mutate(kennzahl = factor(kennzahl, levels = c("dTa", "dWind"),
           labels = c("Δ Lufttemperatur [°C]", "Δ Windgeschwindigkeit [m/s]")))

p_diff <- ggplot(diff_stunde, aes(stunde, wert)) +
  tag_band +
  geom_hline(yintercept = 0, colour = "grey50", linewidth = 0.4) +
  geom_line(linewidth = 0.9, colour = "steelblue") +
  geom_point(size = 1.7, colour = "steelblue") +
  facet_grid(kennzahl ~ ., scales = "free_y", switch = "y") +
  scale_x_continuous(breaks = seq(0, 24, 3), labels = function(x) sprintf("%02d:00", x)) +
  labs(title = "Differenz über Differenz im Tagesgang",
       subtitle = "Über 0 ist die begrünte Straße wärmer bzw. windiger (Auswahl 2, 4, 5, 7)",
       x = "Uhrzeit (Lokalzeit)", y = NULL,
       caption = "hellgelb = Tag (05–22 Uhr)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"),
        strip.placement = "outside", strip.text.y.left = element_text(angle = 90),
        panel.grid.minor = element_blank())

ggsave("../../plots/wind_sidequest/wind_diff_tagesgang.png", p_diff, width = 8, height = 6, dpi = 200, bg = "white")

# =========================================================================
#  GRAFIK 2 — Windgeschwindigkeit je Straße im Tagesgang
# =========================================================================
wind_stunde <- sel %>%
  group_by(stunde, strasse) %>%
  summarise(wind = mean(wind, na.rm = TRUE), .groups = "drop")

p_wind <- ggplot(wind_stunde, aes(stunde, wind, colour = strasse)) +
  tag_band +
  geom_line(linewidth = 1) + geom_point(size = 1.8) +
  scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
  scale_x_continuous(breaks = seq(0, 24, 3), labels = function(x) sprintf("%02d:00", x)) +
  scale_y_continuous(breaks = scales::breaks_width(0.5),
                     minor_breaks = scales::breaks_width(0.25)) +
  labs(title = "Windgeschwindigkeit je Straße im Tagesgang",
       subtitle = "Auswahl 2, 4, 5, 7",
       x = "Uhrzeit (Lokalzeit)", y = "Windgeschwindigkeit (m/s)",
       caption = "hellgelb = Tag (05–22 Uhr)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"),
        legend.position = "bottom")

ggsave("../../plots/wind_sidequest/wind_tagesgang.png", p_wind, width = 8, height = 5, dpi = 200, bg = "white")

# =========================================================================
#  GRAFIK 3 — Durchmischung je Straße und Tageszeit (Boxplots)
# =========================================================================
mix_long <- sel %>%
  select(strasse, tageszeit, TKE, Var_w, Waermefluss) %>%
  pivot_longer(c(TKE, Var_w, Waermefluss), names_to = "metrik", values_to = "wert") %>%
  mutate(metrik = factor(metrik, levels = c("TKE", "Var_w", "Waermefluss"),
           labels = c("TKE [m²/s²]", "Var_w [m²/s²]", "Wärmefluss w'Tv' [m·K/s]")),
         tageszeit = factor(tageszeit, levels = c("Tag", "Nacht")))

p_mix <- ggplot(mix_long, aes(tageszeit, wert, fill = strasse)) +
  geom_boxplot(position = position_dodge(0.8), outlier.size = 0.6, alpha = 0.9, linewidth = 0.4) +
  facet_wrap(~ metrik, scales = "free_y") +
  scale_fill_manual(name = "Straßentyp", values = farben_strasse) +
  labs(title = "Durchmischung je Straße und Tageszeit",
       subtitle = "Weniger Turbulenz und weniger Wärmeabtransport in der begrünten Straße (Auswahl 2, 4, 5, 7)",
       x = "Tageszeit", y = "Wert") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"),
        legend.position = "bottom")

ggsave("../../plots/wind_sidequest/mischung_boxplots.png", p_mix, width = 9, height = 4.5, dpi = 200, bg = "white")

# =========================================================================
#  KENNZAHLEN
# =========================================================================
kennz <- function(df) df %>% summarise(
  n = n(),
  wind = round(mean(wind, na.rm = TRUE), 2),
  TKE = round(mean(TKE, na.rm = TRUE), 3),
  Var_w = round(mean(Var_w, na.rm = TRUE), 3),
  Waermefluss = round(mean(Waermefluss, na.rm = TRUE), 4))

cat("### Wind und Durchmischung je Straße, GESAMT ###\n")
print(as.data.frame(sel %>% group_by(strasse) %>% kennz()), row.names = FALSE)

cat("\n### Wind und Durchmischung je Straße und Tageszeit ###\n")
print(as.data.frame(sel %>% group_by(strasse, tageszeit) %>% kennz()), row.names = FALSE)

cat("\nFERTIG. Drei Grafiken gespeichert in ../plots/ (wind_diff_tagesgang, wind_tagesgang, mischung_boxplots)\n")
