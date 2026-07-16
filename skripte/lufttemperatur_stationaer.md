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
übereinstimmen und wo nicht. Zusätzlich ein gepaarter t-Test pro Runde auf den stationären Daten.

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

**Gepaarter t-Test:** ein Test, der je Runde die beiden Straßen vergleicht und prüft, ob die mittlere
Differenz von null verschieden ist.

**p-Wert:** die Wahrscheinlichkeit, einen so großen Unterschied rein zufällig zu beobachten. Ein Wert
unter 0,05 gilt als statistisch signifikant.

**Artefakt:** ein scheinbarer Effekt, der nicht aus der Sache selbst stammt, sondern aus der Art der
Messung.

## Erzeugte Dateien

`plots/lufttemperatur_stationaer_zeitverlauf.png` (stationäre Lufttemperatur, beide Straßen)
`plots/lufttemperatur_mobil_vs_stationaer_differenz.png` (Straßendifferenz mobil vs. stationär)
