# Oberflächentemperatur im Zeitverlauf: Boden und Wand

**Skript:** `skripte/oberflaeche_zeitverlauf.R`
**Datum:** 2026-07-16

## Verwendete Daten

Kampagnendatei `campaign_2026.rds`, nur gültige Besuche (`visit_status == "ok"`). Die
Oberflächentemperatur stammt aus den vier Handmessungen je Besuch (`manual_Ts_1` bis `manual_Ts_4`,
in °C). Der Boden ist das Mittel der Punkte 1, 2 und 3, die Wand ist Punkt 4. Betrachtet wird der
ganze Zeitverlauf der Kampagne (18. bis 20.06.2026). Wie bei den übrigen Skripten gibt es zwei
Stationsvarianten: alle acht Stationen und die Auswahl 2, 4, 5, 7 (ohne die stark besonnten
Stationen).

## Aggregation / Methode

Liniendiagramme im Stil der Lufttemperatur-Grafik, je eines für Boden und Wand, und das jeweils für
beide Stationsvarianten, also vier Grafiken. Je Grafik zeigt eine grüne Linie die begrünte und eine
graue Linie die unbegrünte Straße. Die Werte sind Stundenmittel je Straße über den echten
Zeitverlauf. Der gelbe Hintergrund markiert den Tag (05 bis 22 Uhr), Weiß die Nacht. Alle vier
Grafiken teilen dieselbe x- und y-Achse, damit Boden und Wand sowie beide Stationsvarianten direkt
vergleichbar sind.

## Ergebnisse

Beide Oberflächen zeigen dasselbe klare Muster: tagsüber ist die begrünte Straße deutlich kühler,
nachts gleichen sich beide Straßen an. Die folgenden Zahlen beziehen sich auf die Auswahl 2, 4, 5, 7.
Über alle Stationen ergibt sich dasselbe Bild, der Tagesabstand fällt tagsüber sogar etwas größer aus
(die unbegrünte Bodenkurve erreicht mittags rund 38,5 °C statt rund 37,3 °C).

Mittelwerte je Tageszeit (unbegrünt minus begrünt, positiv bedeutet begrünte Straße kühler):

| Oberfläche | Tag begrünt | Tag unbegrünt | Δ Tag | Nacht Δ |
|------------|-------------|---------------|-------|---------|
| Boden | 23,8 | 27,4 | +3,6 °C | +0,3 °C |
| Wand | 24,8 | 28,8 | +4,0 °C | +0,9 °C |

Noch deutlicher wird der Unterschied am Nachmittagshöhepunkt, wenn die Sonne am stärksten auf die
unverschatteten Flächen wirkt:

| Oberfläche | Zeitpunkt | begrünt | unbegrünt | Differenz |
|------------|-----------|---------|-----------|-----------|
| Boden | 19.06., 12:00 | 25,6 | 35,7 | **10,1 °C** |
| Wand | 19.06., 16:00 | 28,9 | 38,6 | **9,8 °C** |

Am Höhepunkt ist die begrünte Straße an Boden und Wand also rund 10 °C kühler. In der Nacht liegen
beide Linien fast übereinander.

## Kurzinterpretation

Die Grafiken zeigen den Beschattungseffekt der Bäume sehr eindrücklich. Solange die Sonne scheint,
heizen sich Boden und Wand der unbegrünten Straße stark auf, während die verschatteten Flächen der
begrünten Straße viel kühler bleiben, am Nachmittag um rund 10 °C. Nachts fehlt die Einstrahlung auf
beiden Straßen, weshalb sich die Oberflächen angleichen. Boden und Wand verhalten sich dabei sehr
ähnlich. Das passt zum viel stärkeren Effekt bei der Oberflächentemperatur im Vergleich zur
Lufttemperatur (siehe `oberflaeche_boxplot.md` und `lufttemperatur_strassenvergleich.md`). Alle
Aussagen gelten für den kurzen Kampagnenzeitraum von rund 40 Stunden.

## Begriffe kurz erklärt

**Boden und Wand:** Boden ist der Mittelwert der drei bodennahen Messpunkte (`manual_Ts_1..3`), Wand
ist die Messung an der Fassade (`manual_Ts_4`).

**Stundenmittel:** der Durchschnitt aller Messungen innerhalb einer Stunde, hier je Straße. Er bildet
die Linie in der Grafik.

**Zeitverlauf:** die Darstellung über die echte Uhrzeit der ganzen Kampagne, anders als beim
Tagesgang werden die Kampagnentage nicht zusammengefasst.

## Erzeugte Dateien

`plots/oberflaeche_zeitverlauf_boden_alle.png` (Boden, alle Stationen)
`plots/oberflaeche_zeitverlauf_boden_auswahl.png` (Boden, Auswahl 2, 4, 5, 7)
`plots/oberflaeche_zeitverlauf_wand_alle.png` (Wand, alle Stationen)
`plots/oberflaeche_zeitverlauf_wand_auswahl.png` (Wand, Auswahl 2, 4, 5, 7)
