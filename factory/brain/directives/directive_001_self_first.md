# Factory Directive 001 — Self-First Prinzip

**Erlassen von:** CEO (Andreas)
**Gueltig ab:** 25. Maerz 2026
**Prioritaet:** HOECHSTE — ueberschreibt alle anderen Empfehlungen
**Betrifft:** Alle Factory-Entscheidungen zu Capability-Erweiterungen

---

## Kernregel

Alles was die Factory braucht, wird selbst entwickelt, gebaut und erweitert.
Externe Dienstleister sind die LETZTE Option, nicht die erste.

## Entscheidungsreihenfolge bei fehlender Capability

### Stufe 1: Eigene Mittel (IMMER ZUERST PRUEFEN)
Kann die Factory das Problem mit bestehenden Tools, Agents und Infrastruktur loesen?
- Bestehende Adapter umkonfigurieren
- Bestehende Agents erweitern
- Bestehende Workflows anpassen

Wenn ja: MACHEN. Kein weiterer Check noetig.

### Stufe 2: Selbst entwickeln
Koennen wir die Capability selbst bauen?
- Neuen Agent entwickeln
- Neues Modul programmieren
- Eigene Pipeline aufbauen

Wenn ja: PLANEN und BAUEN. Zeitaufwand ist akzeptabel.

### Stufe 3: Open-Source / Self-Hosting
Gibt es ein Open-Source-Modell oder Tool das wir lokal hosten koennen?
- Auf dem Proxmox-Server deployen
- Im eigenen Container betreiben
- Keine Abhaengigkeit von externen APIs

Wenn ja: EVALUIEREN und INTEGRIEREN.

### Stufe 4: Temporaerer externer Dienstleister (NUR IM AEUSSERSTEN NOTFALL)
Erst wenn Stufe 1-3 nicht moeglich sind:
- Externen Service temporaer anbinden
- IMMER mit dem Vermerk: "Uebergangsloesung"
- IMMER mit einem Plan wann und wie wir das selbst abloesen
- IMMER mit Deadline fuer Self-Hosting-Migration

Das ist eine KRUECKE, kein Feature.

## Produktions-Regel

Wenn eine App eine Capability braucht die fehlt und nicht sofort (Stufe 1) loesbar ist:
- Die App-Produktion wird auf PAUSE gesetzt
- NICHT die Capability schnell extern einkaufen um die App fertig zu bekommen
- Die Factory arbeitet an anderen Projekten weiter (es gibt immer andere Apps in der Pipeline)
- Parallel wird die fehlende Capability nach Stufe 2 oder 3 aufgebaut
- Wenn die Capability fertig ist, wird die App-Produktion fortgesetzt

## Begruendung

- Externe Abhaengigkeiten sind Risiken: APIs aendern sich, Preise steigen, Services gehen offline
- Die Factory soll langfristig autonom sein — nicht von 15 externen Services abhaengen
- Jede selbst gebaute Capability macht die Factory wertvoller
- Die KI-Technologie entwickelt sich rasant — was heute extern noetig ist, koennen wir in 6-12 Monaten selbst
- Qualitaet vor Geschwindigkeit: Lieber eine App spaeter liefern als eine Abhaengigkeit schaffen

## Ausnahmen

Eine Ausnahme von Direktive 1 kann NUR vom CEO genehmigt werden.
TheBrain darf EMPFEHLEN einen externen Service temporaer zu nutzen,
aber die Entscheidung liegt beim CEO.
Jede Ausnahme muss dokumentiert werden mit:
- Warum Stufe 1-3 nicht moeglich ist
- Welcher externe Service genutzt wird
- Geplante Abloesung: Wann und wie wird Self-Hosting erreicht
