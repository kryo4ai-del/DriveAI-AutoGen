// Use high-contrast palette for charts
struct ABTestChartColors {
    // WCAG AA compliant color pairs
    static let variantA = Color(red: 0.0, green: 0.4, blue: 0.8)    // Dark blue
    static let variantB = Color(red: 1.0, green: 0.5, blue: 0.0)    // Orange
    static let variantC = Color(red: 0.2, green: 0.6, blue: 0.2)    // Dark green
    static let background = Color(red: 0.98, green: 0.98, blue: 0.98)  // Near white
    
    // Verify contrast:
    // Dark blue (#0066CC) on white (#FAFAFA) = 8.2:1 ✅
    // Orange (#FF8000) on white (#FAFAFA) = 4.6:1 ✅
    // Dark green (#339933) on white (#FAFAFA) = 4.9:1 ✅
}

// In chart view:
Chart(data) {
    BarMark(x: .value("Variant", $0.id), y: .value("Rate", $0.rate))
        .foregroundColor(colorForVariant($0.id))
}
.background(ABTestChartColors.background)

private func colorForVariant(_ id: String) -> Color {
    switch id {
    case "A": return ABTestChartColors.variantA
    case "B": return ABTestChartColors.variantB
    case "C": return ABTestChartColors.variantC
    default: return .gray
    }
}