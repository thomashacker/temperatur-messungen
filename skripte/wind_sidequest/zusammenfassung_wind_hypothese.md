# Zusammenfassung: Wind-Hypothese zur Lufttemperatur

**Datum:** 2026-07-15
**Fasst zusammen:** `wind_mischung_strassenvergleich.md` (Teil 1) und
`wind_effekt_strahlungskontrolle.md` (Teil 2), mit Bezug auf `lufttemperatur_strassenvergleich.md`.

## Ausgangsbeobachtung

In der Lufttemperatur-Grafik der Auswahl ist die begrünte Straße am 19.06. gegen 15 Uhr kurz wärmer
als die unbegrünte, obwohl sie sonst kühler ist. Die Frage war: ist das ein Messfehler, oder spielen
andere Faktoren wie der Wind hinein? Die Vermutung lautete, dass es in der begrünten Straße
windstiller ist, die Luft dort also schlechter abgeführt wird und sich stärker aufheizen kann.

## Was untersucht wurde

Teil 1 vergleicht Wind und Durchmischung der beiden Straßen. Teil 2 prüft, ob der Wind über den
Schatteneffekt hinaus einen eigenständigen, wärmenden Beitrag liefert, indem die Einstrahlung
herausgerechnet wird. Grundlage ist jeweils die Auswahl der Stationen 2, 4, 5, 7.

## Zentrale Ergebnisse

**Die Voraussetzung der Hypothese stimmt.** Die begrünte Straße ist deutlich windstiller und
schlechter durchmischt.

| Größe | begrünt | unbegrünt |
|-------|---------|-----------|
| Windgeschwindigkeit (m/s) | 0,46 | 0,84 |
| Turbulenz TKE (m²/s²) | 0,086 | 0,154 |
| Wärmefluss nach oben (m·K/s) | -0,0008 | 0,0045 |

**Der Temperaturunterschied wird aber vom Schatten bestimmt, nicht vom Wind.** In der paarweisen
Regression pro Runde (dTa ~ dShortIn + dWind) bleibt nur die Einstrahlung signifikant
(+0,0042 °C je W/m², p = 0,0015). Der Wind verliert nach Kontrolle der Einstrahlung seine Bedeutung
(p = 0,10) und sein Vorzeichen zeigt sogar in die andere Richtung. Windstiller geht in diesen Daten
mit kühler einher, nicht mit wärmer, weil windstill und kühl gemeinsam nachts und im Schatten
auftreten.

**Der 15-Uhr-Spike ist kein Messfehler.** Er beruht auf einer einzigen Runde (Runde 22). Alle vier
begrünten Stationen sind dort konsistent wärmer als die vier unbegrünten, ein defekter Sensor würde
dagegen einen einzelnen Ausreißer erzeugen. Untypisch ist die Runde aus drei Gründen: die Straßen
wurden mit rund einer halben Stunde Zeitversatz gemessen (begrünt 15:00 bis 15:20, unbegrünt 15:29
bis 15:49), die Bewölkung war wechselhaft (Einstrahlung springt von 786 auf 73 W/m²), und hinter dem
Punkt steht nur diese eine Runde.

## Fazit

Die Wind-Hypothese ist physikalisch plausibel und in der Literatur beschrieben, und ihre
Voraussetzung ist belegt: die begrünte Straße ist klar windstiller. Ein eigenständiger, wärmender
Windbeitrag lässt sich in dieser kurzen Kampagne aber nicht nachweisen, weil der Schatteneffekt so
stark dominiert und Straße und Wind kaum zu trennen sind. Der auffällige 15-Uhr-Spike ist kein
Messfehler, sondern eine echte, aber nicht repräsentative Einzelrunde unter wechselhaften
Bedingungen mit Zeitversatz zwischen den Straßen.

## Hypothese (weiterentwickelt)

Aus den Ergebnissen ergibt sich eine geschärfte Hypothese. Die begrünte Straße ist überwiegend
kühler, weil die Bäume die Einstrahlung abschirmen (Schatteneffekt, klar dominierend, besonders an
der Oberfläche mit rund 2,6 °C, aber auch in der Luft mit rund 0,5 °C). Die geringere Durchlüftung
dämpft diese Kühlung bei der Lufttemperatur nur ab, was erklärt, warum der Luft-Effekt viel kleiner
ist als der Oberflächen-Effekt. Sie kehrt ihn aber im Mittel nicht um. Einzelne Momente, in denen
die begrünte Straße wärmer erscheint, entstehen vor allem durch das Messdesign, nämlich den
Zeitversatz zwischen den Straßen unter wechselnder Bewölkung, und nicht durch eine systematische
windbedingte Aufheizung.

## Woran es liegen könnte

Mehrere Ursachen wirken zusammen und lassen sich mit den jetzigen Daten nicht sauber trennen.

1. **Messdesign.** Die Stationen werden nacheinander besucht, deshalb liegen zwischen den beiden
Straßen einer Runde rund 30 Minuten. Bei sich änderndem Wetter verzerrt das den direkten Vergleich.

2. **Wechselnde Bewölkung.** Durchziehende Wolken mit Sonnenlücken erzeugen stark schwankende
Einstrahlung und damit verrauschte Momentaufnahmen einzelner Runden.

3. **Dominanter Schatteneffekt.** Der Energieeintrag über die Sonne bestimmt die Temperatur so stark,
dass der kleinere Windeffekt daneben untergeht.

4. **Beschatteter Strahlungssensor.** Der Sensor unter dem Kronendach misst selbst mittags wenig
(begrünt maximal rund 160 W/m², unbegrünt rund 650), deshalb ist die gemessene Einstrahlung der
begrünten Straße kein sauberes Maß für den tatsächlichen Energieeintrag.

5. **Kurzer Zeitraum und Kollinearität.** Rund 40 Stunden und zwei Straßen, bei denen die begrünte
Straße gerade die windstille Bedingung ist, reichen nicht, um Wind und Straße statistisch zu trennen.

## Empfehlung für die nächsten Schritte

Den tatsächlichen Sonnen- und Schatteneintrag pro Station über die `shadowmaps` schätzen, statt sich
auf den beschatteten Sensor zu verlassen. Den Straßenvergleich zeitlich synchronisieren, etwa indem
die Werte auf eine gemeinsame Uhrzeit bezogen werden, um den Zeitversatz zu entfernen. Und, wenn
möglich, eine längere Messreihe mit mehr Runden je Stunde, damit einzelne Runden weniger Gewicht
haben.

## Begriffe kurz erklärt

**Durchlüftung / Ventilation:** der Luftaustausch im Straßenraum. Viel Wind und Turbulenz führen
Wärme schnell ab, wenig Wind lässt die Luft eher stehen.

**Schatteneffekt:** die Kühlung dadurch, dass Bäume einen Teil der Sonneneinstrahlung abhalten.

**Turbulenz / TKE:** ein Maß für die Verwirbelung der Luft und damit die Durchmischung.

**Kollinearität:** wenn zwei Einflussgrößen so eng zusammenhängen, dass ihr Beitrag statistisch nicht
zu trennen ist. Hier fallen begrünte Straße und windstill praktisch zusammen.

**Repräsentativ:** ob eine Messung den typischen Zustand widerspiegelt. Eine einzelne Runde unter
wechselnder Bewölkung ist wenig repräsentativ.

## Quellen (Literatur zum Mechanismus)

[Baum-Drag und Kühlung im Straßenkanyon](https://www.sciencedirect.com/science/article/abs/pii/S0360132324007558),
[nächtliches Straßenkanyon-Mikroklima im Windkanal](https://www.sciencedirect.com/science/article/pii/S2212095523001220),
[Trennung von Strahlung, Verdunstung und Rauigkeit](https://www.sciencedirect.com/science/article/pii/S1618866720307871),
[Kühlwirkung von Bäumen über Städte hinweg](https://www.nature.com/articles/s43247-024-01908-4).

## Grundlage

Kampagnendaten `campaign_2026.rds`, Auswahl der Stationen 2, 4, 5, 7, Zeitraum 18. bis 20.06.2026.
Details in den beiden zusammengefassten Berichten und in `lufttemperatur_strassenvergleich.md`.
