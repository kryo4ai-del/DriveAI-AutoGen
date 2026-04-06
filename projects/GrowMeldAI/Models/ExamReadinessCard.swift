struct ExamReadinessCard: View {
    let readiness: ExamReadinessScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ✅ ICON + TEXT + COLOR (not color alone)
            HStack(spacing: 8) {
                Image(systemName: iconForReadiness(readiness.readinessLevel))
                    .font(.title2)
                    .foregroundColor(colorForReadiness(readiness.readinessLevel))
                
                VStack(alignment: .leading) {
                    Text(labelForReadiness(readiness.readinessLevel))
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(Int(readiness.passProbability * 100))%")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            // ✅ TEXT DESCRIPTION (explicit, not color-dependent)
            Text(descriptionForReadiness(readiness.readinessLevel))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // ✅ CONFIDENCE RANGE
            VStack(alignment: .leading, spacing: 4) {
                Text("Konfidenzbereich:")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("\(Int(readiness.confidenceLower * 100))% – \(Int(readiness.confidenceUpper * 100))%")
                    .font(.caption)
                    .monospacedDigit()
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorForReadiness(readiness.readinessLevel), lineWidth: 2)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prüfungsvorbereitung")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
    }
    
    private var accessibilityValue: String {
        let percent = Int(readiness.passProbability * 100)
        let level = labelForReadiness(readiness.readinessLevel)
        let confidence = "\(Int(readiness.confidenceLower * 100))% bis \(Int(readiness.confidenceUpper * 100))%"
        
        return "\(level), \(percent)% Erfolgswahrscheinlichkeit, Konfidenzbereich: \(confidence)"
    }
    
    private var accessibilityHint: String {
        return descriptionForReadiness(readiness.readinessLevel)
    }
    
    private func iconForReadiness(_ level: ReadinessLevel) -> String {
        switch level {
        case .veryHighConfidence: return "checkmark.circle.fill"
        case .highConfidence: return "checkmark.circle"
        case .moderate: return "exclamationmark.circle"
        case .needsWork: return "exclamationmark.triangle.fill"
        case .notReady: return "xmark.circle.fill"
        }
    }
    
    private func labelForReadiness(_ level: ReadinessLevel) -> String {
        switch level {
        case .veryHighConfidence: return "Sehr hoch vorbereitet"
        case .highConfidence: return "Gut vorbereitet"
        case .moderate: return "Moderate Vorbereitung"
        case .needsWork: return "Noch Arbeit erforderlich"
        case .notReady: return "Nicht bereit"
        }
    }
    
    private func colorForReadiness(_ level: ReadinessLevel) -> Color {
        switch level {
        case .veryHighConfidence: return .green
        case .highConfidence: return .blue
        case .moderate: return .orange
        case .needsWork: return .red
        case .notReady: return .red
        }
    }
    
    private func descriptionForReadiness(_ level: ReadinessLevel) -> String {
        switch level {
        case .veryHighConfidence:
            return "Du bist sehr gut vorbereitet! Deine Chancen sind ausgezeichnet."
        case .highConfidence:
            return "Gute Vorbereitung. Noch ein bisschen üben für Sicherheit."
        case .moderate:
            return "Moderate Vorbereitung. Mehr Fokus auf schwache Kategorien."
        case .needsWork:
            return "Noch viel zu tun. Konzentriere dich auf deine Schwächen."
        case .notReady:
            return "Du bist noch nicht bereit. Intensives Üben erforderlich."
        }
    }
}