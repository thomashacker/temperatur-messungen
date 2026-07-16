# Lufttemperatur: begrünte vs. unbegrünte Straße (Boxplots)

**Skript:** `skripte/lufttemperatur_boxplot.R`
**Datum:** 2026-07-16

## Verwendete Daten

Quelle ist die Kampagnendatei `campaign_2026.rds` (Objekt `M$data`). Verwendet wird die mobil
gemessene Lufttemperatur `humve_meteo_Ta_mean` in °C (ein Wert je Stationsbesuch). Berücksichtigt
sind nur gültige Besuche (`visit_status == "ok"`). Der Messzeitraum reicht vom 18.06.2026, 18:00 Uhr
bis zum 20.06.2026, 09:47 Uhr (Ortszeit). Die Straßenzuordnung erfolgt über `station_order`: die
Stationen 1 bis 4 bilden die begrünte Straße (Husemann), die Stationen 5 bis 8 die unbegrünte
(Hagenauer).

Zwei Aufteilungen werden gezeigt. Erstens die Stationsauswahl: alle acht Stationen gegenüber der
Auswahl 2, 4, 5, 7, aus der die stark besonnten Stationen 1, 3, 6 und 8 entfernt sind. Zweitens die
Tageszeit: Gesamt, Tag und Nacht, wobei Tag als 05 bis 22 Uhr definiert ist und Nacht als 22 bis
05 Uhr.

Diese Auswertung ist das Boxplot-Gegenstück zur Zeitverlaufs-Grafik in
`lufttemperatur_strassenvergleich.md` und ist bewusst gleich aufgebaut wie die
Oberflächentemperatur-Boxplots (`oberflaeche_boxplot.md`), damit alle Auswertungen einheitlich
aussehen.

## Aggregation / Methode

Wie bei der Oberflächentemperatur ist die Beobachtungseinheit die Runde. Pro Runde und Straße werden
die Stationen zu einem Wert gemittelt, es gibt also je Straße 40 Werte (eine je Runde), nicht die
einzelnen Stationsbesuche. Das vermeidet Pseudoreplikation und ist konsistent mit dem gepaarten
t-Test. Jede Runde wird über ihre mittlere Uhrzeit dem Tag oder der Nacht zugeordnet.

Es entstehen sechs einzelne Grafiken, je eine pro Kombination aus Stationsauswahl (alle, Auswahl)
und Tageszeit (Gesamt, Tag, Nacht). In jeder Grafik stehen die beiden Straßen nebeneinander (grün
für begrünt, grau für unbegrünt). Anders als bei der Oberflächentemperatur gibt es keine Boden- und
Wand-Unterscheidung, die Lufttemperatur ist ein Wert je Besuch. Alle sechs Grafiken nutzen dieselbe
y-Achse.

Für die Kernaussage wird die mittlere Differenz gebildet, Konvention unbegrünt minus begrünt. Ein
positiver Wert bedeutet, dass die begrünte Straße kühler ist. Zusätzlich wird gepaart pro Runde
geprüft.

## Ergebnisse

Mittlere Lufttemperatur je Gruppe und Differenz (begrünte Straße kühler, wenn positiv):

| Stationen | Tageszeit | begrünt (°C) | unbegrünt (°C) | Differenz (°C) |
|-----------|-----------|-------------|---------------|----------------|
| alle | Gesamt | 25,68 | 25,90 | +0,22 |
| alle | Tag | 27,11 | 27,53 | +0,42 |
| alle | Nacht | 23,03 | 22,88 | −0,15 |
| Auswahl | Gesamt | 25,61 | 25,87 | +0,26 |
| Auswahl | Tag | 27,02 | 27,46 | +0,44 |
| Auswahl | Nacht | 22,99 | 22,90 | −0,09 |

Der Effekt ist klein. Tagsüber ist die begrünte Straße rund 0,4 °C kühler, über den Gesamtzeitraum
rund 0,2 bis 0,3 °C. Nachts kehrt sich das leicht um, die begrünte Straße ist dann um weniger als
0,2 °C wärmer. Anders als bei der Oberflächentemperatur ist die Streuung beider Straßen fast gleich
(sd tagsüber rund 4 °C bei beiden), unverschattete Flächen heizen die Luft also nicht so ungleich
auf wie die Oberflächen.

Absicherung über den gepaarten t-Test pro Runde, Auswahl 2, 4, 5, 7:

| Tageszeit | mittlere Differenz pro Runde | t-Test (gepaart) | signifikant |
|-----------|------------------------------|------------------|-------------|
| Gesamt | +0,26 °C | t = 2,34; df = 39; p = 0,024; 95 % KI [0,04; 0,48] | ja |
| Tag | +0,44 °C | t = 2,81; df = 25; p = 0,0096; 95 % KI [0,12; 0,77] | ja |
| Nacht | −0,09 °C | t = −3,99; df = 13; p = 0,0015; 95 % KI [−0,13; −0,04] | ja |

Tagsüber und über den Gesamtzeitraum ist die begrünte Straße signifikant kühler. Nachts ist sie
signifikant, aber nur minimal wärmer (rund 0,09 °C). Der Nachteffekt ist statistisch klar, weil die
Nachtwerte sehr eng streuen, physikalisch ist er aber sehr klein und passt zur bekannten Beobachtung,
dass Bäume die nächtliche Abkühlung leicht bremsen.

## Kennzahlen je Straße

Vollständige Kennzahlen (Median und Co.), berechnet auf den Rundenmitteln. Alle Werte in °C, außer
n (Anzahl der Runden). Q25 und Q75 sind das untere und obere Viertel, IQR ihr Abstand.

| Stationen | Tageszeit | Straße | n | Min | Q25 | Median | Mittel | Q75 | Max | sd | IQR |
|-----------|-----------|--------|---|-----|-----|--------|--------|-----|-----|----|----|
| alle | Gesamt | begrünt | 40 | 20,9 | 22,5 | 25,0 | 25,7 | 28,4 | 34,2 | 3,81 | 5,9 |
| alle | Gesamt | unbegrünt | 40 | 21,0 | 22,6 | 24,9 | 25,9 | 28,5 | 33,6 | 3,99 | 5,8 |
| alle | Tag | begrünt | 26 | 20,9 | 24,3 | 27,5 | 27,1 | 29,6 | 34,2 | 3,97 | 5,4 |
| alle | Tag | unbegrünt | 26 | 21,0 | 25,1 | 27,5 | 27,5 | 30,6 | 33,6 | 4,02 | 5,5 |
| alle | Nacht | begrünt | 14 | 21,2 | 22,1 | 22,9 | 23,0 | 24,0 | 25,0 | 1,26 | 1,9 |
| alle | Nacht | unbegrünt | 14 | 21,1 | 21,9 | 22,8 | 22,9 | 23,8 | 24,9 | 1,21 | 1,9 |
| Auswahl | Gesamt | begrünt | 40 | 20,9 | 22,4 | 24,9 | 25,6 | 28,2 | 33,8 | 3,77 | 5,8 |
| Auswahl | Gesamt | unbegrünt | 40 | 20,9 | 22,5 | 24,9 | 25,9 | 28,4 | 33,4 | 3,98 | 6,0 |
| Auswahl | Tag | begrünt | 26 | 20,9 | 24,2 | 27,3 | 27,0 | 29,6 | 33,8 | 3,93 | 5,4 |
| Auswahl | Tag | unbegrünt | 26 | 20,9 | 25,0 | 27,5 | 27,5 | 30,7 | 33,4 | 4,05 | 5,7 |
| Auswahl | Nacht | begrünt | 14 | 21,1 | 22,1 | 22,9 | 23,0 | 23,9 | 24,9 | 1,23 | 1,8 |
| Auswahl | Nacht | unbegrünt | 14 | 21,1 | 22,0 | 22,8 | 22,9 | 23,8 | 24,9 | 1,21 | 1,9 |

An den Kennzahlen sieht man, dass sich die beiden Straßen bei der Lufttemperatur nur wenig
unterscheiden. Median, Streuung (sd, IQR) und Spannweite liegen jeweils dicht beieinander, tagsüber
ist die unbegrünte Straße nur leicht wärmer, nachts kehrt sich das minimal um.

## Kurzinterpretation

Die begrünte Straße ist bei der Lufttemperatur tagsüber signifikant, aber nur wenig kühler (rund
0,4 °C), nachts sogar minimal wärmer. Der Effekt ist deutlich kleiner als bei der
Oberflächentemperatur, wo der Unterschied tagsüber rund 3,5 bis 4,6 °C beträgt. Das passt zum
physikalischen Bild: Bäume beschatten Boden und Fassade direkt, die Luft mischt sich dagegen und
gleicht die Unterschiede weitgehend aus. Alle Aussagen gelten für den kurzen Kampagnenzeitraum von
rund 40 Stunden.

## Begriffe kurz erklärt

**Boxplot:** eine Darstellung der Verteilung von Werten. Die Box umfasst die mittleren 50 Prozent
(vom unteren zum oberen Viertel), die Linie in der Box ist der Median, die Antennen reichen bis zu
den noch typischen Werten, und einzelne Punkte darüber oder darunter sind Ausreißer.

**Rundenmittel:** je Runde und Straße ein Wert, gebildet als Mittel der Stationen dieser Straße in
dieser Runde. Die Runde ist damit die Beobachtungseinheit (40 Werte je Straße).

**Median:** der mittlere Wert, wenn man alle Messungen der Größe nach sortiert. Robuster gegen
Extremwerte als der Mittelwert.

**Mittelwert (Mittel):** der Durchschnitt aller Werte.

**Quartile (Q25, Q75):** das untere und obere Viertel. Sie bilden Unter- und Oberkante der Box.

**IQR (Interquartilsabstand):** der Abstand zwischen Q75 und Q25, die Streuung der mittleren
50 Prozent.

**Standardabweichung (sd):** ein Maß dafür, wie stark die Werte um den Mittelwert streuen.

**Gepaarter t-Test:** ein Test, der zwei zusammengehörige Messreihen vergleicht, hier je Runde den
Wert der begrünten und der unbegrünten Straße. Geprüft wird, ob die mittlere Differenz von null
verschieden ist.

**p-Wert:** die Wahrscheinlichkeit, einen so großen Unterschied rein zufällig zu beobachten, wenn
es in Wirklichkeit keinen gäbe. Ein Wert unter 0,05 gilt als statistisch signifikant.

**Konfidenzintervall (KI):** der Bereich, in dem der wahre Unterschied mit 95 Prozent Sicherheit
liegt. Schließt er die null nicht ein, ist der Unterschied signifikant.

**Pseudoreplikation:** ein Fehler, bei dem nicht unabhängige Messungen als unabhängig behandelt
werden. Die Stationen einer Straße in derselben Runde sind ähnlich, deshalb werden sie zu einem
Rundenmittel zusammengefasst.

## Erzeugte Dateien

Sechs einzelne Grafiken im Ordner `plots/`:

| Datei | Stationen | Tageszeit |
|-------|-----------|-----------|
| `lufttemperatur_boxplot_alle_gesamt.png` | alle | Gesamt |
| `lufttemperatur_boxplot_alle_tag.png` | alle | Tag |
| `lufttemperatur_boxplot_alle_nacht.png` | alle | Nacht |
| `lufttemperatur_boxplot_auswahl_gesamt.png` | Auswahl 2, 4, 5, 7 | Gesamt |
| `lufttemperatur_boxplot_auswahl_tag.png` | Auswahl 2, 4, 5, 7 | Tag |
| `lufttemperatur_boxplot_auswahl_nacht.png` | Auswahl 2, 4, 5, 7 | Nacht |
