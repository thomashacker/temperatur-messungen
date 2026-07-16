# Lufttemperatur aus den stationären nMetos-Daten: gibt es den 15-Uhr-Peak?

**Skript:** `skripte/lufttemperatur_stationaer.R`
**Datum:** 2026-07-16

## Fragestellung

Die mobile HuMVe-Messung besucht die acht Stationen nacheinander, deshalb liegen zwischen den beiden
Straßen einer Runde rund 30 Minuten. Bei wechselndem Wetter verzerrt das den direkten Vergleich, und
genau daraus entstand vermutlich der 15-Uhr-Peak, bei dem die begrünte Straße kurz wärmer erschien
(siehe `lufttemperatur_strassenvergleich.md` und `einstrahlung_zeitverlauf.md`). Die stationären
nMetos-Stationen messen dagegen kontinuierlich und für beide Straßen gleichzeitig. Damit lässt sich
prüfen, ob der Peak echt ist oder ein Artefakt des mobilen Messtimings.

## Verwendete Daten

Kampagnendatei `campaign_2026.rds`, nur gültige Besuche (`visit_status == "ok"`). Verwendet werden
die vier stationären Lufttemperaturen (in °C), je zwei Stationen pro Straße:

Begrünte Straße (Husemann): `nMetos_husemann21_Ta_mean`, `nMetos_husemann30_Ta_mean`.
Unbegrünte Straße (Hagenauer): `nMetos_hagenauer2_Ta_mean`, `nMetos_hagenauer11_Ta_mean`.

Diese Werte sind an den jeweiligen Zeitstempel jeder Zeile gekoppelt, geben also die stationäre
Messung zum Zeitpunkt des Besuchs wieder. Weil in jeder Zeile alle vier stationären Werte zur selben
Uhrzeit vorliegen, lassen sich die beiden Straßen zum selben Zeitpunkt vergleichen. Zum Vergleich
dient außerdem die mobile Lufttemperatur `humve_meteo_Ta_mean`.

## Aggregation / Methode

Je Straße wird das Mittel der zwei stationären Stationen gebildet, dann das Stundenmittel über den
echten Zeitverlauf. Grafik 1 zeigt beide Straßen im Zeitverlauf. Grafik 2 zeigt die Differenz begrünt
minus unbegrünt getrennt für die mobile und die stationäre Quelle, sodass man direkt sieht, wo beide
übereinstimmen und wo nicht.

Für die Boxplots und die Kennzahlen wird wie bei den mobilen Daten auf Rundenebene aggregiert: pro
Runde und Straße ein Wert (Mittel der zwei Stationen über die Runde), also 40 Werte je Straße. Das
vermeidet Pseudoreplikation und ist konsistent mit dem gepaarten t-Test. Da die stationären Stationen
feste Standorte sind, gibt es keinen Alle- und Auswahl-Split wie bei den mobilen Boxplots, sondern nur
die drei Tageszeiten Gesamt, Tag und Nacht.

## Ergebnisse

Die begrünte Straße bleibt in den stationären Daten über den ganzen Tag kühler, glatt und ohne
Sprung. Am mobilen Peak-Zeitpunkt (15 Uhr) gibt es keine Kreuzung.

Differenz begrünt minus unbegrünt am 19.06. (positiv bedeutet begrünte Straße wärmer):

| Uhrzeit | mobil | stationär |
|---------|-------|-----------|
| 10:00 | −1,93 | −2,14 |
| 11:00 | −1,80 | −1,88 |
| 12:00 | −1,70 | −1,78 |
| 13:00 | −0,79 | −1,44 |
| 14:00 | −0,43 | −1,19 |
| **15:00** | **+2,24** | **−1,08** |
| 16:00 | −1,02 | −0,94 |
| 17:00 | −0,37 | −0,75 |
| 18:00 | −0,33 | −0,72 |

Zu jeder Stunde stimmen beide Quellen im Vorzeichen überein, die begrünte Straße ist kühler. Nur um
15 Uhr springt der mobile Wert auf +2,24, während die stationäre Kurve glatt bei −1,08 bleibt und
sich nahtlos in ihre Nachbarwerte einfügt. Der Peak existiert also allein in der mobilen Messung.

Gepaarter t-Test pro Runde, stationär (unbegrünt minus begrünt): mittlere Differenz +0,58 °C,
t = 6,92; df = 39; p = 2,7e-08; 95 % Konfidenzintervall [0,41; 0,74]. Die unbegrünte Straße ist also
auch stationär signifikant wärmer, und zwar praktisch gleich stark wie in der mobilen Messung
(dort rund +0,50 °C). Die beiden unabhängigen Messsysteme bestätigen sich gegenseitig.

## Kennzahlen je Straße (stationär)

Die Boxplots (drei Dateien für Gesamt, Tag, Nacht) und die folgenden Tabellen beruhen auf den
Rundenmitteln, je Straße 40 Werte.

Mittlere Lufttemperatur je Gruppe und Differenz (unbegrünt minus begrünt, positiv = unbegrünt wärmer):

| Tageszeit | begrünt (°C) | unbegrünt (°C) | Differenz (°C) |
|-----------|-------------|---------------|----------------|
| Gesamt | 25,26 | 25,84 | +0,58 |
| Tag | 26,67 | 27,45 | +0,78 |
| Nacht | 22,64 | 22,84 | +0,20 |

Vollständige Kennzahlen (Median und Co.), alle Werte in °C außer n (Anzahl Runden):

| Tageszeit | Straße | n | Min | Q25 | Median | Mittel | Q75 | Max | sd | IQR |
|-----------|--------|---|-----|-----|--------|--------|-----|-----|----|----|
| Gesamt | begrünt | 40 | 20,6 | 22,1 | 24,5 | 25,3 | 27,9 | 32,5 | 3,76 | 5,8 |
| Gesamt | unbegrünt | 40 | 20,7 | 22,2 | 24,8 | 25,8 | 28,5 | 33,9 | 4,19 | 6,4 |
| Tag | begrünt | 26 | 20,6 | 23,5 | 26,5 | 26,7 | 29,4 | 32,5 | 3,93 | 5,9 |
| Tag | unbegrünt | 26 | 20,7 | 24,4 | 27,3 | 27,5 | 30,8 | 33,9 | 4,34 | 6,5 |
| Nacht | begrünt | 14 | 20,9 | 21,8 | 22,5 | 22,6 | 23,5 | 24,5 | 1,16 | 1,7 |
| Nacht | unbegrünt | 14 | 21,0 | 21,9 | 22,8 | 22,8 | 23,8 | 24,9 | 1,24 | 1,9 |

Gepaarter t-Test pro Runde, stationär, je Tageszeit:

| Tageszeit | mittlere Differenz | t-Test (gepaart) | signifikant |
|-----------|--------------------|--------------------|-------------|
| Gesamt | +0,58 °C | t = 6,92; df = 39; p = 2,7e-08; 95 % KI [0,41; 0,74] | ja |
| Tag | +0,78 °C | t = 7,25; df = 25; p = 1,3e-07; 95 % KI [0,56; 1,00] | ja |
| Nacht | +0,20 °C | t = 6,04; df = 13; p = 4,2e-05; 95 % KI [0,13; 0,27] | ja |

Anders als bei der mobilen Messung ist die unbegrünte Straße hier auch nachts signifikant wärmer
(+0,20 °C). Die mobile Messung hatte nachts einen sehr kleinen Gegeneffekt gezeigt (die begrünte
Straße um rund 0,09 °C wärmer). Beide Nachtwerte sind winzig, und die beiden Messsysteme stehen an
etwas anderen Standorten, deshalb ist ein Vorzeichenwechsel bei so kleinen Unterschieden nicht
überraschend. Tagsüber sind sich beide Systeme einig, die unbegrünte Straße ist klar wärmer.

## Kurzinterpretation

Der 15-Uhr-Peak ist ein Artefakt des mobilen Messtimings, kein reales Phänomen. Die gleichzeitig
messenden stationären Stationen zeigen die begrünte Straße durchgehend kühler, ohne jeden Sprung um
15 Uhr. Damit ist die frühere Erklärung bestätigt: die mobile Messung besuchte die begrünte Straße
rund eine halbe Stunde vor der unbegrünten, und in diese Lücke fiel am 19.06. eine durchziehende
Wolke, die die offene Straße kurz abkühlte. Über den Gesamtzeitraum stimmen mobile und stationäre
Messung sehr gut überein, die unbegrünte Straße ist rund 0,5 bis 0,6 °C wärmer. Alle Aussagen gelten
für den kurzen Kampagnenzeitraum von rund 40 Stunden.

## Begriffe kurz erklärt

**Stationäre Messung (nMetos):** feste Wetterstationen, die kontinuierlich und für alle Standorte
gleichzeitig messen, hier zwei je Straße.

**Mobile Messung (HuMVe):** ein fahrbarer Messwagen, der die Stationen nacheinander anfährt, wodurch
zwischen den Straßen ein Zeitversatz entsteht.

**Stundenmittel:** der Durchschnitt aller Messungen innerhalb einer Stunde, hier je Straße. Er bildet
die Linie in der Grafik.

**Rundenmittel:** je Runde und Straße ein Wert, Grundlage der Boxplots und Kennzahlen (40 Werte je Straße).

**Boxplot:** zeigt die Verteilung. Die Box umfasst die mittleren 50 Prozent, die Linie darin ist der
Median, die Antennen reichen bis zu den noch typischen Werten, Punkte darüber oder darunter sind Ausreißer.

**Median:** der mittlere Wert der sortierten Messungen. **Mittelwert (Mittel):** der Durchschnitt.
**Quartile (Q25, Q75):** unteres und oberes Viertel, die Ränder der Box. **IQR:** der Abstand
zwischen Q75 und Q25. **Standardabweichung (sd):** Maß für die Streuung um den Mittelwert.

**Gepaarter t-Test:** ein Test, der je Runde die beiden Straßen vergleicht und prüft, ob die mittlere
Differenz von null verschieden ist.

**p-Wert:** die Wahrscheinlichkeit, einen so großen Unterschied rein zufällig zu beobachten. Ein Wert
unter 0,05 gilt als statistisch signifikant. **Konfidenzintervall (KI):** der Bereich, in dem der
wahre Unterschied mit 95 Prozent Sicherheit liegt.

**Artefakt:** ein scheinbarer Effekt, der nicht aus der Sache selbst stammt, sondern aus der Art der
Messung.

## Erzeugte Dateien

`plots/lufttemperatur_stationaer_zeitverlauf.png` (stationäre Lufttemperatur, beide Straßen)
`plots/lufttemperatur_mobil_vs_stationaer_differenz.png` (Straßendifferenz mobil vs. stationär)
`plots/lufttemperatur_stationaer_boxplot_gesamt.png` (Boxplot, Gesamt)
`plots/lufttemperatur_stationaer_boxplot_tag.png` (Boxplot, Tag)
`plots/lufttemperatur_stationaer_boxplot_nacht.png` (Boxplot, Nacht)
