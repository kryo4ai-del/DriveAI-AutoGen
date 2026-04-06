// ✅ CORRECT: Add accessible data summary

struct TrendSparklineView: View {
    let dataPoints: [DateValuePair]
    let metricType: PerformanceMetric.MetricType
    
    var body: some View {
        ZStack {
            Canvas { context in
                // Chart drawing code (unchanged)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trend-Chart für \(metricType.accessibilityLabel)")
        .accessibilityValue(accessibleDataSummary())
        .accessibilityHint("Wischen mit zwei Fingern nach oben, um detaillierte Datenpunkte zu hören")
    }
    
    private func accessibleDataSummary() -> String {
        guard !dataPoints.isEmpty else { return "Keine Daten verfügbar" }
        
        let first = dataPoints.first!.value
        let last = dataPoints.last!.value
        let change = last - first
        let changePercent = (change / first) * 100
        let min = dataPoints.min(by: { $0.value < $1.value })?.value ?? 0
        let max = dataPoints.max(by: { $0.value < $1.value })?.value ?? 0
        
        return """
        7-Tage-Zusammenfassung:
        Start: \(Int(first)),
        Ende: \(Int(last)),
        Änderung: \(String(format: "%.1f", changePercent))%,
        Minimum: \(Int(min)),
        Maximum: \(Int(max))
        """
    }
}

// Add rotor for accessible chart navigation
extension TrendSparklineView {
    func accessibilityRotor(_ rotorLabel: String, 
                           _ items: [String]) -> some View {
        self.accessibilityRotor(rotorLabel) {
            AccessibilityRotorEntry(items.joined(separator: "; "))
        }
    }
}