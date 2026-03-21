# Plattform-Strategie-Report: SkillSense

---

## Zielgruppen-Plattform-Analyse

> **Methodischer Hinweis:** SkillSense ist eine Productivity-SaaS-Web-App, kein Mobile Game. Die bereitgestellten Web-Recherche-Ergebnisse (Mobile Gaming Market Data) sind als Kontext-Proxy verwendbar, aber nicht direkt auf dieses Produkt übertragbar. Plattformverteilungs-Schätzungen basieren auf SaaS-Productivity-Tool-Benchmarks + Developer-Tool-Nutzungsdaten als primäre Proxy-Quellen.

| Plattform | Anteil | Begründung |
|---|---|---|
| **Desktop Web (Chrome/Firefox/Safari)** | **~68%** | Primärer Use-Case erfordert File-Upload (Skill-Dateien, Chat-Exporte) — das ist auf Desktop strukturell besser nutzbar. Developer-Zielgruppe (Primär-Persona) arbeitet primär am Desktop. SaaS-Productivity-Tools wie Notion, Linear, Grammarly zeigen 60–75% Desktop-Anteil in Tech-Zielgruppen. |
| **Mobile Web (Browser)** | **~27%** | Advisor-Light-Fragebogen und Landing Page sind auf Mobile vollständig nutzbar. File-Upload-Features werden mobil signifikant seltener genutzt. "Der AI-Enthusiast" (Sekundär-Persona) hat höheren Mobile-Anteil. |
| **Tablet (Web)** | **~5%** | Randnutzung. Keine eigenständige Optimierung notwendig — responsive Design deckt dieses Segment ab. |
| **Native iOS App** | **—** | Phase 3+. Aktuell nicht im Scope. |
| **Native Android App** | **—** | Phase 3+. Aktuell nicht im Scope. |

**Besonderheit der Zielgruppe:**
Die Primär-Persona "Der Developer" (26–38 Jahre, Software Engineer) hat eine statistisch nachweisbar höhere Desktop-Nutzungsrate als der Durchschnitts-Smartphone-Nutzer. Stack Overflow Developer Survey 2024 zeigt: 94% der Entwickler arbeiten primär auf Desktop/Laptop. Der sekundäre Mobile-Anteil (27%) wird überproportional durch die Persona "Der AI-Enthusiast" (20–35 Jahre, Freelancer/Student) getragen, die den Advisor-Light-Fragebogen auch unterwegs nutzen würde.

**Quellen:**
- Stack Overflow Developer Survey 2024 (Desktop-Nutzung Developer-Community)
- Notion / Grammarly / Linear: öffentliche Nutzerdaten-Berichte 2023–2024 (SaaS-Proxy)
- Zielgruppen-Report SkillSense (intern): ~70% Desktop Web, ~25% Mobile Web
- Sensor Tower State of Mobile 2026 (Kontext: Mobile-Markt-Gesamtbild)

---

## Revenue-Verteilung pro Plattform

> **Wichtige Vorbemerkung:** SkillSense operiert als direktes Web-SaaS-Modell via Stripe. Es gibt keine plattformabhängige Revenue-Teilung im MVP. Die folgende Aufstellung zeigt die **strategische Revenue-Relevanz** pro Plattform — nicht eine tatsächliche Aufteilung durch App-Store-Mechanismen.

| Plattform | Anteil am Umsatz | Anmerkung |
|---|---|---|
| **Web (Stripe Direct)** | **~100%** (Phase 1+2) | Kein App-Store-Cut. Volle Marge auf 9,99 €/Monat und 79 €/Jahr. Stripe nimmt ca. 1,4% + 0,25 € pro Transaktion (EU-Karten, Stripe-Standardtarif). |
| **iOS (App Store)** | **0%** (Phase 1+2), Phase 3+ | Bei hypothetischer nativer App: 15–30% App-Store-Gebühr auf Subscription-Revenue. Bei 1.000 Pro-Nutzern à 9,99 €/Monat = 1.499–2.997 € monatlicher Verlust gegenüber Web-Direct. |
| **Android (Google Play)** | **0%** (Phase 1+2), Phase 3+ | Bei hypothetischer nativer App: 15–30% Google-Play-Gebühr (ab Jahr 2: 15% für erste 1 Mio. USD Revenue). Marginal besser als Apple, strukturell identisches Problem. |

**Revenue-Implikation der Web-First-Entscheidung (konkret):**

```
Szenario: 500 Pro-Nutzer (Monatlich à 9,99 €)

Web Direct (Stripe):
  Brutto:       4.995 €/Monat
  Stripe-Fee:   ~120 €
  Netto:        ~4.875 €/Monat

iOS App Store (30% Fee):
  Brutto:       4.995 €/Monat
  Apple-Cut:    1.499 €
  Stripe-Fee:   entfällt (StoreKit)
  Netto:        ~3.496 €/Monat

Differenz:      +1.379 €/Monat durch Web-First
                = +16.548 €/Jahr bei 500 Nutzern
```

Diese Kalkulation wächst linear mit der Nutzerzahl und ist das stärkste ökonomische Argument für die Web-First-Entscheidung im MVP.

**Quellen:**
- Apple App Store Small Business Program: 15% für <1 Mio. USD/Jahr, 30% darüber (apple.com/app-store, 2025)
- Google Play Fee Structure 2025: 15% für erste 1 Mio. USD, 30% darüber
- Stripe Pricing EU: 1,4% + 0,25 € (Standardkarte EU), stripe.com/de/pricing
- Legal-Report SkillSense Phase 1 (intern): App-Store-Gebühren als strategisches Argument für Web-App

---

## Plattform-Bewertung

### iOS (Native / Swift)

**Vorteile:**
- Höchste Zahlungsbereitschaft pro Nutzer in der Tech-Zielgruppe (iOS-Nutzer geben im Schnitt 2,5× mehr für Apps aus als Android-Nutzer — Sensor Tower 2025)
- Bessere Performance bei dateiintensiven Operationen (relevanter für Chat-Export-Analyse mit großen JSON-Dateien)
- Prestige-Signal in der Developer-Community (iPhone-Marktanteil unter US/DACH-Developern überproportional hoch)
- Apple-Ökosystem-Integration: Share Sheet, Files-App-Zugriff für einfacheres Skill-File-Handling

**Nachteile:**
- 15–30% App-Store-Gebühr auf Subscription-Revenue — nicht verhandelbar ohne Apple Developer Enterprise Program
- App-Store-Review-Prozess: Tools die Chat-Daten verarbeiten werden unter Guideline 5.1 (Privacy) besonders geprüft — Review-Zyklen von 1–3 Wochen realistisch
- Swift/SwiftUI-Entwicklung erfordert macOS-Entwicklungsumgebung — schließt Windows/Linux-Developer aus
- iOS-Updates können Breaking Changes in File-Handling-APIs erzeugen (historisch: iOS 13 File-Provider-API-Änderungen)
- Client-Side-Versprechen schwerer kommunizierbar: Apple Privacy Nutrition Label muss befüllt werden, auch wenn keine Daten gesendet werden

**Geschätzte Entwicklungskosten (DACH-Markt):**
```
MVP iOS App (Feature-Parität mit Web-MVP):
  Seniorентwickler (Swift/SwiftUI), DACH-Markt:  85–120 €/Stunde
  Geschätzter Aufwand:                           400–600 Stunden
  
  Gesamtkosten:                                  34.000–72.000 €
  
  Laufende Wartung (iOS-Updates, 1×/Jahr):       5.000–12.000 €/Jahr
  
  App-Store-Entwicklerkonto:                     99 USD/Jahr (~91 €)
```

**Feature-Einschränkungen:**
- **File-Upload:** iOS beschränkt den direkten Dateizugriff — Nutzer müssten Skills über die Files-App oder Share Sheet importieren, nicht per Drag & Drop wie im Web
- **Background-Processing:** Chat-Export-Analyse für große Dateien (>10 MB) würde durch iOS Background-Execution-Limits eingeschränkt — WebWorker-Äquivalent auf iOS ist BGProcessingTask mit strengen Zeitlimits
- **WebCrypto / WASM:** Client-Side-Sicherheitsanalyse (Jaccard, Pattern-Matching) ist in nativen Apps neu zu implementieren — kein Code-Sharing mit Web-Analyse-Engine ohne React Native/Capacitor
- **StoreKit-Pflicht:** Keine externe Zahlungsabwicklung (Stripe) für In-App-Käufe erlaubt — vollständige Neuimplementierung des Bezahlflows notwendig

---

### Android (Native / Kotlin)

**Vorteile:**
- Größere globale Installationsbasis (Android: ~72% globaler Smartphone-Marktanteil — Statista 2025)
- Kein Review-Prozess für Sideloading (direkter APK-Download möglich für Beta-Tester)
- Google Play erlaubt ab 2024 alternative Bezahlsysteme in bestimmten Märkten (User Choice Billing — aktuell DE, UK, AU verfügbar)
- Kotlin/Android-Entwicklung günstiger als iOS (mehr verfügbare Entwickler, niedrigere Stundensätze)
- Besserer File-System-Zugriff als iOS — Drag & Drop aus Dateimanager strukturell einfacher

**Nachteile:**
- Zielgruppen-Overlap mit primärer Persona (Developer) ist auf iOS tendenziell höher in DACH (iOS-Marktanteil DE: ~55–60% laut Statista 2024)
- Fragmentierung: SkillSense müsste auf 50+ unterschiedlichen Android-Gerätekonfigurationen getestet werden
- Play-Store-Gebühr: 15% Jahr 1, 30% danach (User Choice Billing reduziert das, aber mit Komplexitätskosten)
- Geringere Zahlungsbereitschaft im Durchschnitt als iOS-Nutzer — spezifisch in der SkillSense-Zielgruppe wahrscheinlich ausgeglichener, aber generell ein Faktor

**Geschätzte Entwicklungskosten (DACH-Markt):**
```
MVP Android App (Feature-Parität mit Web-MVP):
  Senior-Entwickler (Kotlin/Jetpack Compose), DACH:  70–100 €/Stunde
  Geschätzter Aufwand:                                350–550 Stunden
  
  Gesamtkosten:                                       24.500–55.000 €
  
  Laufende Wartung:                                   4.000–9.000 €/Jahr
  
  Play-Store-Entwicklerkonto:                         25 USD einmalig (~23 €)
```

**Feature-Einschränkungen:**
- **Drag & Drop:** Auf Android besser als iOS, aber von App zu App unterschiedlich implementiert — kein einheitlicher Standard
- **Background-Processing:** WorkManager ermöglicht Hintergrundanalyse — technisch besser als iOS, aber Battery-Optimierungen der Hersteller (Samsung, Huawei) können Prozesse unterbrechen
- **Code-Sharing:** Keine native Code-Sharing-Möglichkeit mit der Web-Analyse-Engine ohne Cross-Platform-Framework

---

### Web (PWA / Browser App)

**Vorteile:**
- **Keine App-Store-Gebühren:** 100% Revenue-Kontrolle via Stripe — strategisch wichtigstes Argument (siehe Revenue-Analyse oben)
- **Kein Review-Prozess:** Deployment in Minuten via Vercel — kein Apple-Review-Risiko für datenschutzsensitive Features
- **Code-Einheitlichkeit:** Eine Codebase für Desktop und Mobile Web — deutlich geringerer Wartungsaufwand
- **Drag & Drop nativ:** File-Upload per Drag & Drop ist Browser-nativ — kein nativer API-Workaround nötig
- **WebWorker für Client-Side-Analyse:** Jaccard-Algorithmus und Pattern-Matching laufen in WebWorkern ohne Main-Thread-Blockierung — performant und vollständig client-side
- **DSGVO by Design:** Chat-Analyse verbleibt im Browser — technisch saubere Umsetzung des Datenschutz-USPs ohne native-App-Kompromisse
- **SEO-Reichweite:** Next.js Server-Side-Rendering ermöglicht organische Suchmaschinenoptimierung für Landing Pages und Blog-Inhalte — nativer Apps fehlt diese Sichtbarkeit
- **PWA-Option:** Progressive Web App mit Service Worker ermöglicht Offline-Funktionalität für bereits analysierte Skills und Home-Screen-Installation auf Mobile — ohne App-Store

**Nachteile:**
- **Keine Push-Notifications auf iOS (Safari):** Apple hat Push für PWAs erst ab iOS 16.4 ermöglicht — Nutzung noch gering, Zuverlässigkeit geringer als nativ. Für SkillSense (kein Daily-Driver) ist das jedoch kein kritischer Nachteil
- **Keine tiefe Betriebssystem-Integration:** Kein nativer Share Sheet, kein Widget, kein Siri/Google-Assistant-Integration — für SkillSense-Use-Case aber nicht relevant
- **Wahrgenommene Qualität:** In manchen Nutzergruppen gelten Web-Apps als "weniger professionell" als native Apps — in der Developer-Zielgruppe von SkillSense ist dieses Vorurteil jedoch umgekehrt: Entwickler bevorzugen Web-Tools
- **Browser-Speicherlimits:** IndexedDB (für lokales Caching der Skill-Datenbank) hat browserspezifische Limits (Chrome: ~60% freier Festplattenplatz, Firefox: ~50%) — für SkillSense-Datenmengen kein praktisches Problem

**Geschätzte Entwicklungskosten (DACH-Markt):**
```
MVP Web-App (Next.js 14, vollständiger Feature-Scope laut Concept Brief):
  Senior Full-Stack-Entwickler (Next.js/TypeScript), DACH:  80–110 €/Stunde
  Geschätzter Aufwand (MVP):                                 250–400 Stunden
  
  Gesamtkosten:                                              20.000–44.000 €
  
  Laufende Infrastruktur (Vercel, Clerk, Supabase):
    MVP-Phase (0–500 Nutzer):                                0–150 €/Monat
    Scale-Phase (500–5.000 Nutzer):                          300–800 €/Monat
  
  Wartung & Updates:                                         3.000–6.000 €/Jahr
```

**Feature-Einschränkungen:**
- **File System Access API:** Moderner Browser-Standard — erlaubt direkten Ordner-Zugriff für Skill-Datei-Management. Noch nicht in allen Browsern vollständig implementiert (Firefox: teilweise). Fallback via Standard-File-Input-Element ausreichend für MVP
- **WebAssembly (optional):** Für hochperformante Sicherheitsanalyse bei sehr großen Chat-Exporten (>50 MB) könnte WASM-basierte Analyse notwendig werden — kein MVP-Blocker, aber ein Phase-2-Optimierungsschritt
- **Offline-Funktionalität:** Service Worker ermöglicht Basis-Offline-Funktion, aber API-abhängige Features (Skill-Generierung via Claude) erfordern Internetverbindung — erwartungskonform für diesen Use-Case

**PWA-spezifische Limitierungen (aus Reddit-Recherche bestätigt):**
- Scheduled Notifications nicht möglich (für SkillSense irrelevant — kein Notification-Use-Case im Core Loop)
- Bluetooth/NFC/USB-Zugriff nicht möglich (irrelevant)
- Alle anderen für SkillSense relevanten Features (File-Upload, WebWorker, IndexedDB, Camera) sind in PWAs vollständig verfügbar

---

### Cross-Platform (React Native / Capacitor / Flutter)

**Vorteile:**
- Code-Sharing zwischen Web und Mobile möglich (besonders Capacitor: Web-Code direkt in native App wrappen)
- Geringere Kosten als zwei separate native Entwicklungen
- Schnellere Time-to-Market für mobile Expansion

**Nachteile:**
- **Capacitor/Ionic:** Direktes Wrapping der Web-App möglich, aber Apple Guideline 4.2 (Minimum Functionality) lehnt reine Web-Wrapper ab — App müsste echte native Features integrieren
- **React Native:** Erfordert Neu-Implementierung der UI-Komponenten in React Native — kein direktes Code-Sharing mit Next.js-Frontend trotz gemeinsamer Sprache (TypeScript)
- **Flutter:** Komplett separates Framework (Dart) — höchster Lernaufwand, kein Code-Sharing mit Web-Stack
- **Performance:** Cross-Platform-Apps erreichen bei dateiintensiven Operationen (Chat-Export-Analyse) nicht die Performance nativer Apps — WebWorker-Äquivalent muss neu implementiert werden
- **Update-Zyklen:** Jedes Framework-Update kann Breaking Changes erzeugen — zusätzlicher Wartungsaufwand der den initialen Kostenvorteil langfristig aufzehrt

**Geschätzte Entwicklungskosten (DACH-Markt):**
```
React Native App (iOS + Android, Basis-Feature-Set):
  Senior-Entwickler (RN/TypeScript), DACH:           75–105 €/Stunde
  Geschätzter Aufwand:                               300–500 Stunden
  
  Gesamtkosten:                                      22.500–52.500 €
  (Kein signifikanter Kostenvorteil gegenüber
   separater iOS- oder Android-Entwicklung bei
   diesem Produkt-Typ)

Capacitor (Web-zu-App-Wrapper):
  Aufwand für Store-Compliance + Native Features:    80–150 Stunden
  Kosten:                                            6.400–16.500 €
  
  ⚠️ Risiko: Apple-Review-Ablehnung als Web-Wrapper
```

**Feature-Einschränkungen:**
- Identische Einschränkungen wie native Apps für File-Handling, Background-Processing
- Zusätzlich: JavaScript-Bridge-