# Oberflächentemperatur: Boden vs. Wand nach Straßentyp

**Skript:** `skripte/oberflaeche_boxplot.R`
**Datum:** 2026-07-15

## Verwendete Daten

Quelle ist die Kampagnendatei `campaign_2026.rds` (Objekt `M$data`). Die Oberflächentemperatur
stammt aus den vier Handmessungen je Stationsbesuch (`manual_Ts_1` bis `manual_Ts_4`, entspricht
dem ODK-Feld `oberflaechentemp_1..4`, in °C). Der Boden ergibt sich als Mittel der Punkte 1, 2 und
3, die Wand ist Punkt 4. So entsteht pro Besuch ein Boden- und ein Wandwert mit gleichem Gewicht.

Berücksichtigt sind nur gültige Stationsbesuche (`visit_status == "ok"`). Der Messzeitraum reicht
vom 18.06.2026, 18:00 Uhr bis zum 20.06.2026, 09:47 Uhr (Ortszeit). Die Straßenzuordnung erfolgt
über `station_order`: die Stationen 1 bis 4 bilden die begrünte Straße (Husemann), die Stationen 5
bis 8 die unbegrünte Straße (Hagenauer).

Zwei Aufteilungen werden nebeneinander gezeigt. Erstens die Stationsauswahl: alle acht Stationen
gegenüber der Auswahl 2, 4, 5, 7, aus der die stark besonnten Stationen 1, 3, 6 und 8 entfernt
sind. Zweitens die Tageszeit: Gesamt, Tag und Nacht, wobei Tag als 05 bis 22 Uhr definiert ist und
Nacht als 22 bis 05 Uhr.

## Aggregation / Methode

Wichtig ist die Beobachtungseinheit. Pro Runde und Straße werden die Stationen zu einem Wert
gemittelt, getrennt für Boden und Wand. Damit ist die Runde die Einheit, es gibt je Straße 40 Werte
(eine je Runde), nicht die einzelnen Stationsbesuche. Das vermeidet Pseudoreplikation, denn die zwei
bis vier Stationen einer Straße in derselben Runde sind keine unabhängigen Messungen, und es ist
konsistent mit dem gepaarten t-Test. Jede Runde wird über ihre mittlere Uhrzeit dem Tag (05 bis
22 Uhr) oder der Nacht zugeordnet.

Es entstehen sechs einzelne Grafiken, je eine pro Kombination aus Stationsauswahl (alle, Auswahl)
und Tageszeit (Gesamt, Tag, Nacht). In jeder Grafik steht auf der x-Achse der Oberflächentyp
(Boden, Wand), auf der y-Achse die Oberflächentemperatur, und die Farbe unterscheidet die beiden
Straßen (grün für begrünt, grau für unbegrünt). Jeder Boxplot zeigt die Verteilung der 40
Rundenmittel je Straße. Alle sechs Grafiken nutzen dieselbe y-Achse, damit sie direkt vergleichbar
sind.

Für die Kernaussage wird die mittlere Differenz gebildet, Konvention unbegrünt minus begrünt. Ein
positiver Wert bedeutet, dass die begrünte Straße kühler ist. Zusätzlich wird die zentrale
Tageshypothese gepaart pro Runde geprüft.

Hinweis zur Methode: Eine frühere Fassung bildete Boxplots und Kennzahlen über die einzelnen
Stationsbesuche (n = 160 bzw. 80). Die Mittelwerte sind dabei fast identisch, aber die Streuung
(sd, IQR) und die Maxima fielen größer aus, weil jede Station einzeln einging. Die jetzige Fassung
auf Rundenebene ist methodisch sauberer und passt zum Signifikanztest.

## Ergebnisse

Mittlere Oberflächentemperatur je Gruppe und Differenz (begrünte Straße kühler, wenn positiv):

| Stationen | Tageszeit | Typ | begrünt (°C) | unbegrünt (°C) | Differenz (°C) |
|-----------|-----------|-----|-------------|---------------|----------------|
| alle | Gesamt | Boden | 24,03 | 26,42 | **+2,39** |
| alle | Gesamt | Wand | 24,36 | 27,67 | **+3,31** |
| alle | Tag | Boden | 24,96 | 28,40 | **+3,44** |
| alle | Tag | Wand | 25,04 | 29,67 | **+4,63** |
| alle | Nacht | Boden | 22,31 | 22,75 | +0,44 |
| alle | Nacht | Wand | 23,10 | 23,95 | +0,86 |
| Auswahl | Gesamt | Boden | 23,22 | 25,58 | **+2,37** |
| Auswahl | Gesamt | Wand | 24,15 | 26,98 | **+2,82** |
| Auswahl | Tag | Boden | 23,84 | 27,30 | **+3,46** |
| Auswahl | Tag | Wand | 24,83 | 28,71 | **+3,88** |
| Auswahl | Nacht | Boden | 22,05 | 22,39 | +0,34 |
| Auswahl | Nacht | Wand | 22,90 | 23,75 | +0,85 |

Das Muster ist in beiden Stationssätzen gleich. Tagsüber ist die begrünte Straße deutlich kühler,
am Boden um rund 3,4 bis 3,5 °C und an der Wand um rund 3,9 bis 4,6 °C. Nachts schrumpft der
Unterschied auf weniger als 1 °C, die beiden Straßen gleichen sich also an. Die Auswahl verändert
das Tagesbild nur wenig, anders als bei der Lufttemperatur ist der Effekt hier auch über alle
Stationen schon groß. Die deutlich größere Streuung der unbegrünten Straße am Tag (Maxima der
Rundenmittel bis rund 39,7 °C an der Wand) zeigt zusätzlich, dass unverschattete Flächen in der
Sonne stark aufheizen.

Absicherung der Tageshypothese über den gepaarten t-Test pro Runde, Auswahl 2, 4, 5, 7, tagsüber:

| Typ | mittlere Differenz pro Runde | t-Test (gepaart) | signifikant |
|-----|------------------------------|------------------|-------------|
| Boden | +3,46 °C | t = 5,21; df = 25; p = 0,000022; 95 % KI [2,09; 4,83] | ja |
| Wand | +3,88 °C | t = 6,82; df = 25; p = 0,00000038; 95 % KI [2,71; 5,06] | ja |

Beide Unterschiede sind hoch signifikant.

## Kennzahlen je Oberflächentyp und Straße

Die folgenden Tabellen zeigen die vollständigen Kennzahlen (Median und Co.) getrennt nach Boden und
Wand, berechnet auf den Rundenmitteln. Alle Werte in °C, außer n (Anzahl der Runden). Q25 und Q75
sind das untere und obere Viertel, IQR ihr Abstand.

**Boden** (Mittel der Messpunkte 1, 2, 3):

| Stationen | Tageszeit | Straße | n | Min | Q25 | Median | Mittel | Q75 | Max | sd | IQR |
|-----------|-----------|--------|---|-----|-----|--------|--------|-----|-----|----|----|
| alle | Gesamt | begrünt | 40 | 20,3 | 21,4 | 23,4 | 24,0 | 25,8 | 30,6 | 3,05 | 4,4 |
| alle | Gesamt | unbegrünt | 40 | 20,7 | 21,9 | 25,0 | 26,4 | 29,1 | 38,6 | 5,46 | 7,2 |
| alle | Tag | begrünt | 26 | 20,3 | 22,8 | 24,8 | 25,0 | 27,2 | 30,6 | 3,35 | 4,4 |
| alle | Tag | unbegrünt | 26 | 20,7 | 23,7 | 27,5 | 28,4 | 33,0 | 38,6 | 5,81 | 9,2 |
| alle | Nacht | begrünt | 14 | 20,8 | 21,4 | 22,0 | 22,3 | 23,1 | 24,7 | 1,24 | 1,6 |
| alle | Nacht | unbegrünt | 14 | 20,8 | 21,8 | 22,3 | 22,8 | 23,7 | 25,8 | 1,47 | 2,0 |
| Auswahl | Gesamt | begrünt | 40 | 20,0 | 21,2 | 22,7 | 23,2 | 24,4 | 28,4 | 2,48 | 3,2 |
| Auswahl | Gesamt | unbegrünt | 40 | 20,0 | 21,6 | 23,6 | 25,6 | 28,6 | 37,3 | 5,23 | 7,1 |
| Auswahl | Tag | begrünt | 26 | 20,0 | 21,3 | 23,8 | 23,8 | 26,1 | 28,4 | 2,78 | 4,8 |
| Auswahl | Tag | unbegrünt | 26 | 20,0 | 22,3 | 26,6 | 27,3 | 31,3 | 37,3 | 5,74 | 9,0 |
| Auswahl | Nacht | begrünt | 14 | 20,6 | 21,2 | 21,8 | 22,0 | 22,7 | 24,2 | 1,13 | 1,5 |
| Auswahl | Nacht | unbegrünt | 14 | 20,7 | 21,4 | 21,8 | 22,4 | 23,3 | 25,1 | 1,35 | 1,9 |

**Wand** (Messpunkt 4, Fassade):

| Stationen | Tageszeit | Straße | n | Min | Q25 | Median | Mittel | Q75 | Max | sd | IQR |
|-----------|-----------|--------|---|-----|-----|--------|--------|-----|-----|----|----|
| alle | Gesamt | begrünt | 40 | 21,2 | 22,5 | 23,8 | 24,4 | 25,8 | 29,8 | 2,50 | 3,4 |
| alle | Gesamt | unbegrünt | 40 | 21,9 | 23,7 | 26,8 | 27,7 | 30,1 | 39,7 | 4,80 | 6,4 |
| alle | Tag | begrünt | 26 | 21,2 | 22,7 | 25,0 | 25,0 | 27,6 | 29,8 | 2,75 | 4,9 |
| alle | Tag | unbegrünt | 26 | 21,9 | 26,7 | 29,1 | 29,7 | 33,2 | 39,7 | 4,77 | 6,5 |
| alle | Nacht | begrünt | 14 | 21,5 | 22,2 | 22,9 | 23,1 | 23,9 | 25,4 | 1,25 | 1,7 |
| alle | Nacht | unbegrünt | 14 | 21,9 | 22,7 | 23,5 | 24,0 | 25,1 | 27,1 | 1,58 | 2,4 |
| Auswahl | Gesamt | begrünt | 40 | 21,0 | 22,1 | 23,8 | 24,2 | 25,9 | 29,4 | 2,47 | 3,8 |
| Auswahl | Gesamt | unbegrünt | 40 | 21,4 | 22,8 | 25,4 | 27,0 | 29,5 | 38,6 | 4,93 | 6,7 |
| Auswahl | Tag | begrünt | 26 | 21,0 | 22,2 | 24,5 | 24,8 | 27,5 | 29,4 | 2,70 | 5,2 |
| Auswahl | Tag | unbegrünt | 26 | 21,4 | 24,1 | 28,8 | 28,7 | 33,2 | 38,6 | 5,26 | 9,1 |
| Auswahl | Nacht | begrünt | 14 | 21,0 | 22,0 | 22,7 | 22,9 | 23,7 | 25,3 | 1,28 | 1,6 |
| Auswahl | Nacht | unbegrünt | 14 | 21,5 | 22,6 | 23,3 | 23,8 | 25,0 | 26,8 | 1,58 | 2,3 |

An den Kennzahlen liest man das Muster der Boxplots direkt ab. Tagsüber liegt der Median der
unbegrünten Straße klar über dem der begrünten (Boden 27,5 gegen 24,8; Wand 29,1 gegen 25,0 bei allen
Stationen), und die unbegrünte Straße streut deutlich stärker (sd und IQR etwa doppelt so groß,
Maxima der Rundenmittel bis rund 39,7 °C). Nachts liegen Median und Streuung beider Straßen dicht
beieinander.

## Kurzinterpretation

Die Hypothese wird bestätigt. Die Oberflächentemperatur der begrünten Straße ist tagsüber klar
niedriger als die der unbegrünten Straße, am Boden wie an der Wand, mit rund 3,4 bis 4,6 °C
Unterschied und statistisch hoch signifikant. Nachts verschwindet der Unterschied nahezu, was zum
Bild eines Beschattungseffekts passt: Am Tag halten die Bäume die direkte Sonne von Boden und
Fassade ab, nachts fehlt diese Einstrahlung auf beiden Straßen. Alle Aussagen gelten für den kurzen
Kampagnenzeitraum von rund 40 Stunden.

## Begriffe kurz erklärt

**Boxplot:** eine Darstellung der Verteilung von Werten. Die Box umfasst die mittleren 50 Prozent
(vom unteren zum oberen Viertel), die Linie in der Box ist der Median, die Antennen (Whisker)
reichen bis zu den noch typischen Werten, und einzelne Punkte darüber oder darunter sind Ausreißer.

**Boden und Wand:** Boden ist der Mittelwert der drei bodennahen Messpunkte (`manual_Ts_1..3`),
Wand ist die Messung an der Fassade (`manual_Ts_4`).

**Rundenmittel:** je Runde und Straße ein Wert, gebildet als Mittel der Stationen dieser Straße in
dieser Runde. Die Runde ist damit die Beobachtungseinheit (40 Werte je Straße).

**Pseudoreplikation:** ein Fehler, bei dem nicht unabhängige Messungen als unabhängig behandelt
werden. Die Stationen einer Straße in derselben Runde sind ähnlich, deshalb werden sie zu einem
Rundenmittel zusammengefasst.

**Median:** der mittlere Wert, wenn man alle Messungen der Größe nach sortiert. Robuster gegen
Extremwerte als der Mittelwert.

**Mittelwert (Mittel):** der Durchschnitt aller Werte.

**Quartile (Q25, Q75):** das untere Viertel (25 Prozent der Werte liegen darunter) und das obere
Viertel (75 Prozent liegen darunter). Sie bilden die Ober- und Untergrenze der Box im Boxplot.

**IQR (Interquartilsabstand):** der Abstand zwischen Q75 und Q25, also die Streuung der mittleren
50 Prozent der Werte. Robust gegen Ausreißer.

**Standardabweichung (sd):** ein Maß dafür, wie stark die Werte um den Mittelwert streuen.

**Gepaarter t-Test:** ein Test, der zwei zusammengehörige Messreihen vergleicht, hier je Runde den
Wert der begrünten und der unbegrünten Straße. Geprüft wird, ob die mittlere Differenz von null
verschieden ist.

**p-Wert:** die Wahrscheinlichkeit, einen so großen Unterschied rein zufällig zu beobachten, wenn
es in Wirklichkeit keinen gäbe. Ein Wert unter 0,05 gilt als statistisch signifikant.

**Konfidenzintervall (KI):** der Bereich, in dem der wahre Unterschied mit 95 Prozent Sicherheit
liegt. Schließt er die null nicht ein, ist der Unterschied signifikant.

## Erzeugte Dateien

Sechs einzelne Grafiken im Ordner `plots/`:

| Datei | Stationen | Tageszeit |
|-------|-----------|-----------|
| `oberflaeche_boxplot_alle_gesamt.png` | alle | Gesamt |
| `oberflaeche_boxplot_alle_tag.png` | alle | Tag |
| `oberflaeche_boxplot_alle_nacht.png` | alle | Nacht |
| `oberflaeche_boxplot_auswahl_gesamt.png` | Auswahl 2, 4, 5, 7 | Gesamt |
| `oberflaeche_boxplot_auswahl_tag.png` | Auswahl 2, 4, 5, 7 | Tag |
| `oberflaeche_boxplot_auswahl_nacht.png` | Auswahl 2, 4, 5, 7 | Nacht |
