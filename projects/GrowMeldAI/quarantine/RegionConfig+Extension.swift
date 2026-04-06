// Current problem (presumed):
// Views hardcode colors, fonts, region names scattered across codebase

// Solution: Extend RegionConfig with computed properties
extension RegionConfig {
    var accentColor: Color { /* per-region */ }
    var secondaryColor: Color { /* per-region */ }
    var localizedRegionName: String { /* Germany/Österreich/Schweiz */ }
    var flagEmoji: String { /* 🇩🇪 🇦🇹 🇨🇭 */ }
    var primaryFont: Font { /* region-specific typography */ }
}

// Views then reference: @EnvironmentObject var regionConfig: RegionConfig
Text("Willkommen")
    .foregroundColor(regionConfig.accentColor) // ← Consistent everywhere
    .font(regionConfig.primaryFont)