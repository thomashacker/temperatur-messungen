#' Lufttemperatur aus den stationären nMetos-Daten: gibt es den 15-Uhr-Peak?
#' Prüft am gleichzeitig gemessenen stationären Signal, ob der mobile 15-Uhr-Peak echt ist.
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

# --- Grafik 1: Stationäre Lufttemperatur im Zeitverlauf ---
p1 <- ggplot() +
  geom_rect(data = tag_rechtecke,
            aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = "Tag"), alpha = 0.5) +
  geom_line(data = stat_lang, aes(stunde, Ta, colour = strasse), linewidth = 1) +
  geom_point(data = stat_lang, aes(stunde, Ta, colour = strasse), size = 1.6) +
  scale_fill_manual(name = NULL, values = c("Tag" = "lightyellow"), labels = "Tag (05–22 Uhr)") +
  scale_colour_manual(name = "Straßentyp", values = farben_strasse) +
  scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
  scale_y_continuous(breaks = scales::breaks_width(2), minor_breaks = scales::breaks_width(1)) +
  coord_cartesian(xlim = zeitbereich) +
  labs(title = "Lufttemperatur (stationäre nMetos-Stationen)",
       subtitle = "Gleichzeitig gemessen für beide Straßen; die begrünte bleibt durchweg kühler",
       x = "Zeit", y = "Lufttemperatur (°C)",
       caption = "Hintergrund: hellgelb = Tag") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")
ggsave(paste0(plotpfad, "lufttemperatur_stationaer_zeitverlauf.png"), p1,
       width = 10, height = 5.5, dpi = 200, bg = "white")

# --- Grafik 2: Straßendifferenz mobil vs. stationär (beide stimmen überein, nur mobil springt um 15 Uhr) ---
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
  geom_line(linewidth = 1) + geom_point(size = 1.6) +
  scale_colour_manual(name = "Messquelle", values = farben_quelle) +
  scale_x_datetime(date_breaks = "6 hours", date_labels = "%d.%m.\n%H:%M") +
  coord_cartesian(xlim = zeitbereich) +
  labs(title = "Straßendifferenz der Lufttemperatur: mobil vs. stationär",
       subtitle = "Differenz begrünt minus unbegrünt; über 0 = begrünte Straße wärmer",
       x = "Zeit", y = "Δ Lufttemperatur (°C)",
       caption = "Hintergrund: hellgelb = Tag") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey40"), legend.position = "bottom")
ggsave(paste0(plotpfad, "lufttemperatur_mobil_vs_stationaer_differenz.png"), p2,
       width = 10, height = 5.5, dpi = 200, bg = "white")

# --- Boxplots (stationär): pro Runde je Straße ein Wert (Mittel der zwei Stationen), n = 40 je Straße ---
runde_stat <- aufb %>%
  group_by(round_no) %>%
  summarise(`Begrünte Straße`   = mean(stat_begr,   na.rm = TRUE),
            `Unbegrünte Straße` = mean(stat_unbegr, na.rm = TRUE),
            zeit = mean(beginn_local_parsed), .groups = "drop") %>%
  mutate(tageszeit = if_else(hour(zeit) >= 5 & hour(zeit) < 22, "Tag", "Nacht"))

runde_lang <- runde_stat %>%
  pivot_longer(c(`Begrünte Straße`, `Unbegrünte Straße`),
               names_to = "strasse", values_to = "Ta") %>%
  mutate(strasse = factor(strasse, levels = names(farben_strasse)))

plot_df <- bind_rows(
  runde_lang %>% mutate(zeitfenster = "Gesamt"),
  runde_lang %>% filter(tageszeit == "Tag")   %>% mutate(zeitfenster = "Tag (05–22 Uhr)"),
  runde_lang %>% filter(tageszeit == "Nacht") %>% mutate(zeitfenster = "Nacht (22–05 Uhr)")
) %>%
  mutate(zeitfenster = factor(zeitfenster,
           levels = c("Gesamt", "Tag (05–22 Uhr)", "Nacht (22–05 Uhr)")))

# Gemeinsame y-Achse über alle drei Grafiken.
y_grenzen <- range(plot_df$Ta, na.rm = TRUE)

speichere_boxplot <- function(daten, untertitel, dateiname) {
  p <- ggplot(daten, aes(x = strasse, y = Ta, fill = strasse)) +
    geom_boxplot(width = 0.6, outlier.size = 0.8, alpha = 0.9, linewidth = 0.4) +
    scale_fill_manual(name = "Straßentyp", values = farben_strasse) +
    scale_y_continuous(breaks = scales::breaks_width(2), minor_breaks = scales::breaks_width(1)) +
    coord_cartesian(ylim = y_grenzen) +
    labs(title = "Lufttemperatur stationär: begrünte vs. unbegrünte Straße",
         subtitle = untertitel, x = "Straßentyp", y = "Lufttemperatur (°C)",
         caption = "Stationäre nMetos-Daten, ein Wert je Messrunde und Straße, n = 40 je Straße") +
    theme_minimal(base_size = 13) +
    theme(plot.title = element_text(face = "bold"), plot.subtitle = element_text(colour = "grey40"),
          legend.position = "bottom",
          panel.grid.major.y = element_line(colour = "grey85"),
          panel.grid.minor.y = element_line(colour = "grey92", linewidth = 0.3))
  ggsave(paste0(plotpfad, dateiname), p, width = 6.5, height = 5, dpi = 200, bg = "white")
}

kombis <- list(
  list(zf = "Gesamt",            datei = "lufttemperatur_stationaer_boxplot_gesamt.png"),
  list(zf = "Tag (05–22 Uhr)",   datei = "lufttemperatur_stationaer_boxplot_tag.png"),
  list(zf = "Nacht (22–05 Uhr)", datei = "lufttemperatur_stationaer_boxplot_nacht.png")
)
for (k in kombis) speichere_boxplot(filter(plot_df, zeitfenster == k$zf), k$zf, k$datei)

# --- Statistik (stationär) ---
# --- Mittlere Temperatur je Gruppe und Differenz (unbegrünt minus begrünt) ---
differenz_tab <- plot_df %>%
  group_by(zeitfenster, strasse) %>%
  summarise(mittel = mean(Ta), .groups = "drop") %>%
  pivot_wider(names_from = strasse, values_from = mittel) %>%
  mutate(differenz = round(`Unbegrünte Straße` - `Begrünte Straße`, 2),
         `Begrünte Straße` = round(`Begrünte Straße`, 2),
         `Unbegrünte Straße` = round(`Unbegrünte Straße`, 2))
cat("### Mittlere Lufttemperatur je Gruppe und Differenz (stationär) ###\n")
print(as.data.frame(differenz_tab), row.names = FALSE)

# --- Deskriptive Kennzahlen je Gruppe (Median und Co.) ---
kennz_tab <- plot_df %>%
  group_by(zeitfenster, strasse) %>%
  summarise(n = n(), min = round(min(Ta), 1), Q25 = round(quantile(Ta, 0.25), 1),
            median = round(median(Ta), 1), mittel = round(mean(Ta), 1),
            Q75 = round(quantile(Ta, 0.75), 1), max = round(max(Ta), 1),
            sd = round(sd(Ta), 2), IQR = round(IQR(Ta), 1), .groups = "drop")
cat("\n### Deskriptive Kennzahlen je Gruppe, stationär (Median und Co.) ###\n")
print(as.data.frame(kennz_tab), row.names = FALSE)

# --- Gepaarter t-Test pro Runde, je Zeitfenster ---
paar_test <- function(df) {
  w <- df %>% select(round_no, strasse, Ta) %>%
    pivot_wider(names_from = strasse, values_from = Ta)
  t.test(w$`Unbegrünte Straße`, w$`Begrünte Straße`, paired = TRUE)
}
cat("\n### Gepaarter t-Test pro Runde, stationär (unbegrünt vs. begrünt) ###\n")
for (zf in c("Gesamt", "Tag (05–22 Uhr)", "Nacht (22–05 Uhr)")) {
  cat("\n--", zf, "--\n")
  print(paar_test(filter(plot_df, zeitfenster == zf)))
}

# --- Vergleich mobil vs. stationär am 19.06. (Kontext zum 15-Uhr-Peak) ---
cat("\n### Differenz begrünt minus unbegrünt am 19.06. (positiv = begrünt wärmer) ###\n")
vgl <- mob_diff %>% select(stunde, mobil = diff) %>%
  left_join(stat_diff %>% select(stunde, stationaer = diff), by = "stunde") %>%
  filter(as.Date(stunde) == as.Date("2026-06-19"), hour(stunde) >= 10, hour(stunde) <= 18) %>%
  mutate(uhr = format(stunde, "%H:%M"), mobil = round(mobil, 2), stationaer = round(stationaer, 2))
print(as.data.frame(vgl %>% select(uhr, mobil, stationaer)), row.names = FALSE)

cat("\nFERTIG. Fünf Grafiken in ../plots/ (2x Zeitverlauf, 3x stationärer Boxplot)\n")
