# DAI-Core Brand Bible v1.0

**Version**: 1.0
**Datum**: 2026-03-27
**Status**: VERBINDLICH

---

## 1. Markenidentitaet

### Name
**DAI-Core** (gesprochen: "Day-Core")

### Domain
dai-core.ai

### Tagline
> One idea in. One extraordinary app out.

### Elevator Pitch
DAI-Core ist eine autonome Swarm Factory mit ueber 100 KI-Spezialisten in 14+ Abteilungen.
Von einer einzigen Idee bis zur fertigen App in allen Stores — vollstaendig KI-gesteuert.

### Interner Name
DriveAI-AutoGen (nur intern, NIE in oeffentlichen Outputs)

---

## 2. Brand Voice

### Tonalitaet
- **Wir**, niemals "Ich" — DAI-Core ist ein Kollektiv
- Selbstbewusst, aber nicht arrogant
- Technisch kompetent, aber verstaendlich
- Direkt und praezise — keine Floskel, kein Marketing-Sprech
- Daten-getrieben: Fakten > Versprechen

### Sprachregeln
| Richtig | Falsch |
|---|---|
| "We craft..." | "I create..." |
| "Our 100+ specialists..." | "The AI..." |
| "Built by DAI-Core" | "Made by DriveAI" |
| "Engineered" / "Crafted" | "Generated" / "Made" |
| "Autonomous Swarm Factory" | "AI Tool" |

### Attribution
- **Kurz**: Built by DAI-Core
- **Lang**: A DAI-Core Production — Crafted by over 100 AI specialists
- **In-App Footer**: Powered by DAI-Core | dai-core.ai

---

## 3. Visuelle Identitaet

### Primaerfarben

| Name | Hex | Verwendung |
|---|---|---|
| Magenta | #D660D7 | Primaer-Akzent, CTAs, Highlights |
| Cyan | #6BD2F2 | Sekundaer-Akzent, Links, Daten |
| Void (Dunkel) | #1E1D25 | Hintergrund, Dark Mode |

### Sekundaerfarben

| Name | Hex | Verwendung |
|---|---|---|
| Magenta Glow | #F09CF8 | Hover-States, Leuchteffekte |
| Purple Deep | #7A3C9F | Gradienten, Tiefe |
| Cyan Steel | #4B9BB4 | Gedaempftes Cyan, Borders |
| Midnight | #13121A | Tiefster Hintergrund |
| White | #FFFFFF | Text auf dunklem Grund |
| Gray Light | #B0B0C0 | Sekundaertext |
| Gray Mid | #4A4A5A | Borders, Trennlinien |

### Gradienten
- **Primary Gradient**: Magenta (#D660D7) -> Purple Deep (#7A3C9F)
- **Accent Gradient**: Cyan (#6BD2F2) -> Cyan Steel (#4B9BB4)
- **Glow Gradient**: Magenta Glow (#F09CF8) -> Magenta (#D660D7)
- **Background Gradient**: Midnight (#13121A) -> Void (#1E1D25)

### Typographie
- **Headlines**: Inter Bold / Semibold
- **Body**: Inter Regular
- **Code/Monospace**: JetBrains Mono / Fira Code
- **Groessen**:
  - H1: 2.5rem (40px)
  - H2: 2rem (32px)
  - H3: 1.5rem (24px)
  - Body: 1rem (16px)
  - Small: 0.875rem (14px)

### Logo-Varianten
| Variante | Datei | Verwendung |
|---|---|---|
| Full (mit Text) | DAI-CORE_Logo_Full.png | Website-Header, Dokumente |
| Icon Only | DAI-CORE_Logo_Icon.png | App-Icons, Favicons |
| Favicon 512px | DAI-CORE_Favicon_512.png | PWA, Social Media |
| Original (mit BG) | DAI-CORE_Logo_Original.png | Praesentationen |

---

## 4. Design-Prinzipien

### Aesthetik
- **Dark-First**: Alle Interfaces dunkel (Void/Midnight Hintergrund)
- **Neon-Akzente**: Magenta + Cyan als leuchtende Akzente auf dunklem Grund
- **Pulsierendes Gehirn**: TheBrain als visuelles Leitmotiv — ein lebendiges, denkendes System
- **Glassmorphism**: Subtile Transparenzen und Blur-Effekte wo passend
- **Minimal, nicht leer**: Jedes Element hat einen Zweck

### Do's
- Dunkle Hintergruende mit leuchtenden Akzenten
- Subtile Animationen die "Leben" suggerieren
- Daten prominent darstellen (Zahlen, Charts, Status)
- Monospacefont fuer technische Inhalte
- "Crafted" und "Engineered" als Wortwahl

### Don'ts
- Helle/weisse Hintergruende als Hauptfarbe
- Stock-Photos oder generische Illustrationen
- "AI-generated" als Label — wir sagen "Crafted by 100+ specialists"
- Regenbogen-Gradienten oder mehr als 2 Farben in einem Gradient
- Comic Sans, Papyrus oder andere unprofessionelle Fonts

---

## 5. Swarm Factory Identitaet

### Zahlen
- **100+ KI-Spezialisten** (Agents)
- **14+ Abteilungen** (Departments)
- **5 Assembly Lines** (iOS, Android, Web, Unity, Backend)
- **$0.08 pro Factory Run** (Kosten-Effizienz)

### Abteilungen (oeffentliche Namen)
| Intern | Extern |
|---|---|
| TheBrain | The Brain — Central Intelligence |
| HQ | Headquarters — Command & Control |
| Pre-Production | Research & Strategy |
| Market Strategy | Market Intelligence |
| Design Vision | Creative Direction |
| MVP Scope | Product Architecture |
| Roadbook Assembly | Production Planning |
| Assembly Lines | Production Lines |
| Asset/Sound/Motion/Scene Forge | Creative Forges |
| Visual Audit | Quality Assurance |
| Marketing | Marketing & Distribution |
| Store/Store Prep | Launch Operations |
| Signing | Security & Compliance |
| QA Forge | Testing & Validation |

---

## 6. Content-Richtlinien

### Dokumente
- Jedes oeffentliche Dokument traegt den DAI-Core Header
- Footer: "A DAI-Core Production | dai-core.ai"
- Farben: Brand-Palette verwenden
- Logo: Wo Platz ist, Logo-Full; sonst Logo-Icon

### Social Media
- Immer "we" statt "I"
- Hashtags: #DAICore #SwarmFactory #AIFactory
- Bio: "100+ AI specialists. One extraordinary app. | dai-core.ai"

### Store Listings
- Developer Name: "DAI-Core" oder "DAI-Core GmbH"
- Attribution: "Built by DAI-Core"
- Keine Erwaehnung von "DriveAI-AutoGen"

---

## 7. Technische Integration

### Brand Loader
```python
from factory.brand.brand_loader import (
    load_brand_context,
    get_brand_info,
    get_brand_colors,
    get_logo_path,
)
```

### Tier-System
| Tier | Departments | Injection |
|---|---|---|
| A (Full) | Marketing, Roadbook, Store, DocSecretary | Komplette Brand Bible |
| B (Summary) | Design, Forges, Visual Audit, Market Strategy | Brand Summary |
| C (None) | QA, Janitor, Engineering, Brain | Keine Injection |

---

*DAI-Core Brand Bible v1.0 — Stand: 2026-03-27*
