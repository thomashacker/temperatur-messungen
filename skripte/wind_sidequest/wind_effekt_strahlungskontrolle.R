#' Windeffekt unter Kontrolle der Einstrahlung
#' Abschlussbericht Datenanalyse Stadtklima 2026. Autor: Hannah Balle
#' Rechnet den Schatteneffekt heraus, um den Windbeitrag zu isolieren (Auswahl 2, 4, 5, 7).

# --- Pakete ---
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

# --- Pfade (bei Bedarf anpassen) ---
datenpfad <- "../../../CONTEXT/campaign_2026.rds"   # Kampagnendatei
plotpfad  <- "../../plots/wind_sidequest/"          # Zielordner der Grafiken

Messkampagne <- readRDS(datenpfad)
Daten <- filter(Messkampagne$data, visit_status == "ok")

# --- Aufbereitung ---
auswahl_stationen <- c(2, 4, 5, 7)
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")

sel <- Daten %>%
  filter(station_order %in% auswahl_stationen) %>%
  mutate(
    strasse = factor(if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
                     levels = names(farben_strasse)),
    Ta = humve_meteo_Ta_mean,
    ShortIn = humve_meteo_ShortIn_mean,
    wind = humve_wind_wind_speed_gill_mean
  )

# --- Grafik 1: Lufttemperatur gegen Einstrahlung, je Straße (gleiche Einstrahlung vergleichen) ---
p_scatter <- ggplot(sel, aes(ShortIn, Ta, colour = strasse)) +
  geom_point(alpha = 0.5, size = 1.3) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1) +
  scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
  labs(title = "Lufttemperatur gegen Einstrahlung",
       subtitle = "Grün erreicht hohe Temperaturen schon bei geringer gemessener Einstrahlung, weil das Kronendach den Sensor beschattet (Auswahl 2, 4, 5, 7)",
       x = "Einstrahlung ShortIn (W/m²)", y = "Lufttemperatur (°C)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")

ggsave(paste0(plotpfad, "ta_vs_einstrahlung.png"), p_scatter, width = 8, height = 5.5, dpi = 200, bg = "white")

# --- Test: paarweise pro Runde, Differenzen begrünt minus unbegrünt ---
# Modell dTa ~ dShortIn + dWind: dShortIn>0 = Schatteneffekt, dWind<0 (windstiller) => wärmer = Windeffekt.
paar <- sel %>%
  group_by(round_no, strasse) %>%
  summarise(Ta = mean(Ta, na.rm = TRUE), ShortIn = mean(ShortIn, na.rm = TRUE),
            wind = mean(wind, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = strasse, values_from = c(Ta, ShortIn, wind)) %>%
  mutate(dTa      = `Ta_Begrünte Straße`      - `Ta_Unbegrünte Straße`,
         dShortIn = `ShortIn_Begrünte Straße` - `ShortIn_Unbegrünte Straße`,
         dWind    = `wind_Begrünte Straße`    - `wind_Unbegrünte Straße`)

cat("### Paarweise Regression pro Runde: dTa ~ dShortIn + dWind ###\n")
modell <- lm(dTa ~ dShortIn + dWind, data = paar)
print(summary(modell))

cat("\n### Zum Vergleich: nur Einstrahlung, bzw. nur Wind ###\n")
cat("dTa ~ dShortIn:\n"); print(round(coef(summary(lm(dTa ~ dShortIn, data = paar))), 4))
cat("\ndTa ~ dWind:\n");  print(round(coef(summary(lm(dTa ~ dWind, data = paar))), 4))

# --- Grafik 2: Partielle Streudiagramme dTa gegen dShortIn und gegen dWind ---
paar_long <- paar %>%
  select(round_no, dTa, dShortIn, dWind) %>%
  pivot_longer(c(dShortIn, dWind), names_to = "einfluss", values_to = "wert") %>%
  mutate(einfluss = factor(einfluss, levels = c("dShortIn", "dWind"),
           labels = c("Δ Einstrahlung [W/m²]", "Δ Windgeschwindigkeit [m/s]")))

p_partial <- ggplot(paar_long, aes(wert, dTa)) +
  geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.3) +
  geom_vline(xintercept = 0, colour = "grey70", linewidth = 0.3) +
  geom_point(alpha = 0.6, size = 1.4, colour = "steelblue") +
  geom_smooth(method = "lm", se = TRUE, colour = "steelblue", linewidth = 0.9) +
  facet_wrap(~ einfluss, scales = "free_x") +
  labs(title = "Temperatur-Differenz gegen Einstrahlungs- und Wind-Differenz",
       subtitle = "Alle Differenzen begrünt minus unbegrünt, je Runde (Auswahl 2, 4, 5, 7)",
       x = "Differenz begrünt minus unbegrünt",
       y = "Δ Lufttemperatur [°C]") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"))

ggsave(paste0(plotpfad, "wind_effekt_streudiagramm.png"), p_partial, width = 9, height = 4.5, dpi = 200, bg = "white")

cat("\nFERTIG. Zwei Grafiken gespeichert in ../plots/ (ta_vs_einstrahlung, wind_effekt_streudiagramm)\n")
