// Instead of "Streak: 5", show exam readiness
struct ExamReadinessIndicator: View {
    let daysUntilExam: Int
    let questionsAnsweredThisWeek: Int
    let accuracyRate: Double
    let streak: Int
    
    var readinessPercentage: Double {
        // Science-based calculation (spaced repetition principle)
        let answeringCoverage = min(Double(questionsAnsweredThisWeek) / 35.0, 1.0)
        let accuracyComponent = min(accuracyRate, 1.0) * 0.6
        let consistencyBonus = Double(streak) / 14.0 * 0.4
        
        return (answeringCoverage * accuracyComponent) + consistencyBonus
    }
    
    var readinessLabel: String {
        switch readinessPercentage {
        case 0.0..<0.3: return "Noch viel zu lernen"
        case 0.3..<0.6: return "Gute Fortschritte"
        case 0.6..<0.8: return "Gut vorbereitet"
        case 0.8...1.0: return "Prüfungsreif! 🚗"
        default: return "Unbekannt"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prüfungsvorbereitung")
                        .font(.caption)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    
                    Text(readinessLabel)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: readinessPercentage)
                        .stroke(readinessColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(readinessPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .frame(width: 60, height: 60)
            }
            
            // Sub-metrics
            VStack(spacing: 8) {
                MetricRow(
                    label: "Diese Woche",
                    value: "\(questionsAnsweredThisWeek) Fragen",
                    target: 35,
                    icon: "calendar"
                )
                MetricRow(
                    label: "Genauigkeit",
                    value: "\(Int(accuracyRate * 100))%",
                    target: 90,
                    icon: "target"
                )
                MetricRow(
                    label: "Konsistenz",
                    value: "\(streak) Tage",
                    target: 14,
                    icon: "flame.fill"
                )
                MetricRow(
                    label: "Bis zur Prüfung",
                    value: "\(daysUntilExam) Tage",
                    target: 1,
                    icon: "calendar.circle.fill"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var readinessColor: Color {
        switch readinessPercentage {
        case 0.0..<0.3: return .red
        case 0.3..<0.6: return .orange
        case 0.6..<0.8: return .yellow
        case 0.8...1.0: return .green
        default: return .gray
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let target: Int
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}