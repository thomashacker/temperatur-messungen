# Einstrahlung im Zeitverlauf: begrünte vs. unbegrünte Straße

**Skript:** `skripte/einstrahlung_zeitverlauf.R`
**Datum:** 2026-07-15

## Verwendete Daten

Kampagnendatei `campaign_2026.rds`, nur gültige Besuche (`visit_status == "ok"`). Verwendet wird die
kurzwellige Einstrahlung `humve_meteo_ShortIn_mean` in W/m² über den echten Zeitverlauf der Kampagne
(18. bis 20.06.2026). Es gibt zwei Varianten, analog zu den übrigen Skripten: alle acht Stationen und
die Auswahl 2, 4, 5, 7.

## Aggregation / Methode

Gleiche Optik wie die Lufttemperatur-Grafik. Die Linien zeigen das Stundenmittel der Einstrahlung je
Straße. Der gelbe Hintergrund markiert den Tag (05 bis 22 Uhr), grün steht für die begrünte, grau
für die unbegrünte Straße. Eine gestrichelte rote senkrechte Linie markiert den Zeitpunkt des
Lufttemperatur-Spikes (19.06., 15 Uhr, Runde 22). Beide Varianten teilen dieselbe x- und y-Achse,
damit sie direkt vergleichbar sind.

## Ergebnisse

Die begrünte Straße bekommt über den ganzen Tag wenig direkte Einstrahlung, weil das Kronendach den
Sensor beschattet (Maximum rund 116 W/m² im Stundenmittel). Die unbegrünte Straße liegt am Vormittag
des 19.06. deutlich höher.

Die folgende Tabelle zeigt für das Fenster um den Spike (19.06., 12 bis 17 Uhr) je Stunde die
Lufttemperatur und die Einstrahlung beider Straßen. Ta in °C, Einstrahlung in W/m², ΔTa ist begrünt
minus unbegrünt (positiv bedeutet begrünte Straße wärmer).

| Uhrzeit | Ta begrünt | Ta unbegrünt | ΔTa | Einstrahlung begrünt | Einstrahlung unbegrünt |
|---------|-----------|-------------|-----|---------------------|-----------------------|
| 12:00 | 31,8 | 33,2 | −1,4 | 71 | 355 |
| 13:00 | 32,5 | 33,4 | −0,9 | 68 | 323 |
| 14:00 | 32,9 | 33,4 | −0,5 | 87 | 87 |
| **15:00** | **33,8** | **32,0** | **+1,8** | 116 | 164 |
| 16:00 | 32,1 | 33,3 | −1,2 | 78 | 102 |
| 17:00 | 29,7 | 30,1 | −0,4 | 58 | 49 |

An den Werten liest man den Zusammenhang direkt ab. Bis 13 Uhr hat die unbegrünte Straße hohe
Einstrahlung (rund 350 W/m²) und ist wärmer, die begrünte also kühler (ΔTa negativ). Um 14 Uhr bricht
die Einstrahlung der unbegrünten Straße plötzlich auf 87 W/m² ein, das ist das Muster einer
durchziehenden Wolke. In derselben Stunde schrumpft der Temperaturabstand, und um 15 Uhr ist die
begrünte Straße erstmals wärmer (ΔTa plus 1,8 °C). Sobald die Einstrahlung der unbegrünten Straße ab
16 Uhr wieder etwas steigt, ist die begrünte Straße erneut kühler.

## Kurzinterpretation

Die Grafik stützt die Erklärung des 15-Uhr-Spikes sichtbar. Während die begrünte Straße dauerhaft
beschattet ist, verliert die unbegrünte Straße am frühen Nachmittag durch eine Wolke ihre hohe
Einstrahlung und kühlt dadurch ab. Der kurze Moment, in dem die begrünte Straße wärmer erscheint,
hängt also mit dem Wetter und dem Zeitversatz der Messung zusammen, nicht mit einem Messfehler. Die
Beobachtung passt zu `lufttemperatur_strassenvergleich.md`.

## Einordnung: Wind-Sidequest

Die Beobachtung hat eine eigene Nebenuntersuchung ausgelöst, ob nicht der Wind hinter dem Spike
steckt, weil es in der begrünten Straße windstiller ist und die Luft sich dort stärker aufheizen
könnte. Diese Untersuchung liegt gesammelt im Ordner `wind_sidequest`. Kurz zusammengefasst: die
begrünte Straße ist zwar klar windstiller und schlechter durchmischt (rund halb so viel Wind und
Turbulenz), und der Mechanismus ist in der Literatur beschrieben, aber ein eigenständiger, wärmender
Windbeitrag ließ sich nicht nachweisen. Sobald die Einstrahlung herausgerechnet wird, ist der
Windbeitrag nicht signifikant und zeigt sogar in die andere Richtung. Das Thema ist also komplex und
führt zu keinem klaren Ergebnis.

Näher liegt die Einstrahlung als Erklärung: die durchziehende Wolke nahm der offenen Straße am frühen
Nachmittag ihre Sonne und kühlte sie ab, während die begrünte Straße ohnehin im Schatten lag. Details
zur Nebenuntersuchung in `wind_sidequest/zusammenfassung_wind_hypothese.md`.

## Begriffe kurz erklärt

**Einstrahlung (ShortIn):** die von der Sonne kommende kurzwellige Strahlung, die auf den Sensor
trifft, gemessen in Watt pro Quadratmeter (W/m²). Hohe Werte bedeuten viel Sonne, niedrige Werte
Schatten oder Bewölkung.

**Stundenmittel:** der Durchschnitt aller Messungen innerhalb einer Stunde, hier je Straße. Er bildet
die geglättete Linie im Diagramm.

**Bewölkung (Oktas):** die Wolkenbedeckung in Achteln des Himmels, von 0 (klar) bis 8 (bedeckt).

## Erzeugte Dateien

`plots/einstrahlung_zeitverlauf_alle.png` (Einstrahlung im Zeitverlauf, alle acht Stationen)
`plots/einstrahlung_zeitverlauf_auswahl.png` (Einstrahlung im Zeitverlauf, Auswahl 2, 4, 5, 7)
