# Wind und Durchmischung: begrünte vs. unbegrünte Straße

**Skript:** `skripte/wind_mischung_strassenvergleich.R`
**Datum:** 2026-07-15

## Verwendete Daten

Quelle ist die Kampagnendatei `campaign_2026.rds` (Objekt `M$data`), nur gültige Besuche
(`visit_status == "ok"`) und die Auswahl der Stationen 2, 4, 5, 7. Aus dem Gill-Ultraschallanemometer
kommen die Windgeschwindigkeit (`humve_wind_wind_speed_gill_mean`), die Varianzen der drei
Windkomponenten (`Var_u`, `Var_v`, `Var_w`) und der turbulente Wärmefluss (`Cov_wTv`). Daraus
gebildet wird die turbulente kinetische Energie TKE als 0,5 mal der Summe der drei Varianzen. Die
Lufttemperatur stammt aus `humve_meteo_Ta_mean`. Tag ist 05 bis 22 Uhr, Nacht 22 bis 05 Uhr.

## Aggregation / Methode

Drei Grafiken. Erstens die Differenz über Differenz im Tagesgang: je Stunde die Temperatur-Differenz
und die Wind-Differenz zwischen den Straßen (begrünt minus unbegrünt), untereinander gezeichnet.
Zweitens die Windgeschwindigkeit je Straße im Tagesgang als zwei Linien. Drittens Boxplots der
Durchmischung (TKE, Var_w, Wärmefluss) je Straße und Tageszeit. Ergänzend die Mittelwerte je Straße,
gesamt und nach Tageszeit.

## Ergebnisse

Wind und Durchmischung sind in der begrünten Straße durchgehend geringer:

| Tageszeit | Größe | begrünt | unbegrünt | Verhältnis |
|-----------|-------|---------|-----------|------------|
| Gesamt | Wind (m/s) | 0,46 | 0,84 | grün rund 45 % weniger |
| Gesamt | TKE (m²/s²) | 0,086 | 0,154 | grün rund halb so viel |
| Gesamt | Var_w (m²/s²) | 0,024 | 0,043 | grün rund halb so viel |
| Gesamt | Wärmefluss (m·K/s) | -0,0008 | 0,0045 | grün deutlich weniger Aufwärtstransport |
| Tag | Wind (m/s) | 0,51 | 0,94 | |
| Tag | TKE (m²/s²) | 0,101 | 0,193 | |
| Tag | Wärmefluss (m·K/s) | -0,0023 | 0,0062 | |
| Nacht | Wind (m/s) | 0,35 | 0,66 | |
| Nacht | TKE (m²/s²) | 0,059 | 0,084 | |

Die begrünte Straße ist also klar windstiller, weniger turbulent und führt vor allem tagsüber
deutlich weniger Wärme nach oben ab. Die notwendige Voraussetzung der Hypothese, dass es in der
begrünten Straße windstiller ist, ist damit bestätigt.

Im Kernbild (Differenz über Differenz) zeigt sich aber auch: Die Wind-Differenz ist zu jeder Stunde
negativ (grün immer windstiller), am stärksten mittags. Die Temperatur-Differenz ist tagsüber
überwiegend negativ (grün kühler) und wird nur in einer einzigen Stunde (15 Uhr, plus 1,73 °C)
positiv. Die beiden Kurven laufen nicht parallel. Das bedeutet: allein aus dem Bild lässt sich kein
einfacher Zusammenhang «weniger Wind, also wärmer» ablesen. Ob der Wind über den Schatteneffekt
hinaus etwas beiträgt, wird deshalb getrennt geprüft (siehe `wind_effekt_strahlungskontrolle.md`).

## Kurzinterpretation

Die begrünte Straße ist eindeutig windstiller und schlechter durchmischt, mit rund halb so viel
Turbulenz und deutlich geringerem Wärmeabtransport nach oben. Das ist die physikalische
Voraussetzung für die vermutete Wärmestauung. Die Beobachtung der einen heißen Mittagsstunde ist
für sich genommen dünn und wird von den Nachbarstunden nicht gestützt. Alle Aussagen gelten für den
kurzen Kampagnenzeitraum von rund 40 Stunden.

## Einordnung des 15-Uhr-Spikes

Im Kernbild (Differenz über Differenz) wird die Temperatur-Differenz nur in der 15-Uhr-Stunde
positiv, die begrünte Straße ist dort also wärmer. Dieser Punkt beruht auf einer einzigen Runde
(Runde 22 am 19.06., 15:00 bis 15:49). Es handelt sich nicht um einen Sensorfehler: alle vier
begrünten Stationen liegen konsistent bei 32,7 bis 34,8 °C, alle vier unbegrünten bei 31,6 bis
32,2 °C. Ein defekter Sensor würde einen einzelnen Ausreißer erzeugen, nicht vier gleichmäßig höhere
Werte.

Drei Gründe machen diese Runde untypisch. Erstens der Zeitversatz: die Stationen werden nacheinander
besucht, die begrünte Straße von 15:00 bis 15:20, die unbegrünte erst von 15:29 bis 15:49, im
Schnitt rund eine halbe Stunde später. Die beiden Straßen werden also nicht gleichzeitig verglichen,
und am späten Nachmittag kann die Luft in dieser halben Stunde bereits abkühlen. Zweitens die
wechselhafte Bewölkung: die Einstrahlung springt innerhalb der begrünten Straße von 786 auf
73 W/m², die Bewölkung liegt bei 2 bis 7 Achteln, also durchziehende Wolken mit Sonnenlücken.
Drittens die dünne Datenbasis: hinter diesem Zeitpunkt steht nur diese eine Runde.

Fazit: kein Messfehler, sondern eine echte, aber nicht repräsentative Einzelrunde unter wechselhaften
Bedingungen mit Zeitversatz zwischen den Straßen. Über viele Runden mittelt sich so etwas heraus,
weshalb dieser eine Punkt nicht überinterpretiert werden sollte.

## Begriffe kurz erklärt

**Ultraschallanemometer (Gill):** ein Windmessgerät, das aus Laufzeiten von Schallsignalen die drei
Windkomponenten sehr schnell misst und daraus auch Turbulenz ableiten kann.

**TKE (turbulente kinetische Energie):** ein Maß für die gesamte Verwirbelung der Luft, berechnet aus
der Schwankung der drei Windkomponenten. Hohe TKE bedeutet starke Durchmischung.

**Var_w:** die Schwankung der vertikalen Windkomponente, also ein Maß dafür, wie stark sich die Luft
nach oben und unten mischt.

**Turbulenter Wärmefluss (Cov_wTv):** wie viel Wärme die verwirbelte Luft netto nach oben abführt.
Ein kleiner Wert bedeutet, dass wenig Wärme aus dem Straßenraum nach oben entweicht.

**Tagesgang:** der typische Verlauf über die Uhrzeit, hier gemittelt über die Kampagnentage.

## Erzeugte Dateien

`plots/wind_sidequest/wind_diff_tagesgang.png` (Kernbild, Differenz über Differenz)
`plots/wind_sidequest/wind_tagesgang.png` (Windgeschwindigkeit je Straße im Tagesgang)
`plots/wind_sidequest/mischung_boxplots.png` (TKE, Var_w, Wärmefluss je Straße und Tageszeit)
