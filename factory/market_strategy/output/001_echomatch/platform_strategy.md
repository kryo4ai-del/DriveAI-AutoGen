# Plattform-Strategie-Report: EchoMatch

---

## Zielgruppen-Plattform-Analyse

### Nutzer-Verteilung nach Plattform

- **iOS Anteil: 42–45%** | Begründung: Primärzielgruppe 18–34 in Tier-1-Märkten (USA, UK, DE, AU, CA) ist überproportional stark auf iOS vertreten. iOS-Nutzer in diesen Märkten zeigen höhere IAP-Konversionsraten und höheren ARPU — direkt relevant für den Battle-Pass als primären Recurring-Revenue-Anker. Social-Sharing als organischer UA-Kanal funktioniert auf iOS durch enge iMessage/AirDrop-Integration besonders effektiv. ⚠️ ATT-Framework reduziert Behavioral-Tracking-Reichweite unter iOS, was die KI-Personalisierung in der Kaltstart-Phase einschränkt (s. Legal-Relevanz).

- **Android Anteil: 55–58%** | Begründung: Android dominiert global durch Tier-2-Märkte (Brasilien, Indien, Südostasien) und ist auch in Tier-1-Märkten volumenstärker. Das Sekundär- und Nischensegment (35–49, 50+) ist auf Android stärker repräsentiert — relevant für Ad-Revenue-Optimierung. Rewarded Ads als primärer Revenue-Kanal für Free-Player-Masse skaliert auf Android durch hohes Installvolumen effektiver.

- **Web/Browser Anteil: 0–3%** | Begründung: Match-3 ist ein nativer Mobile-Use-Case. Session-Design (5–10 Min., Commuter-Kontext, Push-Notification-Trigger) ist strukturell auf Mobile-Hardware ausgerichtet. Web hat im Puzzle-/Casual-Segment keine relevante Primär-Nutzerbasis. Gyroscope, Haptics und nativer Notification-Stack sind Web-seitig nicht vollständig replizierbar. Kein einziger Top-Wettbewerber (Royal Match, Candy Crush, Fishdom) hat eine relevante Web-Strategie.

**Quellen:** Zielgruppen-Profil EchoMatch (intern, Agent 3); BusinessOfApps Mobile Game Demographics 2026; Web-Recherche revolgames.co (iOS 60% / Android 40% Revenue-Split im Gesamtmarkt); Proxy: app.data.ai / Branchendurchschnitt Hybrid-Casual 2025

---

## Revenue-Verteilung pro Plattform

| Plattform | Anteil am Umsatz | Kommentar |
|---|---|---|
| **iOS** | ~60% | Strukturell höherer ARPU, bessere IAP-Konversion, Battle-Pass-affine Zielgruppe in Tier-1 |
| **Android** | ~38% | Höheres Volumen, niedrigerer ARPU, stärkerer Ad-Revenue-Anteil |
| **Web** | ~2% | Vernachlässigbar; kein strategischer Revenue-Kanal im Launch-Horizon |

> ⚠️ Diese Verteilung basiert auf dem in den Web-Recherche-Ergebnissen identifizierten Branchenwert (iOS: 60%, Android: 40% Revenue-Split im mobilen Gaming-Gesamtmarkt, revolgames.co 2025). Für das spezifische Match-3/Hybrid-Casual-Segment liegen keine segmentspezifischen Aufschlüsselungen vor. EchoMatch-spezifische Validierung nach Soft-Launch durch interne Tracking-Daten empfohlen.

**Quellen:** revolgames.co "Top Mobile Game Revenue Statistics 2025"; AppMagic Mobile Games Monetization Report 2025 (Substack/gamedevreports); Zielgruppen-Profil EchoMatch (intern)

---

## Plattform-Bewertung

### iOS (Native / Swift)

**Vorteile:**
- Höchster ARPU im Puzzle-Segment; Battle-Pass und kosmetische IAPs konvertieren in Tier-1-iOS-Märkten (USA, DE, AU) strukturell besser
- Homogene Gerätelandschaft (begrenzte Hardware-Varianz) → geringerer QA-Aufwand, stabilere Performance für KI-Rendering
- Core Haptics, Live Activities, Dynamic Island-Integration für Session-Trigger (Push-Notifications) nativ verfügbar
- App Store Featuring-Chancen bei guter Retention-Performance sind strategisch wertvoll für organische UA — besonders bei begrenztem UA-Budget in der Launch-Phase
- Social-Sharing-Mechanismen (iMessage, SharePlay) als organischer UA-Kanal relevant angesichts Rekordhoch-UA-Kosten (Bigabid 2026)

**Nachteile:**
- Apple In-App Purchase: 15–30% Revenue-Cut (15% unter $1M Jahresumsatz via Small Business Program)
- App Tracking Transparency (ATT): KI-Behavioral-Tracking erfordert expliziten Opt-in → reduziert initial verfügbare Personalisierungsdaten für Cold-Start des KI-Systems; Consent-Rate liegt branchenweit bei 25–40% — bedeutet bis zu 75% der Nutzer liefern initial keine Tracking-Daten
- Entwicklungskosten höher als Android-only durch Apple-Ökosystem-spezifische Anforderungen (Swift, Xcode, App Store Review-Zyklen: 24–48h)
- Privacy Nutrition Labels und DSGVO-Consent-Architektur müssen vor Submission vollständig implementiert sein

**Geschätzte Entwicklungskosten (iOS-native, DACH-Markt):**
- iOS-native Solo-Development: €80.000–150.000 (MVP, 6–9 Monate)
- iOS-native mit Team (3–5 Personen, DACH-Stundensatz): €180.000–350.000
- ⚠️ Nicht empfohlen als Single-Platform-Strategie (s. Cross-Platform-Empfehlung)

**Feature-Einschränkungen:**
- ATT-Einschränkung für KI-Behavioral-Tracking ist der kritischste technische Engpass für EchoMatchs Kern-USP unter iOS
- Apple Review-Prozess kann KI-generierte Content-Updates (tägliche Level) verlangsamen, falls Updates über App Store eingereicht werden müssen — Cloud-seitige Level-Generierung ist daher architektonisch zwingend (keine Client-Side-Level-Updates, die Review-pflichtig wären)

---

### Android (Native / Kotlin)

**Vorteile:**
- Höchstes globales Installvolumen; Tier-2-Märkte (Brasilien, Indien) sind Android-dominant → Ad-Revenue-Skalierung
- Google Play Billing: Gleicher 15–30% Revenue-Cut wie Apple, aber flexiblere Sideloading-Optionen in bestimmten Märkten
- Keine ATT-Äquivalent-Barriere in gleicher Restriktivität → KI-Behavioral-Tracking technisch einfacher implementierbar (unter DSGVO-Consent-Framework)
- Google Play Instant (Try-Before-Install) als optionaler Conversion-Booster für UA-Kampagnen
- Firebase-Stack (Google) für Cloud-Backend, Analytics und A/B-Testing nativ integrierbar

**Nachteile:**
- Extreme Geräteheterogenität (tausende Geräte, Android 8–15, verschiedene Chip-Architekturen) → signifikant höherer QA-Aufwand für KI-Level-Rendering-Performance auf Low-End-Devices
- Niedrigerer ARPU als iOS; IAP-Konversionsraten in Tier-2-Märkten deutlich geringer
- Google Play Review-Prozess ist unberechenbarer als Apple bei erster Submission (automatisiertes Screening mit höherer Reject-Rate bei KI-Content-Deklaration)
- Fragmentierung erfordert explizite Performance-Budget-Entscheidungen für KI-Laufzeit auf Low-End-Geräten

**Geschätzte Entwicklungskosten (Android-native, DACH-Markt):**
- Android-native Solo-Development: €85.000–160.000 (MVP, 6–9 Monate)
- Android-native mit Team: €190.000–360.000
- ⚠️ Nicht empfohlen als Single-Platform-Strategie

**Feature-Einschränkungen:**
- KI-Level-Generierung muss für Low-End-Android-Geräte (Snapdragon 400er-Serie, 2GB RAM) explizit getestet werden — On-Device-KI-Inferenz ist hier nicht realistisch, Cloud-Backend ist Pflicht
- Google Play Families Policy: Falls App unter 13-Jährigen zugänglich → drastisch eingeschränkte Tracking- und Ad-Möglichkeiten (s. Legal-Relevanz)

---

### Web (PWA / Browser App)

**Vorteile:**
- Keine Store-Gebühren (kein 15–30% Revenue-Cut)
- Kein App Store Review-Prozess → schnellere Iterations-Zyklen bei Content-Updates
- Theoretisch plattformübergreifend erreichbar

**Nachteile:**
- Strukturell nicht kompatibel mit EchoMatchs Session-Design (Push-Notifications, Haptics, Offline-Fähigkeit, Commuter-Use-Case sind in PWA limitiert oder nicht verfügbar)
- Kein nativer IAP-Stack im Web → Battle-Pass und kosmetische IAPs erfordern eigene Payment-Infrastruktur (Stripe o. ä.) mit eigenen PCI-DSS-Compliance-Anforderungen
- Rewarded Ads im Web-Kontext deutlich geringer monetarisiert als in nativen Apps (kein AdMob, kein ironSource-Equivalent mit gleicher eCPM)
- Kein einziger relevanter Match-3-Wettbewerber verfolgt eine Web-First-Strategie
- DSGVO-Consent-Management im Web technisch aufwändiger (Cookie-Banner, keine nativen Permission-Dialoge)

**Geschätzte Entwicklungskosten (PWA, DACH-Markt):**
- PWA MVP: €40.000–80.000
- Irreführend günstiger Eindruck: Die Einsparnisse bei Entwicklung werden durch fehlende Revenue-Infrastruktur, geringere Monetarisierungseffizienz und höhere Compliance-Kosten für Payment-Stack aufgewogen

**Feature-Einschränkungen:**
- Push Notifications in Safari/iOS PWA bis 2023 nicht verfügbar; seit iOS 16.4 eingeschränkt unterstützt, aber Opt-in-Rate deutlich niedriger als native Apps
- KI-Behavioral-Tracking im Web unterliegt Third-Party-Cookie-Abschaffung → erheblich eingeschränkte Datenbasis für KI-Personalisierung
- Offline-Fähigkeit für Level-Caching bei KI-generierten Inhalten in PWA architektonisch komplex

**Fazit Web:** ❌ Kein strategischer Launch-Kanal. Web ist für EchoMatch weder im Phase-1- noch im Phase-2-Horizon relevant. Ressourcen nicht investieren.

---

### Cross-Platform (Unity)

**Vorteile:**
- **30–40% Kostenersparnis** gegenüber paralleler nativer iOS+Android-Entwicklung durch Single Codebase (Sprigstack 2025; lowcode.agency 2025)
- Unity ist Industriestandard für Hybrid-Casual-Games — alle relevanten Wettbewerber (Royal Match, Candy Crush, Fishdom) entwickeln auf Unity oder einem Unity-nahen Stack; SDK-Ökosystem (ironSource, AppLovin MAX, Firebase, Adjust) ist Unity-nativ verfügbar
- KI-Plugin-Architektur (s. Concept Brief Tech-Stack) lässt sich modular in Unity integrieren — Cloud-Backend-Calls (für tägliche Level-Generierung) sind plattformunabhängig implementierbar
- Cross-Platform QA ist bei Unity effizienter als bei zwei separaten nativen Codebases, trotz Android-Fragmentierungsproblem
- Unity Remote Config + Unity A/B-Testing für Battle-Pass-Preispunkt-Tests und KI-Level-vs.-Kuration-Tests nativ verfügbar
- Cubix-Analyse (2025): Unity ist die empfohlene Wahl wenn Game-Logik, Performance und Cross-Platform-Reach kombiniert werden müssen — exakt EchoMatchs Anforderungsprofil

**Nachteile:**
- Unity Runtime Fee-Kontroverse (2023): Unity hat seine Preismodell-Kommunikation nach starker Community-Reaktion angepasst — für Indie-/Early-Stage-Projekte ist das aktuelle Modell (Unity Personal/Plus: kostenfrei bis $200K Jahresumsatz) unkritisch, aber langfristige Lizenzkosten sollten in der Finanzplanung berücksichtigt werden
- Performance-Overhead gegenüber Native: Bei sehr grafikintensiven Features (~5–10% Performance-Gap gegenüber Native) — für Match-3 mit 2D-Spielfeld nicht kritisch, aber relevant wenn aufwändige Partikeleffekte oder KI-Inferenz On-Device geplant werden
- iOS-spezifische Features (Live Activities, Dynamic Island) erfordern Native-Bridge-Code → kein reiner Unity-Code, aber beherrschbar
- Unity-Versionswechsel können Breaking Changes einführen — CI/CD-Pipeline und versionierte Abhängigkeiten sind Pflicht

**Geschätzte Entwicklungskosten (Unity Cross-Platform, DACH-Markt):**

| Szenario | Kosten | Zeitrahmen |
|---|---|---|
| MVP (Kern-Loop + KI-Placeholder + Soft-Launch-Ready) | €120.000–200.000 | 6–9 Monate |
| Full Production (alle drei Layer, KI-Live, Social-Features) | €280.000–500.000 | 12–18 Monate |
| KI-Level-Generierung PoC (separat, vor Full Production) | €20.000–40.000 | 6–10 Wochen |

> Kostengrundlage: DACH-Markt Entwickler-Stundensatz €80–120/h (Mid-Senior Unity Developer); Cross-Platform-Ersparnis 30–40% gegenüber nativer Parallelentwicklung (Sprigstack 2025)

**Feature-Einschränkungen:**
- KI-Cloud-Backend muss als externe Service-Architektur entwickelt werden (nicht Unity-intern) — das ist kein Nachteil, sondern architektonisch korrekt: Level-Generierung läuft serverseitig, Unity rendert das Ergebnis
- ATT-Compliance unter iOS erfordert Unity-seitiges Plugin (z. B. Unity's own "Apple.Core" Framework) — kein Blocker, aber expliziter Implementierungsschritt

---

## Gestaffelter vs. gleichzeitiger Launch

**Empfehlung: Gestaffelter Launch — Soft-Launch Tier-2 first, dann Tier-1 Global**

| Phase | Märkte | Zeitpunkt | Ziel |
|---|---|---|---|
| **Soft-Launch (Technik & Retention)** | Kanada, Australien, Neuseeland | Monat 6–9 nach Production-Start | Technische Stabilität, Retention-KPIs (D1/D7/D30), KI-Level-Qualität validieren |
| **Monetarisierungs-Soft-Launch** | + Schweden, Finnland, Dänemark | Monat 9–12 | Battle-Pass-Preispunkt testen, IAP-Mix validieren, A/B-Test KI vs. kuratierte Level |
| **Global Launch Phase 1 (Tier-1)** | USA, UK, DE, AU (global) | Monat 12–15 | Vollständiger Tier-1-Rollout mit validierten Metrics |
| **Global Launch Phase 2 (Tier-2)** | Brasilien, Indien, Südostasien | Monat 15–18 | Ad-Revenue-Skalierung, Volumen |

**Begründung:**
- Der Soft-Launch-Guide (Lancaric 2025, "THE Soft launch Bible") und die a16z-Analyse bestätigen: Soft-Launch in kulturell ähnlichen, aber kleineren Märkten (Kanada, Australien) ist der etablierte Standard für Tier-1-Optimierung — diese Märkte haben hohe ARPU-Korrelation mit USA/UK, aber niedrigere UA-Kosten
- Das kritischste ungelöste technische Risiko (KI-Level-Generierung, Risiko 1 im Concept Brief) muss vor dem kapitalintensiven Tier-1-Launch validiert sein — ein fehlerhafter KI-Loop im US-Launch bei hohen UA-Kosten wäre ein wirtschaftlich kritisches Szenario
- UA-Kosten waren Ende 2024 auf Rekordhoch (Bigabid 2026) — ein validiertes Produkt reduziert Burn bei UA-Investition erheblich
- DSGVO-Compliance (🔴 Risiko, 15.000–35.000€ Kostenpunkt) muss vor dem DE/EU-Launch abgeschlossen sein — Australien/Kanada geben 3–6 Monate Vorlaufzeit
- Battle-Pass-Preispunkt ($4–9/Monat) und KI-Level-vs.-Kuration-Split sind explizit offene Datenpunkte (Concept Brief, Risiko 3) — Soft-Launch-A/B-Testing vor globalem Commit ist zwingend

---

## Cross-Platform Synergien

| Feature | Empfehlung | Begründung |
|---|---|---|
| **Cloud-Save** | ✅ Ja — Pflicht | Gerätewechsel ist bei 18–34-Zielgruppe frequent; fehlender Cloud-Save ist nachweislicher Churn-Trigger in Puzzle-Games; Unity Cloud Save oder Firebase Realtime Database als Backend |
| **Cross-Play** | ✅ Ja — für Social-Features | Asynchrone Friend-Challenges müssen plattformübergreifend funktionieren (iOS-Nutzer challenged Android-Freund) — sonst fragmentiert der Social-Layer; technisch über Server-Side-Matchmaking lösbar |
| **Geteilte Accounts** | ✅ Ja — empfohlen | Single Account (z. B. via Sign-in with Apple + Google Sign-In + E-Mail-Fallback) ermöglicht Cross-Device-Nutzung und vereinfacht DSGVO-Datenlöschungsanfragen (ein Account = ein Datensatz); außerdem retention-relevant: Konto-Bindung reduziert Re