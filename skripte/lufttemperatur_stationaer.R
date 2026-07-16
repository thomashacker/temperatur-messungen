#' Lufttemperatur aus den stationären nMetos-Daten: gibt es den 15-Uhr-Peak?
#' Abschlussbericht Datenanalyse Stadtklima 2026
#' Die stationären Stationen (nMetos) messen kontinuierlich und für beide Straßen
#' gleichzeitig, anders als die mobile HuMVe-Messung, die die Stationen nacheinander
#' besucht. Damit lässt sich prüfen, ob der 15-Uhr-Peak (begrünte Straße kurz wärmer)
#' echt ist oder ein Artefakt des mobilen Messtimings.
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
# Zwei stationäre Stationen je Straße, am jeweiligen Zeitstempel der Zeile:
#   begrünt (Husemann) = husemann21, husemann30
#   unbegrünt (Hagenauer) = hagenauer2, hagenauer11
# Zusätzlich die mobile Lufttemperatur (humve_meteo_Ta_mean) je Straße aus station_order.
farben_strasse <- c("Begrünte Straße" = "forestgreen", "Unbegrünte Straße" = "gray60")
farben_quelle  <- c("mobil (HuMVe)" = "#1F78B4", "stationär (nMetos)" = "#E31A1C")

aufb <- Daten %>%
  mutate(
    strasse   = if_else(station_order %in% 1:4, "Begrünte Straße", "Unbegrünte Straße"),
    stat_begr   = rowMeans(cbind(nMetos_husemann21_Ta_mean, nMetos_husemann30_Ta_mean), na.rm = TRUE),
    stat_unbegr = rowMeans(cbind(nMetos_hagenauer2_Ta_mean, nMetos_hagenauer11_Ta_mean), na.rm = TRUE),
    stunde    = floor_date(beginn_local_parsed, "hour")
  )

# --- Stundenmittel: stationär je Straße -----------------------------------
stat_lang <- aufb %>%
  group_by(stunde) %>%
  summarise(`Begrünte Straße`   = mean(stat_begr,   na.rm = TRUE),
            `Unbegrünte Straße` = mean(stat_unbegr, na.rm = TRUE), .groups = "drop") %>%
  pivot_longer(-stunde, names_to = "strasse", values_to = "Ta") %>%
  mutate(strasse = factor(strasse, levels = names(farben_strasse)))

# --- Achsenhilfen (Tag-Rechtecke, Zeitbereich, Spike-Marker) --------------
tzone <- tz(stat_lang$stunde)
tage  <- seq(as.Date(min(stat_lang$stunde), tz = tzone),
             as.Date(max(stat_lang$stunde), tz = tzone), by = "day")
tag_rechtecke <- tibble(
  xmin = as.POSIXct(paste(tage, "05:00:00"), tz = tzone),
  xmax = as.POSIXct(paste(tage, "22:00:00"), tz = tzone)
)
zeitbereich <- range(stat_lang$stunde, na.rm = TRUE)
spike_zeit  <- as.POSIXct("2026-06-19 15:00:00", tz = tzone)

# =========================================================================
#  GRAFIK 1 — Stationäre Lufttemperatur im Zeitverlauf
# =========================================================================
p1 <- ggplot() +
  geom_rect(data = tag_rechtecke,
            aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = "Tag"), alpha = 0.5) +
  geom_vline(xintercept = spike_zeit, linetype = "dashed", colour = "firebrick", linewidth = 0.6) +
  geom_line(data = stat_lang, aes(stunde, Ta, colour = strasse), linewidth = 1) +
  geom_point(data = stat_lang, aes(stunde, Ta, colour = strasse), size = 1.6) +
  scale_fill_manual(name = NULL, values = c("Tag" = "lightyellow"), labels = "Tag (05–22 Uhr)") +
  scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
  scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
  scale_y_continuous(breaks = scales::breaks_width(2), minor_breaks = scales::breaks_width(1)) +
  coord_cartesian(xlim = zeitbereich) +
  labs(title = "Lufttemperatur (stationäre nMetos-Stationen)",
       subtitle = "Gleichzeitig gemessen für beide Straßen; die begrünte bleibt durchweg kühler, kein 15-Uhr-Peak",
       x = "Zeit", y = "Lufttemperatur (°C)",
       caption = "Gestrichelt: Zeitpunkt des mobilen 15-Uhr-Peaks. Hintergrund: hellgelb = Tag") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")
ggsave("../plots/lufttemperatur_stationaer_zeitverlauf.png", p1,
       width = 10, height = 5.5, dpi = 200, bg = "white")

# =========================================================================
#  GRAFIK 2 — Differenz begrünt minus unbegrünt: mobil vs. stationär
#  Zeigt: beide Quellen stimmen überein, nur der mobile Wert springt um 15 Uhr.
# =========================================================================
mob_diff <- aufb %>%
  group_by(stunde, strasse) %>%
  summarise(Ta = mean(humve_meteo_Ta_mean, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = strasse, values_from = Ta) %>%
  transmute(stunde, diff = `Begrünte Straße` - `Unbegrünte Straße`, quelle = "mobil (HuMVe)")

stat_diff <- stat_lang %>%
  pivot_wider(names_from = strasse, values_from = Ta) %>%
  transmute(stunde, diff = `Begrünte Straße` - `Unbegrünte Straße`, quelle = "stationär (nMetos)")

diff_lang <- bind_rows(mob_diff, stat_diff) %>%
  mutate(quelle = factor(quelle, levels = names(farben_quelle)))

p2 <- ggplot(diff_lang, aes(stunde, diff, colour = quelle)) +
  geom_rect(data = tag_rechtecke, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf), fill = "lightyellow", alpha = 0.5) +
  geom_hline(yintercept = 0, colour = "grey50", linewidth = 0.4) +
  geom_vline(xintercept = spike_zeit, linetype = "dashed", colour = "firebrick", linewidth = 0.6) +
  geom_line(linewidth = 1) + geom_point(size = 1.6) +
  scale_colour_manual(name = "Messquelle", values = farben_quelle) +
  scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
  coord_cartesian(xlim = zeitbereich) +
  labs(title = "Straßendifferenz der Lufttemperatur: mobil vs. stationär",
       subtitle = "Differenz begrünt minus unbegrünt; über 0 = begrünte Straße wärmer",
       x = "Zeit", y = "Δ Lufttemperatur (°C)",
       caption = "Gestrichelt: mobiler 15-Uhr-Peak. Hintergrund: hellgelb = Tag") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")
ggsave("../plots/lufttemperatur_mobil_vs_stationaer_differenz.png", p2,
       width = 10, height = 5.5, dpi = 200, bg = "white")

# =========================================================================
#  KENNZAHLEN
# =========================================================================
cat("### Differenz begrünt minus unbegrünt am 19.06. (positiv = begrünt wärmer) ###\n")
vgl <- mob_diff %>% select(stunde, mobil = diff) %>%
  left_join(stat_diff %>% select(stunde, stationaer = diff), by = "stunde") %>%
  filter(as.Date(stunde) == as.Date("2026-06-19"), hour(stunde) >= 10, hour(stunde) <= 18) %>%
  mutate(uhr = format(stunde, "%H:%M"), mobil = round(mobil, 2), stationaer = round(stationaer, 2))
print(as.data.frame(vgl %>% select(uhr, mobil, stationaer)), row.names = FALSE)

# Gepaarter t-Test pro Runde auf den stationären Daten (Gesamtzeitraum).
paar_stat <- aufb %>%
  group_by(round_no) %>%
  summarise(begr = mean(stat_begr, na.rm = TRUE), unbegr = mean(stat_unbegr, na.rm = TRUE), .groups = "drop")
cat("\n### Gepaarter t-Test pro Runde, stationär (unbegrünt vs. begrünt) ###\n")
print(t.test(paar_stat$unbegr, paar_stat$begr, paired = TRUE))

cat("\nFERTIG. Zwei Grafiken in ../plots/ (lufttemperatur_stationaer_zeitverlauf, _mobil_vs_stationaer_differenz)\n")
