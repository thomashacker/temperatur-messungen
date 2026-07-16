# Zeitversatz der Aufwärmung: Boden vs. Wand, begrünt vs. unbegrünt (Sidequest)

**Skript:** `skripte/zeitversatz_sidequest/zeitversatz_aufwaermung.R`
**Datum:** 2026-07-16

## Fragestellung

In den Oberflächen-Zeitverläufen (`oberflaeche_zeitverlauf_*_alle.png`) fällt auf, dass sich die
Flächen zeitversetzt aufwärmen. Zwei Fragen:

1. Warum unterscheiden sich Boden und Wand im zeitlichen Verlauf?
2. Warum unterscheiden sich innerhalb von Boden und innerhalb von Wand die beiden Straßen?

Vermutung: Die tiefstehende Morgensonne bestrahlt zuerst senkrechte Flächen (Wand), die flache
Bodenfläche erst mittags. Dazu werden Einstrahlung und Oberflächentemperatur gemeinsam betrachtet.

## Verwendete Daten

Kampagnendatei `campaign_2026.rds`, nur gültige Besuche (`visit_status == "ok"`). Oberflächen aus den
Handmessungen: Boden ist das Mittel der Punkte 1, 2 und 3 (`manual_Ts_1..3`), Wand ist Punkt 4
(`manual_Ts_4`). Die Einstrahlung ist `humve_meteo_ShortIn_mean` in W/m², gemessen mit einem nach
oben gerichteten (horizontalen) Sensor, sie beschreibt also die auf eine waagerechte Fläche
treffende Strahlung. Straßenzuordnung über `station_order` (1 bis 4 begrünt, 5 bis 8 unbegrünt).

## Aggregation / Methode

Gebildet wird der Tagesgang, also der Mittelwert je Uhrzeit (volle Stunde) über die Kampagnentage.
Alle Werte einer Uhrzeit werden zusammengefasst, dadurch wird der tageszeitliche Verlauf sichtbar,
unabhängig vom einzelnen Kalendertag. Drei Grafiken: Boden gegen Wand je Straße, die beiden Straßen
je Oberfläche, sowie Einstrahlung und Oberflächentemperatur gestapelt für die unbegrünte Straße.

Wichtiger Vorbehalt: Der Zeitraum ist kurz. Die Nachtstunden stammen aus zwei Nächten, die
Tagesstunden (etwa 10 bis 17 Uhr) im Wesentlichen aus dem einen vollen Kampagnentag (19.06.). Die
Tagesform beruht also fast nur auf diesem Tag.

## Ergebnisse

### Frage 1: Boden und Wand (unbegrünte Straße)

Peak-Uhrzeiten im Tagesgang:

| Größe | Peak-Uhrzeit | Wert |
|-------|--------------|------|
| Einstrahlung (horizontal) | 12:00 | 539 W/m² |
| Boden | 13:00 | 38,6 °C |
| Wand | 16:00 | 39,7 °C |

Morgens ist die Wand deutlich wärmer als der Boden, mittags kehrt es sich um:

| Uhrzeit | Wand minus Boden |
|---------|------------------|
| 05:00 | +1,2 °C |
| 06:00 | +2,6 °C |
| 07:00 | +4,2 °C |
| 08:00 | +3,0 °C |
| 09:00 | +2,5 °C |
| 10:00 | +2,2 °C |
| 11:00 | −1,5 °C |

Die Wand führt von Sonnenaufgang bis rund 10 Uhr, um 07 Uhr sogar um 4,2 °C. Ab etwa 11 Uhr überholt
der Boden. Der Boden erreicht sein Maximum um 13 Uhr, kurz nach dem Einstrahlungsmaximum um 12 Uhr.
Die Wand erreicht ihr Maximum erst um 16 Uhr.

Das ist genau das Muster der Sonnengeometrie. Die horizontale Einstrahlung (der obere Bereich in
Grafik 3) folgt dem Sonnenstand und erreicht mittags ihr Maximum, wenn die Sonne hoch steht und fast
senkrecht auf den Boden trifft. Deshalb heizt sich der Boden mittags am stärksten auf und peakt
zusammen mit der Einstrahlung. Eine senkrechte Wand bekommt dagegen bei tiefem Sonnenstand am Morgen
(und am späten Nachmittag) den fast frontalen Strahl ab, mittags bei hohem Sonnenstand nur streifend.
Deshalb ist die Wand morgens schon warm, bevor die horizontale Einstrahlung ihr Mittagsmaximum
erreicht, und behält bis in den späten Nachmittag hohe Werte.

### Frage 2: begrünte vs. unbegrünte Straße

Peak-Uhrzeiten der begrünten Straße: Boden 16 Uhr (30,6 °C), Wand 15 Uhr (29,8 °C),
Einstrahlung 15 Uhr (276 W/m²). Der Tagesgang ist stark gedämpft und flacher.

Der Grund ist die Beschattung durch die Bäume. Die begrünte Straße bekommt viel weniger Einstrahlung
(Maximum 276 gegen 539 W/m²) und diese zudem unregelmäßig durch Sonnenlücken. Beide Oberflächen
bleiben dadurch deutlich kühler, und die Aufheizung ist über den Tag verteilt statt scharf gebündelt.
Das gleiche Muster Wand führt morgens gibt es auch hier, aber sehr abgeschwächt.

## Antwort und Fazit

Beide Beobachtungen lassen sich mit den Daten erklären. Boden und Wand unterscheiden sich zeitlich,
weil die Sonne wegen ihres wechselnden Standes verschiedene Flächen zu verschiedenen Zeiten fast
frontal trifft: die senkrechte Wand morgens und spätnachmittags, die waagerechte Bodenfläche mittags.
Die Vermutung, dass beim Sonnenaufgang zuerst die Wand und dann der Boden bestrahlt wird, wird also
bestätigt. Die beiden Straßen unterscheiden sich, weil die Bäume der begrünten Straße die Einstrahlung
abschirmen und so Höhe und Schärfe des Tagesgangs dämpfen.

Grenzen der Aussage: Die Ausrichtung der Wände (Ost, Süd, West) steht nicht in den Daten, deshalb
lässt sich die genaue Morgen- und Nachmittagsasymmetrie nicht einzelnen Fassaden zuordnen. Die Wand
ist außerdem nur ein Messpunkt je Station (der Boden ein Mittel aus drei), also etwas verrauschter.
Und der Tagesteil beruht fast nur auf dem 19.06.

## Begriffe kurz erklärt

**Tagesgang:** der typische Verlauf über die Uhrzeit, hier als Mittelwert je Stunde über die
Kampagnentage.

**Einstrahlung (ShortIn):** die von der Sonne kommende kurzwellige Strahlung auf einen nach oben
gerichteten (horizontalen) Sensor, in Watt pro Quadratmeter.

**Einfallswinkel / Sonnengeometrie:** der Winkel, unter dem der Sonnenstrahl auf eine Fläche trifft.
Trifft er fast senkrecht, ist der Energieeintrag pro Fläche groß, trifft er streifend, ist er klein.
Tiefer Sonnenstand trifft senkrechte Flächen fast frontal, hoher Sonnenstand waagerechte Flächen.

**Beschattung:** das Abschirmen der direkten Sonne, hier durch die Baumkronen der begrünten Straße.

**Boden und Wand:** Boden ist der Mittelwert der drei bodennahen Messpunkte, Wand die Messung an der
Fassade.

## Erzeugte Dateien

`plots/zeitversatz_sidequest/tagesgang_boden_vs_wand.png` (Boden gegen Wand je Straße)
`plots/zeitversatz_sidequest/tagesgang_strassen_je_flaeche.png` (Straßenvergleich je Oberfläche)
`plots/zeitversatz_sidequest/einstrahlung_und_oberflaeche.png` (Einstrahlung und Oberflächentemperatur, unbegrünte Straße)
