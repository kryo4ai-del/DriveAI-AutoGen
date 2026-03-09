# AskFin Test Image Evaluation Manifest

Last updated: 2026-03-09

## Purpose

Structured dataset for testing the AskFin analysis pipeline on real and mock screenshots.
Use with the Real Question Test harness (Settings > Developer > Real Question Test).

---

## Parser Improvements Reference (2026-03-09)

The following robustness improvements were added to `RealQuestionTestViewModel.runParsing()`:

| Improvement | Implementation | Code reference |
|---|---|---|
| **Standalone letter detection** | Line matching `^[A-Da-d]$` → next line becomes answer text, combined as `"A) answer text"` | `standaloneLetter` regex + `pendingLetter` state |
| **UI noise filtering (regex)** | 6 patterns: timer `^\d{1,2}:\d{2}`, `^Punkte:`, `^noch \d+ Aufgaben`, `^Frage:?\s*\d+`, `^Führerscheintest`, standalone numbers `^\d{1,2}$` | `noisePatterns` array |
| **UI noise filtering (exact)** | 14 words: Grundstoff, Klasse B/A/C/D, freenet, MOBILFUNK, WhatsApp, Weiter, Abgabe, Zurück, Überspringen, Bildfrage, Theorieprüfung Simulation | `noiseExactWords` set |
| **Multi-line answer append** | Non-prefix lines after first answer append to previous answer with space separator | `else` branch in parsing loop |
| **Extended answer prefixes** | `A) B. C:` `1. 2)` and bullet chars `- bullet □ ☐ checkmark ✗` | `answerPrefixPattern` regex |

---

## Real Images — Parser Evaluation Sheets

### bildfrage_1.png

| Field | Value |
|---|---|
| **Source** | Führerscheintest desktop app (green UI) |
| **Question type** | Traffic situation with image |
| **Question** | "Welches Verhalten ist richtig?" |
| **Expected category** | Right of Way |
| **Expected answer count** | 3 |
| **Correct answer(s)** | "Ich muss den Radfahrer durchfahren lassen" + "Ich muss den Motorradfahrer durchfahren lassen" |
| **OCR difficulty** | HIGH |

**Answer format patterns:**

| Pattern | Present | Details |
|---|---|---|
| Checkbox format (□/☐) | YES | Primary format — 3 checkbox answers, no A/B/C |
| Standalone letter column | NO | — |
| Multi-line answers | LIKELY | Answer text may wrap across lines |
| Traffic sign + text | NO | Traffic situation drawing (non-text) |

**Parser improvements that should help:**

| Improvement | Expected impact | Confidence |
|---|---|---|
| UI noise filter: `^Führerscheintest` | Removes "Führerscheintest - Frage: 6" header line | HIGH |
| UI noise filter: `^Punkte:\s*\d+` | Removes "Punkte: 5" line | HIGH |
| UI noise filter: `^noch\s+\d+\s+Aufgaben` | Removes "noch 25 Aufgaben" line | HIGH |
| UI noise filter: `Grundstoff`, `Klasse B` | Removes exam-type labels | HIGH |
| UI noise filter: `^\d{1,2}$` | Removes question grid numbers 1-30 | HIGH — but only standalone numbers, "1-30" as range won't match |
| UI noise filter: `^Frage:?\s*\d+` | Removes "Frage: 6" if on separate line | MEDIUM — depends on OCR line splitting |
| Multi-line append | Reassembles wrapped checkbox answers | MEDIUM |
| Checkbox prefix regex `□☐` | Detects checkbox-prefixed answers | MEDIUM — depends on exact OCR Unicode output |

**Remaining parser risks:**

| Risk | Severity | Details |
|---|---|---|
| OCR checkbox Unicode variance | HIGH | Vision framework may render checkbox as `[ ]`, `o`, or other glyph not in regex `[-•◦▪□☐✓✗]` |
| "Führerscheintest - Frage: 6" as single line | MEDIUM | Noise regex `^Führerscheintest` matches prefix, but if OCR merges with other text it may not start at `^` |
| Question grid as "1 2 3 4 ... 30" on one line | MEDIUM | Standalone number regex only matches single numbers per line, not space-separated sequences |
| Orange/red highlighted "Motorradfahrer" | LOW | Colored text may reduce OCR accuracy for that word |
| Traffic drawing OCR artifacts | LOW | Illustration may produce random character noise |

**Validation checklist (for later real-device test):**

- [ ] OCR produces readable text (not garbled)
- [ ] Noise filter removes timer, Punkte, Grundstoff, Klasse B, question grid
- [ ] 3 answers detected (checkbox format)
- [ ] Question text is clean "Welches Verhalten ist richtig?" without noise
- [ ] Category detected: "Right of Way"
- [ ] No answer text truncated by multi-line split

---

### bildfrage_2.png

| Field | Value |
|---|---|
| **Source** | fahrschule.freenet.de mobile website (iPhone screenshot) |
| **Question type** | Text question with illustration |
| **Question** | "Es fängt an zu regnen. Warum müssen Sie den Sicherheitsabstand sofort vergrößern?" |
| **Expected category** | Distance |
| **Expected answer count** | 3 |
| **Correct answer(s)** | A + C (Sicht + Schmierfilm) |
| **OCR difficulty** | MEDIUM |

**Answer format patterns:**

| Pattern | Present | Details |
|---|---|---|
| Checkbox format (□/☐) | NO | — |
| Standalone letter column | YES | A, B, C appear as standalone letters on left side, answer text in separate column |
| Multi-line answers | YES | Answer A spans ~4 lines in OCR |
| Traffic sign + text | NO | Cartoon illustration (non-text) |

**Parser improvements that should help:**

| Improvement | Expected impact | Confidence |
|---|---|---|
| Standalone letter detection | Combines standalone "A" + next line(s) into `"A) answer text"` | HIGH — this is the primary fix for this image |
| UI noise filter: `freenet`, `MOBILFUNK`, `WhatsApp` | Removes phone app/website headers | HIGH |
| UI noise filter: `^\d{1,2}:\d{2}` | Removes "14:56" status bar time | HIGH |
| Multi-line append | Reassembles wrapped answer text after letter prefix | HIGH — answer A spans 4 lines |

**Remaining parser risks:**

| Risk | Severity | Details |
|---|---|---|
| Standalone letter + answer on SAME line | MEDIUM | If OCR keeps "A Weil die Sicht..." on one line, standalone detection won't fire and the line won't match prefix regex either (no `).:` after letter) |
| Multi-line: wrong answer boundary | MEDIUM | After "A) first answer line", subsequent lines append to A — but where does A end and B begin? Only when next standalone "B" is found. If OCR misses "B" standalone, A absorbs B's text |
| Cartoon illustration OCR noise | LOW | Cartoon character may produce random text fragments |
| Ad banners / navigation links | LOW | Mobile site may have "Anzeige", cookie banners — not in noise filter |
| Battery/signal icons as text | LOW | "100%", signal bars could become text fragments |

**Validation checklist (for later real-device test):**

- [ ] Standalone letters A, B, C detected on separate lines
- [ ] Each letter correctly paired with its answer text
- [ ] Answer A multi-line text fully reassembled (not truncated)
- [ ] 3 answers detected total
- [ ] "freenet", "MOBILFUNK", "14:56" filtered out
- [ ] Question text clean without phone chrome
- [ ] Category detected: "Distance" (keyword: "Sicherheitsabstand")

---

### verkehrszeichen_1.png

| Field | Value |
|---|---|
| **Source** | fahrschule.freenet.de mobile website (iPhone screenshot) |
| **Question type** | Traffic sign question with sign image |
| **Question** | "Was ist bei diesen Verkehrszeichen erlaubt?" |
| **Expected category** | Traffic Signs |
| **Expected answer count** | 3 |
| **Correct answer** | C ("Bewohner mit entsprechend nummeriertem Parkausweis dürfen hier parken") |
| **OCR difficulty** | MEDIUM |

**Answer format patterns:**

| Pattern | Present | Details |
|---|---|---|
| Checkbox format (□/☐) | NO | — |
| Standalone letter column | YES | Same layout as bildfrage_2 — A, B, C standalone on left |
| Multi-line answers | YES | A: 3 lines, B: 2 lines, C: 3 lines |
| Traffic sign + text | YES | Sign image contains "P" and "Bewohner mit Parkausweis Nr. IIIIIIIII" — OCR will extract this as text |

**Parser improvements that should help:**

| Improvement | Expected impact | Confidence |
|---|---|---|
| Standalone letter detection | Combines standalone "A"/"B"/"C" with following answer text | HIGH |
| UI noise filter: `freenet`, `MOBILFUNK` | Removes website/phone headers | HIGH |
| UI noise filter: `^\d{1,2}:\d{2}` | Removes "15:17" status bar time | HIGH |
| Multi-line append | Reassembles multi-line answers (A: 3 lines, B: 2 lines, C: 3 lines) | HIGH |

**Remaining parser risks:**

| Risk | Severity | Details |
|---|---|---|
| Sign text "P" as standalone letter | HIGH | OCR extracts "P" from parking sign — standalone letter regex only matches A-D, so "P" won't trigger. But "P" on its own line becomes a question line (noise). No filter for single uppercase non-A-D letters. |
| Sign text "Bewohner mit Parkausweis Nr. IIIIIIIII" in question | HIGH | This sign text looks like normal German text. Parser will include it in question lines. Category detection may still work (contains "Parkausweis" → Parking, but question has "Verkehrszeichen" → Traffic Signs). |
| "IIIIIIIII" OCR artifacts | MEDIUM | Roman numerals or decorative lines from sign may produce junk characters |
| Multi-line answer boundary between B and C | MEDIUM | If OCR misses standalone "C", answer B absorbs C's text |
| Same-line letter+text possibility | MEDIUM | Same risk as bildfrage_2 — OCR may keep letter and text on one line |

**Validation checklist (for later real-device test):**

- [ ] Standalone letters A, B, C detected correctly
- [ ] Sign text "P" does NOT create a phantom answer
- [ ] Sign text "Bewohner mit Parkausweis Nr." included in question (acceptable) or filtered
- [ ] 3 answers detected, each with correct multi-line text
- [ ] "freenet", "MOBILFUNK", "15:17" filtered out
- [ ] Category detected: "Traffic Signs" (not "Parking" despite sign content)
- [ ] Category confidence reasonable despite competing Parking keywords

---

## Mock Images — Parser Evaluation

### bildfrage_1..5.png (5 files)

| Field | Value |
|---|---|
| Source | AskFin mock app UI |
| Answer format | Checkbox squares (□), no letter prefix |
| OCR difficulty | LOW |

**Parser improvements that should help:**

| Improvement | Expected impact |
|---|---|
| UI noise filter: `Bildfrage` | Removes "Bildfrage" header — was previously included in question text |
| Checkbox prefix regex | Detects □-prefixed answers |

**Remaining risks:** Minimal. Clean layout, controlled font. Only risk is checkbox Unicode variance.

### screen_01..20.png (20 files)

| Field | Value |
|---|---|
| Source | AskFin mock app UI |
| Answer format | Checkbox squares (□), no letter prefix |
| OCR difficulty | LOW |

**Parser improvements that should help:**

| Improvement | Expected impact |
|---|---|
| UI noise filter: `^Frage:?\s*\d+` | Removes "Frage 1:" prefix line — was previously included in question text |
| UI noise filter: `Weiter` | Removes "Weiter" button text |
| UI noise filter: `Theorieprüfung Simulation` | Removes header text |
| Checkbox prefix regex | Detects □-prefixed answers |

**Remaining risks:** Minimal. "Frage N:" removal is the biggest improvement — previously polluted question text.

---

## Known Parser Challenges — Updated Status

| Challenge | Affected images | Pre-fix severity | Post-fix status |
|---|---|---|---|
| No A/B/C/D prefix (checkbox format) | bildfrage_1.png, all mocks | HIGH | MITIGATED — regex supports □☐ but OCR Unicode variance remains |
| Standalone letter + separate text column | bildfrage_2.png, verkehrszeichen_1.png | HIGH | FIXED — `standaloneLetter` detection merges letter + next line |
| Multi-line answer text | bildfrage_1.png, bildfrage_2.png, verkehrszeichen_1.png | MEDIUM | FIXED — append logic in parsing loop |
| UI chrome noise (timer, scores, navigation) | bildfrage_1.png | HIGH | FIXED — 6 regex patterns + 14 exact words filter |
| Phone chrome (status bar, app headers) | bildfrage_2.png, verkehrszeichen_1.png | LOW | FIXED — time, "freenet", "MOBILFUNK" all filtered |
| Sign text in OCR output | verkehrszeichen_1.png | MEDIUM | OPEN — "P" and "Bewohner mit Parkausweis" still reach parser |
| Multiple correct answers | bildfrage_1.png, bildfrage_2.png | N/A | N/A — solver responsibility |
| "Weiter"/"Abgabe" buttons as text | all mocks | LOW | FIXED — exact word filter |
| "Frage N:" prefix in question | all mocks | LOW | FIXED — regex noise filter |
| "Bildfrage"/"Theorieprüfung Simulation" header | all mocks | LOW | FIXED — exact word filter |

### New risks identified (post-improvement)

| Risk | Affected images | Severity | Details |
|---|---|---|---|
| OCR keeps letter+text on same line | bildfrage_2, verkehrszeichen_1 | MEDIUM | "A Weil die Sicht..." — no prefix delimiter, standalone detection won't fire, prefix regex won't match |
| Sign text as question content | verkehrszeichen_1 | MEDIUM | "Bewohner mit Parkausweis Nr." looks like German text, will be included in question lines |
| Standalone "P" from parking sign | verkehrszeichen_1 | LOW | Falls through as question line (not A-D), minor noise |
| Question grid as number sequence | bildfrage_1 | LOW | "1 2 3 ... 30" on single line won't match standalone `^\d{1,2}$` |
| Checkbox Unicode variance | bildfrage_1, all mocks | MEDIUM | Vision framework output for □ is unknown — could be `[ ]`, `o`, or other |
| Ad/cookie banner text | bildfrage_2, verkehrszeichen_1 | LOW | Mobile site banners not in noise filter |

---

## Evaluation Workflow

For each image, run through Real Question Test and record:

```
Image: ___
OCR Quality:    [ OK / PARTIAL / FAIL ]  chars: ___ lines: ___
Noise Filtered: ___ lines removed (list which patterns matched)
Question Parse: [ OK / PARTIAL / FAIL ]  noise lines still included: ___
Answer Count:   [ OK / WRONG ]           expected: ___ actual: ___
Answer Format:  [ PREFIX / STANDALONE / CHECKBOX / UNKNOWN ]
Standalone Merge: [ OK / N/A / FAIL ]    letters merged: ___
Multi-line:     [ OK / N/A / FAIL ]      lines appended: ___
Category:       [ OK / WRONG / GENERAL ] expected: ___ actual: ___
Cat. Confidence: ___%  keywords: ___
Solver:         [ OK / UNAVAILABLE ]     (placeholder API expected)
Overall:        [ PASS / PARTIAL / FAIL ]
Notes: ___
```

## Priority Order for Testing

1. **verkehrszeichen_1.png** — tests standalone letter detection + noise filter + sign text interference
2. **bildfrage_2.png** — tests standalone letter detection + multi-line merge + phone chrome filter
3. **bildfrage_1.png** — hardest case: checkbox format + heavy UI noise + multi-select
4. **Mock screen_01..05** — baseline: validates noise filter for "Frage N:", "Weiter", "Theorieprüfung Simulation"
5. **Mock bildfrage_1..5** — validates noise filter for "Bildfrage" header + checkbox detection
