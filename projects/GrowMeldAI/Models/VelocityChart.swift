struct VelocityChart: View {
    let velocityTrend: [Double]
    let dateRange: (start: Date, end: Date)
    
    var body: some View {
        VStack {
            Canvas { context in
                // Draw sparkline as before
            }
            .accessibilityElement(children: .ignore)  // Hide visual from VoiceOver
            .accessibilityLabel("Wöchentliche Lerngeschwindigkeit")
            .accessibilityValue(accessibilityDescription)
            .accessibilityHint("Zeigt Fragen pro Tag für die letzte Woche an")
            
            // ✅ Text alternative below chart
            DisclosureGroup("Zahlen anzeigen") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(velocityTrend.enumerated()), id: \.offset) { index, value in
                        let dayOffset = index - velocityTrend.count + 1
                        let dayLabel = dayName(daysAgo: dayOffset)
                        Text("\(dayLabel): \(String(format: "%.1f", value)) Fragen/Tag")
                            .font(.caption)
                            .accessibilityElement(children: .combine)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
        }
    }
    
    private var accessibilityDescription: String {
        let min = velocityTrend.min() ?? 0
        let max = velocityTrend.max() ?? 0
        let avg = velocityTrend.reduce(0, +) / Double(velocityTrend.count)
        let trend: String
        
        if velocityTrend.last ?? 0 > velocityTrend.first ?? 0 {
            trend = "steigend"
        } else if velocityTrend.last ?? 0 < velocityTrend.first ?? 0 {
            trend = "fallend"
        } else {
            trend = "stabil"
        }
        
        return "Minimum \(String(format: "%.1f", min)), "
            + "Maximum \(String(format: "%.1f", max)), "
            + "Durchschnitt \(String(format: "%.1f", avg)), "
            + "Tendenz \(trend)"
    }
    
    private func dayName(daysAgo: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysAgo, to: Date())!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}