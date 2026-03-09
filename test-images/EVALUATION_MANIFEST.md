# AskFin Test Image Evaluation Manifest

Last updated: 2026-03-09

## Purpose

Structured dataset for testing the AskFin analysis pipeline on real and mock screenshots.
Use with the Real Question Test harness (Settings > Developer > Real Question Test).

---

## Real Images (test-images/real/)

### bildfrage_1.png

| Field | Value |
|---|---|
| Source | Führerscheintest desktop app (green UI) |
| Type | Traffic situation with image |
| Question | "Welches Verhalten ist richtig?" |
| Answer format | Checkbox (3 options, no letter prefix) |
| Expected answers | 3 |
| Expected category | Right of Way |
| Correct answer(s) | "Ich muss den Radfahrer durchfahren lassen" + "Ich muss den Motorradfahrer durchfahren lassen" |
| OCR difficulty | HIGH |
| Parser challenge | Checkboxes rendered as squares, no A/B/C prefix. Multi-line answers. Heavy UI chrome (timer, score, question grid at bottom). OCR will pick up "0:00:28", "Führerscheintest - Frage: 6", "Punkte: 5", "noch 25 Aufgaben", "Grundstoff", "Klasse B", number grid 1-30. |
| Category keywords | "Radfahrer", "Motorradfahrer", "durchfahren lassen", "abbiegen" |
| Notes | Multiple correct answers (multi-select). Parser must handle checkbox format. Significant UI noise from test framework chrome. Image contains traffic situation drawing that OCR cannot interpret. "Motorradfahrer" appears in orange/red highlight color which may affect OCR. |

### bildfrage_2.png

| Field | Value |
|---|---|
| Source | fahrschule.freenet.de mobile website (iPhone screenshot) |
| Type | Text question with illustration |
| Question | "Es fängt an zu regnen. Warum müssen Sie den Sicherheitsabstand sofort vergrößern?" |
| Answer format | A / B / C (letter prefix, no parenthesis/period) |
| Expected answers | 3 |
| Expected category | Distance |
| Correct answer(s) | A + C (Sicht + Schmierfilm) |
| OCR difficulty | MEDIUM |
| Parser challenge | Letters A/B/C appear as standalone on left side, answer text is in separate column. OCR may not link letter to text on same line. Multi-line answer text (A spans 4 lines). Phone UI chrome: "14:56", "WhatsApp", "freenet", "MOBILFUNK", battery. Illustration image (cartoon character) adds OCR noise. |
| Category keywords | "Sicherheitsabstand", "Bremsweg", "Sicht" |
| Notes | Multiple correct answers. "Sicherheitsabstand" is strong keyword for Distance category. Also contains "Bremsweg" (C) which could trigger Distance or Safety. Mobile screenshot with ads and navigation. |

### verkehrszeichen_1.png

| Field | Value |
|---|---|
| Source | fahrschule.freenet.de mobile website (iPhone screenshot) |
| Type | Traffic sign question with sign image |
| Question | "Was ist bei diesen Verkehrszeichen erlaubt?" |
| Answer format | A / B / C (letter prefix, no parenthesis/period) |
| Expected answers | 3 |
| Expected category | Traffic Signs |
| Correct answer | C ("Bewohner mit entsprechend nummeriertem Parkausweis dürfen hier parken") |
| OCR difficulty | MEDIUM |
| Parser challenge | Same layout as bildfrage_2 — letter on left, text on right. Multi-line answers (A: 3 lines, B: 2 lines, C: 3 lines). Sign image contains "P" and "Bewohner mit Parkausweis Nr. IIIIIIIII" which OCR will extract as text mixed with question. Phone chrome: "15:17", battery, "freenet", "MOBILFUNK". |
| Category keywords | "Verkehrszeichen", "Parkplätze", "parken" |
| Notes | Also touches Parking category ("Parkplätze", "parken"). Primary category should be Traffic Signs due to "Verkehrszeichen" in question text. Sign text "Bewohner mit Parkausweis" will appear in OCR output and may confuse parser (looks like answer text but is part of the sign). |

---

## Mock Images (test-images/mock/)

### bildfrage_1..5.png (5 files)

| Field | Value |
|---|---|
| Source | AskFin mock app UI |
| Type | Bildfrage (image-based question) |
| Layout | Clean card UI, "Bildfrage" header, question text, placeholder "Situationsbild" box, 3 checkbox answers |
| Answer format | Checkbox squares, no letter prefix |
| OCR difficulty | LOW |
| Parser challenge | Checkbox squares (□) as answer prefix — supported by current parser regex. Clean layout, minimal noise. |
| Example (mock 1) | Q: "Wie verhalten Sie sich in dieser Verkehrssituation?" / Answers: "Bremsen", "Weiterfahren", "Vorfahrt beachten" |

### screen_01..20.png (20 files)

| Field | Value |
|---|---|
| Source | AskFin mock app UI |
| Type | Theorieprüfung Simulation (exam simulation screens) |
| Layout | "Theorieprüfung Simulation" header, "Frage N:" label, question text, 3 checkbox answers, "Weiter" button |
| Answer format | Checkbox squares, no letter prefix |
| OCR difficulty | LOW |
| Parser challenge | "Frage 1:" prefix line will be included in question text by parser. "Weiter" button text may appear as answer line. Clean layout otherwise. |
| Example (screen_01) | Q: "Sie möchten nach rechts abbiegen. Was müssen Sie beachten?" / Answers: "Fußgänger auf dem Zebrastreifen", "Gegenverkehr", "Fahrzeuge hinter Ihnen" |

---

## Known Parser Challenges (Summary)

| Challenge | Affected images | Severity |
|---|---|---|
| No A/B/C/D prefix (checkbox format) | bildfrage_1.png, all mocks | HIGH — parser regex supports □ but OCR may render as different unicode |
| Standalone letter + separate text column | bildfrage_2.png, verkehrszeichen_1.png | HIGH — OCR may produce "A" and text on separate lines |
| Multi-line answer text | bildfrage_1.png, bildfrage_2.png, verkehrszeichen_1.png | MEDIUM — handled by multi-line append logic |
| UI chrome noise (timer, scores, navigation) | bildfrage_1.png | HIGH — many non-question lines will pollute OCR |
| Phone chrome (status bar, app headers) | bildfrage_2.png, verkehrszeichen_1.png | LOW — typically at top, question at bottom |
| Sign text in OCR output | verkehrszeichen_1.png | MEDIUM — "P", "Bewohner mit Parkausweis" mixed into question text |
| Multiple correct answers | bildfrage_1.png, bildfrage_2.png | N/A — not a parser issue, but solver must handle multi-select |
| "Weiter" / "Abgabe" buttons as text | all | LOW — one-word lines, won't match answer pattern |

---

## Evaluation Workflow

For each image, run through Real Question Test and record:

```
Image: ___
OCR Quality:    [ OK / PARTIAL / FAIL ]  chars: ___ lines: ___
Question Parse: [ OK / PARTIAL / FAIL ]  noise lines included: ___
Answer Count:   [ OK / WRONG ]           expected: ___ actual: ___
Category:       [ OK / WRONG / GENERAL ] expected: ___ actual: ___
Cat. Confidence: ___%  keywords: ___
Solver:         [ OK / UNAVAILABLE ]     (placeholder API expected)
Overall:        [ PASS / PARTIAL / FAIL ]
Notes: ___
```

## Priority Order for Testing

1. **verkehrszeichen_1.png** — cleanest real image, clear question + answers
2. **bildfrage_2.png** — mobile screenshot, A/B/C format, moderate noise
3. **bildfrage_1.png** — hardest case, checkbox format, heavy UI noise, multi-select
4. **Mock screen_01..05** — baseline: parser should handle these perfectly
