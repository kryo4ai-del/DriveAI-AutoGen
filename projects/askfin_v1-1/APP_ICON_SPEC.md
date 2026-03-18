# AskFin — App Icon Spezifikation

## Technische Anforderungen (Apple)

- **Format**: PNG, keine Transparenz, keine abgerundeten Ecken (Apple macht das automatisch)
- **Größe**: 1024 x 1024 Pixel
- **Farbprofil**: sRGB
- **Ablage**: `Resources/Assets.xcassets/AppIcon.appiconset/icon_1024.png`

## Design-Richtlinien

- **Farbe**: App-Grün (#34C744) als Hauptfarbe, schwarzer Hintergrund
- **Stil**: Minimalistisch, dunkel, konsistent mit App UI
- **Motiv-Vorschläge**:
  - Stilisiertes Steuerrad + Checkmark
  - "AF" Monogramm in grün auf schwarz
  - Straßenschild-Silhouette mit grünem Akzent
- **Vermeiden**: Text (wird zu klein), Fotos, zu viele Details

## Nach Erstellung

1. PNG als `icon_1024.png` in `Resources/Assets.xcassets/AppIcon.appiconset/` ablegen
2. `Contents.json` aktualisieren: `"filename": "icon_1024.png"` hinzufügen
3. Build prüfen: `xcodegen generate && xcodebuild build`
