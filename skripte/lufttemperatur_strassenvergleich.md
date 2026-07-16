# Lufttemperatur: Begrünte vs. unbegrünte Straße

**Skript:** `skripte/lufttemperatur_strassenvergleich.R`
**Datum:** 2026-07-15

## Verwendete Daten

Quelle ist die Kampagnendatei `campaign_2026.rds` (Objekt `M$data`). Verwendet wird die mobil
gemessene Lufttemperatur `humve_meteo_Ta_mean` in °C. Berücksichtigt sind nur gültige
Stationsbesuche (`visit_status == "ok"`), also 317 der 320 Zeilen. Der Messzeitraum reicht vom
18.06.2026, 18:00 Uhr bis zum 20.06.2026, 09:47 Uhr (Ortszeit, rund 40 Stunden mit zwei Nächten).

Die Zuordnung zu den Straßen erfolgt über `station_order`. Die Stationen 1 bis 4 bilden die
begrünte Straße (Husemann), die Stationen 5 bis 8 die unbegrünte Straße (Hagenauer). Es werden
zwei Datensätze betrachtet: einmal alle acht Stationen und einmal die Auswahl 2, 4, 5, 7. Aus der
Auswahl entfernt sind die stark besonnten Stationen 1, 3, 6 und 8. Die Auswahl enthält je zwei
Stationen pro Straße und bleibt damit ausgewogen.

## Aggregation / Methode

Für die beiden Grafiken werden die Werte je Stunde und Straße gemittelt (Stundenmittel aus
`beginn_local_parsed`). Beide Grafiken teilen sich dieselbe x- und y-Achse, damit sie direkt
vergleichbar sind. Der gelbe Hintergrund markiert den Tag (05–22 Uhr), Weiß die Nacht.

Für die Statistik dienen die Rohwerte je Besuch (deskriptive Kennzahlen und Ausreißerprüfung nach
der 1,5·IQR-Regel). Der Straßenunterschied wird zusätzlich gepaart pro Runde geprüft. Dabei wird
je Runde ein Mittelwert pro Straße gebildet, sodass die 40 Runden die Vergleichseinheiten sind.
Das vermeidet die Pseudoreplikation, die entstünde, wenn man jede Einzelmessung als unabhängig
behandelt. Vorzeichenkonvention durchgehend: unbegrünt minus begrünt, ein positiver Wert bedeutet
also, die unbegrünte Straße ist wärmer (die Baumstraße kühler).

## Ergebnisse Teil 1: Alle Stationen gegen die Auswahl

Deskriptive Kennzahlen je Straße (Rohwerte je Besuch, in °C):

| Datensatz | Straße | n | min | max | Mittel | Median | sd | IQR | Spannweite |
|-----------|--------|---|-----|-----|--------|--------|----|-----|------------|
| alle | begrünt | 160 | 20,8 | 34,8 | 25,7 | 24,9 | 3,79 | 6,12 | 14,0 |
| alle | unbegrünt | 157 | 20,9 | 34,2 | 25,9 | 24,9 | 3,98 | 6,29 | 13,3 |
| Auswahl | begrünt | 80 | 20,8 | 34,8 | 25,6 | 24,8 | 3,76 | 6,07 | 14,0 |
| Auswahl | unbegrünt | 79 | 20,9 | 34,0 | 25,9 | 24,8 | 3,99 | 6,21 | 13,1 |

Nach der 1,5·IQR-Regel gibt es in keinem der vier Fälle Ausreißer (jeweils 0). Streuung (sd),
IQR und Spannweite ändern sich zwischen allen Stationen und der Auswahl nur minimal. Für die
Lufttemperatur reduziert die Auswahl also weder Ausreißer noch Streuung nennenswert.

Den klaren Vorteil zeigt der gepaarte Straßenvergleich:

| Datensatz | mittlere Differenz (unbegrünt minus begrünt) | t-Test (gepaart, pro Runde) | signifikant (α = 0,05) |
|-----------|----------------------------------------------|-----------------------------|------------------------|
| alle Stationen | +0,22 °C | t = 1,74; df = 39; p = 0,089; 95 % KI [−0,04; 0,48] | nein |
| Auswahl 2, 4, 5, 7 | +0,26 °C | t = 2,34; df = 39; p = 0,024; 95 % KI [0,04; 0,48] | ja |

Auf den Stundenmitteln (passend zur Grafik) beträgt die mittlere Differenz +0,200 °C für alle
Stationen und +0,220 °C für die Auswahl.

Kernaussage: Entfernt man die stark besonnten Stationen, wird der Kühleffekt der Baumstraße etwas
größer und vor allem statistisch gesichert (p sinkt von 0,089 auf 0,024, das Konfidenzintervall
schließt die Null nicht mehr ein). Über alle Stationen ist derselbe Unterschied nicht gesichert.
Die Auswahl liefert damit das klarere und belastbarere Signal, auch wenn die reine Streuung
gleich bleibt.

## Ergebnisse Teil 2: Statistik nur auf der Auswahl (2, 4, 5, 7)

Deskriptive Kennzahlen je Straße (Rohwerte je Besuch, in °C):

| Straße | n | min | max | Mittel | Median | sd | IQR | Spannweite |
|--------|---|-----|-----|--------|--------|----|-----|------------|
| begrünt | 80 | 20,8 | 34,8 | 25,6 | 24,8 | 3,76 | 6,07 | 14,0 |
| unbegrünt | 79 | 20,9 | 34,0 | 25,9 | 24,8 | 3,99 | 6,21 | 13,1 |

Mittlere Differenz pro Runde (unbegrünt minus begrünt): **+0,26 °C** über 40 Runden.

Gepaarter t-Test pro Runde: t = 2,34; df = 39; **p = 0,024**; 95 % Konfidenzintervall [0,04; 0,48].
Der Unterschied ist auf dem 5-Prozent-Niveau signifikant.

Wilcoxon-Vorzeichen-Rang-Test (Absicherung, verteilungsfrei): V = 527; **p = 0,057**. Er liegt
knapp über der 5-Prozent-Schwelle, stützt die Richtung des Ergebnisses aber.

## Kurzinterpretation

Die begrünte Straße ist im Mittel rund 0,26 °C kühler als die unbegrünte Straße. Der Effekt ist
für die Lufttemperatur klein, aber in der Auswahl statistisch gesichert. In der Grafik ist er vor
allem tagsüber sichtbar, wenn die grüne Linie in den heißen Mittags- und Nachmittagsstunden
deutlich unter der grauen liegt, während sich beide Straßen nachts angleichen. Der Vorteil der
Auswahl liegt nicht in weniger Ausreißern, sondern in einem klareren und belastbareren Signal.
Alle Aussagen gelten für den kurzen Kampagnenzeitraum von rund 40 Stunden.

## Einordnung des 15-Uhr-Spikes

In der Grafik der Auswahl fällt am 19.06. gegen 15 Uhr ein Punkt auf, an dem die begrünte Straße
wärmer ist als die unbegrünte. Dieser Punkt beruht auf einer einzigen Runde (Runde 22, 15:00 bis
15:49). Es handelt sich nicht um einen Sensorfehler: alle vier begrünten Stationen liegen konsistent
bei 32,7 bis 34,8 °C, alle vier unbegrünten bei 31,6 bis 32,2 °C. Ein defekter Sensor würde einen
einzelnen Ausreißer erzeugen, nicht vier gleichmäßig höhere Werte.

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

**Mittelwert (Mittel):** der Durchschnitt aller Werte.

**Median:** der mittlere Wert, wenn man alle Messungen der Größe nach sortiert. Er ist robuster
gegen einzelne Extremwerte als der Mittelwert.

**Standardabweichung (sd):** ein Maß dafür, wie stark die Werte um den Mittelwert streuen. Ein
großer Wert bedeutet viel Schwankung, ein kleiner Wert bedeutet, dass die Werte eng beieinander
liegen.

**IQR (Interquartilsabstand):** die Spannweite der mittleren 50 Prozent der Werte, also der
Abstand zwischen dem unteren Viertel (Q25) und dem oberen Viertel (Q75). Ein robustes Streuungsmaß.

**IQR-Regel (1,5·IQR):** eine Faustregel zum Erkennen von Ausreißern. Werte, die mehr als das
1,5-Fache des IQR unter Q25 oder über Q75 liegen, gelten als Ausreißer.

**Spannweite:** der Abstand zwischen dem kleinsten und dem größten Wert.

**Gepaarter t-Test:** ein Test, der zwei zusammengehörige Messreihen vergleicht, hier je Runde
den Wert der begrünten und der unbegrünten Straße. Geprüft wird, ob die mittlere Differenz
zwischen den Paaren von null verschieden ist.

**p-Wert:** die Wahrscheinlichkeit, einen so großen Unterschied rein zufällig zu beobachten, wenn
es in Wirklichkeit keinen gäbe. Ein kleiner p-Wert (unter 0,05) gilt als statistisch signifikant.

**Konfidenzintervall (KI):** der Bereich, in dem der wahre Unterschied mit 95 Prozent Sicherheit
liegt. Schließt das Intervall die null nicht ein, ist der Unterschied signifikant.

**Wilcoxon-Vorzeichen-Rang-Test:** eine verteilungsfreie Alternative zum t-Test. Er vergleicht die
Paare über Ränge statt über Mittelwerte und dient hier zur Absicherung, falls die Werte nicht
normalverteilt sind.

**Pseudoreplikation:** ein Fehler, bei dem nicht wirklich unabhängige Messungen als unabhängig
behandelt werden. Hier wird jeder Punkt 40-mal besucht, weshalb pro Runde gemittelt wird, damit
die Runden und nicht die Einzelmessungen die Vergleichseinheiten sind.

## Erzeugte Dateien

`plots/lufttemperatur_alle_stationen.png` (alle acht Stationen)
`plots/lufttemperatur_auswahl_stationen.png` (Auswahl 2, 4, 5, 7)
