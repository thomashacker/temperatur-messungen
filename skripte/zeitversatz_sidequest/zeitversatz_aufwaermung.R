#' Zeitversatz der Aufwärmung: Boden vs. Wand, begrünt vs. unbegrünt
#' Abschlussbericht Datenanalyse Stadtklima 2026 (Sidequest)
#' Untersucht, warum sich Boden und Wand sowie die beiden Straßen zeitversetzt
#' aufwärmen. Vermutung: die tiefstehende Morgensonne trifft senkrechte Flächen
#' (Wand) früher fast frontal, die flache Bodenfläche erst mittags. Kombiniert
#' Einstrahlung und Oberflächentemperatur im Tagesgang.
#' Autor: Hannah Balle

# --- Pakete ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

# --- Daten laden ----------------------------------------------------------
# Portabler Datenpfad (siehe README.md, Abschnitt Setup): Umgebungsvariable
# CAMPAIGN_RDS, sonst data/ im Repo, sonst CONTEXT/ daneben.
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
# Straßentyp, Oberflächen (Boden = Mittel Punkte 1..3, Wand = Punkt 4), Uhrzeit.
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")
farben_flaeche <- c("Boden" = "#B0662A", "Wand" = "#2166AC")

besuche <- Daten %>%
  mutate(
    strasse = factor(if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
                     levels = names(farben_strasse)),
    Boden   = rowMeans(cbind(manual_Ts_1, manual_Ts_2, manual_Ts_3), na.rm = TRUE),
    Wand    = manual_Ts_4,
    ShortIn = humve_meteo_ShortIn_mean,
    stunde  = hour(beginn_local_parsed)
  )

# --- Tagesgang: Mittelwert je Uhrzeit (über die Kampagnentage) ------------
# Fasst alle Werte einer Uhrzeit zusammen (z. B. alle 07-Uhr-Werte). So wird der
# tageszeitliche Verlauf sichtbar, unabhängig vom einzelnen Kalendertag.
tagesgang_flaeche <- besuche %>%
  pivot_longer(c(Boden, Wand), names_to = "oberflaechentyp", values_to = "Ts") %>%
  filter(!is.na(Ts)) %>%
  group_by(strasse, oberflaechentyp, stunde) %>%
  summarise(Ts = mean(Ts, na.rm = TRUE), .groups = "drop") %>%
  mutate(oberflaechentyp = factor(oberflaechentyp, levels = c("Boden", "Wand")))

tagesgang_si <- besuche %>%
  group_by(strasse, stunde) %>%
  summarise(ShortIn = mean(ShortIn, na.rm = TRUE), .groups = "drop")

# Achsenhilfen für alle Grafiken.
stunden_achse <- scale_x_continuous(breaks = seq(0, 24, 3),
                                    labels = function(x) sprintf("%02d:00", x))

# =========================================================================
#  GRAFIK 1 — Boden vs. Wand je Straße (Frage 1: warum Boden/Wand anders)
# =========================================================================
p1 <- ggplot(tagesgang_flaeche, aes(stunde, Ts, colour = oberflaechentyp)) +
  geom_line(linewidth = 1) + geom_point(size = 1.6) +
  facet_wrap(~ strasse) +
  scale_colour_manual(name = "Oberfläche", values = farben_flaeche) +
  stunden_achse +
  labs(title = "Tagesgang der Oberflächentemperatur: Boden vs. Wand",
       subtitle = "Die Wand führt morgens, der Boden zieht mittags nach (Mittel je Uhrzeit über die Kampagne)",
       x = "Uhrzeit (Lokalzeit)", y = "Oberflächentemperatur (°C)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")
ggsave("../../plots/zeitversatz_sidequest/tagesgang_boden_vs_wand.png", p1,
       width = 10, height = 5, dpi = 200, bg = "white")

# =========================================================================
#  GRAFIK 2 — Straßenvergleich je Oberfläche (Frage 2: warum Straßen anders)
# =========================================================================
p2 <- ggplot(tagesgang_flaeche, aes(stunde, Ts, colour = strasse)) +
  geom_line(linewidth = 1) + geom_point(size = 1.6) +
  facet_wrap(~ oberflaechentyp) +
  scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
  stunden_achse +
  labs(title = "Tagesgang je Oberfläche: begrünte vs. unbegrünte Straße",
       subtitle = "Die Beschattung der begrünten Straße dämpft Höhe und Schärfe des Tagesgangs",
       x = "Uhrzeit (Lokalzeit)", y = "Oberflächentemperatur (°C)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")
ggsave("../../plots/zeitversatz_sidequest/tagesgang_strassen_je_flaeche.png", p2,
       width = 10, height = 5, dpi = 200, bg = "white")

# =========================================================================
#  GRAFIK 3 — Einstrahlung + Oberflächentemperatur (unbegrünte Straße)
#  Zwei gestapelte Felder: oben die horizontale Einstrahlung, unten Boden/Wand.
#  Zeigt: die Wand ist morgens schon warm, bevor die horizontale Einstrahlung
#  ihr Mittagsmaximum erreicht.
# =========================================================================
si_unbegr <- tagesgang_si %>% filter(strasse == "Unbegrünte Straße") %>%
  transmute(stunde, wert = ShortIn, feld = "Einstrahlung (W/m²)")
temp_unbegr <- tagesgang_flaeche %>% filter(strasse == "Unbegrünte Straße") %>%
  transmute(stunde, wert = Ts, oberflaechentyp, feld = "Oberflächentemperatur (°C)")

si_peak <- si_unbegr$stunde[which.max(si_unbegr$wert)]   # Uhrzeit des Einstrahlungsmaximums

p3 <- ggplot() +
  geom_vline(xintercept = si_peak, linetype = "dashed", colour = "firebrick", linewidth = 0.5) +
  geom_area(data = si_unbegr, aes(stunde, wert), fill = "#E8A33D", alpha = 0.8) +
  geom_line(data = temp_unbegr, aes(stunde, wert, colour = oberflaechentyp), linewidth = 1) +
  geom_point(data = temp_unbegr, aes(stunde, wert, colour = oberflaechentyp), size = 1.6) +
  facet_grid(feld ~ ., scales = "free_y", switch = "y") +
  scale_colour_manual(name = "Oberfläche", values = farben_flaeche) +
  stunden_achse +
  labs(title = "Einstrahlung und Oberflächentemperatur (unbegrünte Straße)",
       subtitle = "Die Wand ist morgens warm, bevor die horizontale Einstrahlung mittags ihr Maximum erreicht",
       x = "Uhrzeit (Lokalzeit)", y = NULL,
       caption = "Gestrichelt: Uhrzeit des Einstrahlungsmaximums") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"),
        strip.placement = "outside", strip.text.y.left = element_text(angle = 90),
        legend.position = "bottom")
ggsave("../../plots/zeitversatz_sidequest/einstrahlung_und_oberflaeche.png", p3,
       width = 9, height = 6, dpi = 200, bg = "white")

# =========================================================================
#  KENNZAHLEN (für den Bericht)
# =========================================================================
peak_tab <- tagesgang_flaeche %>%
  group_by(strasse, oberflaechentyp) %>%
  summarise(peak_stunde = stunde[which.max(Ts)], peak_wert = round(max(Ts), 1), .groups = "drop")
cat("### Peak-Uhrzeit je Straße und Oberfläche ###\n")
print(as.data.frame(peak_tab), row.names = FALSE)

cat("\n### Einstrahlungsmaximum je Straße ###\n")
print(as.data.frame(tagesgang_si %>% group_by(strasse) %>%
  summarise(peak_stunde = stunde[which.max(ShortIn)], peak_wert = round(max(ShortIn), 0))),
  row.names = FALSE)

cat("\n### Morgen-Vorsprung Wand minus Boden (unbegrünte Straße), °C ###\n")
vorsprung <- tagesgang_flaeche %>% filter(strasse == "Unbegrünte Straße") %>%
  pivot_wider(names_from = oberflaechentyp, values_from = Ts) %>%
  transmute(stunde, differenz = round(Wand - Boden, 1)) %>% filter(stunde >= 5, stunde <= 11)
print(as.data.frame(vorsprung), row.names = FALSE)

cat("\nFERTIG. Drei Grafiken in ../../plots/zeitversatz_sidequest/\n")
