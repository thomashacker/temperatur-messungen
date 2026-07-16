# Windeffekt unter Kontrolle der Einstrahlung

**Skript:** `skripte/wind_effekt_strahlungskontrolle.R`
**Datum:** 2026-07-15

## Fragestellung

Ist die begrünte Straße wärmer, weil dort weniger Wind weht und die Luft schlechter abgeführt wird?
Der große Störfaktor ist der Schatten: die Bäume nehmen der begrünten Straße einen Teil der
Einstrahlung, was sie kühlt. Um den eigenständigen Beitrag des Windes zu sehen, muss der
Schatteneffekt herausgerechnet werden.

## Verwendete Daten

Kampagnendatei `campaign_2026.rds`, gültige Besuche, Auswahl 2, 4, 5, 7. Verwendet werden die
Lufttemperatur (`humve_meteo_Ta_mean`), die Einstrahlung (`humve_meteo_ShortIn_mean`) und die
Windgeschwindigkeit (`humve_wind_wind_speed_gill_mean`).

## Methode

Der Test läuft paarweise pro Runde. Da in jeder Runde beide Straßen etwa zur gleichen Zeit gemessen
werden, ist die Tageszeit automatisch kontrolliert. Je Runde wird die Differenz begrünt minus
unbegrünt gebildet, für Temperatur (dTa), Einstrahlung (dShortIn) und Wind (dWind). Das Modell
lautet dTa ~ dShortIn + dWind. Ein positiver dShortIn-Koeffizient steht für den Schatteneffekt
(weniger Sonne, kühler). Ein negativer dWind-Koeffizient würde die Hypothese stützen (grün
windstiller, also wärmer).

## Ergebnisse

Regression dTa ~ dShortIn + dWind über 40 Runden:

| Einfluss | Koeffizient | Standardfehler | p-Wert | Bewertung |
|----------|-------------|----------------|--------|-----------|
| Einstrahlung dShortIn | +0,0042 °C je W/m² | 0,0012 | 0,0015 | signifikant |
| Wind dWind | +0,58 °C je m/s | 0,34 | 0,10 | nicht signifikant |
| (Achsenabschnitt) | +0,12 °C | 0,14 | 0,39 | |

Das Modell erklärt rund 47 Prozent der Streuung (R² = 0,47). Einzeln betrachtet hängen sowohl die
Einstrahlungs-Differenz (p < 0,001) als auch die Wind-Differenz (p < 0,001) mit der
Temperatur-Differenz zusammen. Sobald aber beide zusammen im Modell stehen, bleibt nur die
Einstrahlung signifikant, der Wind verliert seine Bedeutung.

Zwei Dinge sprechen klar gegen die Hypothese. Erstens ist der Wind-Koeffizient nach Kontrolle der
Einstrahlung nicht signifikant. Zweitens ist sein Vorzeichen positiv statt negativ. Positiv heißt:
wenn die begrünte Straße relativ windstiller ist, ist sie tendenziell kühler, nicht wärmer. Das ist
das Gegenteil der Vermutung und erklärt sich dadurch, dass windstill und kühl gemeinsam nachts und
im Schatten auftreten, windig und heiß dagegen mittags auf der offenen Straße.

Ein wichtiger Vorbehalt zeigt sich in der Grafik `ta_vs_einstrahlung.png`: Der Strahlungssensor unter
dem Kronendach misst selbst mittags nur geringe Werte (die begrünte Straße erreicht ihr Maximum bei
rund 160 W/m², die unbegrünte bei rund 650 W/m²). Die gemessene Einstrahlung der begrünten Straße
ist also kein sauberes Maß für den tatsächlichen Energieeintrag, was die Kontrolle erschwert.

## Kurzinterpretation

Mit diesen Daten lässt sich die Hypothese nicht bestätigen. Der Temperaturunterschied zwischen den
Straßen wird von der Einstrahlung, also vom Schatten der Bäume, bestimmt. Der Wind ist zwar klar
geringer in der begrünten Straße (siehe `wind_mischung_strassenvergleich.md`), aber ein
eigenständiger, wärmender Windbeitrag ist statistisch nicht nachweisbar und weist in diesen Daten
sogar in die andere Richtung. Die Vermutung bleibt physikalisch plausibel und ist in der Literatur
beschrieben, in dieser kurzen Kampagne dominiert jedoch der Schatteneffekt so stark, dass sich ein
Windeffekt nicht sauber trennen lässt.

## Begriffe kurz erklärt

**Lineare Regression:** ein Verfahren, das beschreibt, wie eine Zielgröße (hier die
Temperatur-Differenz) von einer oder mehreren Einflussgrößen abhängt.

**Koeffizient:** die Steigung je Einflussgröße. Er sagt, um wie viel sich die Zielgröße ändert, wenn
die Einflussgröße um eine Einheit steigt und die anderen konstant bleiben.

**p-Wert:** die Wahrscheinlichkeit, einen solchen Zusammenhang rein zufällig zu sehen. Unter 0,05
gilt als signifikant.

**R² (Bestimmtheitsmaß):** der Anteil der Streuung, den das Modell erklärt, zwischen 0 und 1.

**Kollinearität:** wenn zwei Einflussgrößen eng zusammenhängen und schwer zu trennen sind. Hier sind
Straße und Wind kaum trennbar, weil die begrünte Straße gerade die windstille Bedingung ist.

**Störfaktor (Confounder):** eine dritte Größe, die zwei andere gemeinsam beeinflusst und einen
Scheinzusammenhang erzeugen kann. Hier ist die Tageszeit über die Einstrahlung ein solcher Faktor.

## Erzeugte Dateien

`plots/wind_sidequest/ta_vs_einstrahlung.png` (Lufttemperatur gegen Einstrahlung je Straße)
`plots/wind_sidequest/wind_effekt_streudiagramm.png` (Temperatur-Differenz gegen Einstrahlungs- und Wind-Differenz)
