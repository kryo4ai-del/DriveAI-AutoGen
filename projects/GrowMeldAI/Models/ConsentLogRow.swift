// ✅ FIXED: Add accessibility labels to views displaying logs
struct ConsentLogRow: View {
    let log: ConsentLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDecision(log.decision))
                .font(.headline)
                .accessibilityLabel("Zustimmungsentscheidung")
                .accessibilityValue(formatDecision(log.decision))
            
            HStack {
                Label("Zeitpunkt", systemImage: "clock")
                Spacer()
                Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .accessibilityHidden(true) // Parent label covers it
            }
            
            HStack {
                Label("Grund", systemImage: "info.circle")
                Spacer()
                Text(log.context)
                    .accessibilityHidden(true)
            }
            
            if let withdrawalDate = log.withdrawalDate {
                HStack {
                    Label("Widerrufen am", systemImage: "xmark.circle")
                    Spacer()
                    Text(withdrawalDate.formatted(date: .abbreviated, time: .shortened))
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Zustimmungseintrag")
        .accessibilityValue("\(formatDecision(log.decision)) am \(log.timestamp.formatted())")
    }
    
    private func formatDecision(_ decision: LocationPermissionState) -> String {
        switch decision {
        case .authorized:
            return "Gewährt"
        case .denied:
            return "Verweigert"
        case .notDetermined:
            return "Nicht bestimmt"
        case .restricted:
            return "Eingeschränkt"
        case .requestingConsent:
            return "In Anfrage"
        }
    }
}