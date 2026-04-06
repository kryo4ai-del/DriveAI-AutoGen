struct ExamCenterRow: View {
    let center: ExamCenter
    let distance: Double?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // ✅ Main location name with strong emphasis
                Text(center.name)
                    .font(.headline)
                    .accessibilityLabel("Prüfungszentrum")
                    .accessibilityValue(center.name)
                
                // ✅ Address group with clear labeling
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label("Adresse", systemImage: "mappin.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Text(center.address)
                        .font(.body)
                    HStack {
                        Text(center.postalCode)
                        Text(center.city)
                        Spacer()
                    }
                    .font(.body)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Adresse")
                .accessibilityValue("\(center.address), \(center.postalCode) \(center.city)")
                
                // ✅ Distance (if available)
                if let distance = distance {
                    HStack {
                        Label("Entfernung", systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f km", distance))
                            .font(.caption)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Entfernung")
                    .accessibilityValue(String(format: "%.1f Kilometer", distance))
                }
                
                // ✅ Availability status
                if let slots = center.availableSlots, slots > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(slots) Plätze verfügbar")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Verfügbarkeit")
                    .accessibilityValue("\(slots) Prüfungstermine verfügbar")
                }
                
                // ✅ Contact info (if available)
                if let phone = center.phoneNumber {
                    HStack {
                        Label("Telefon", systemImage: "phone.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(phone)
                            .font(.caption)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Telefon")
                    .accessibilityValue(phone)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prüfungszentrum")
        .accessibilityValue(
            "\(center.name) in \(center.city). " +
            (distance.map { String(format: "%.1f Kilometer entfernt", $0) } ?? "Entfernung unbekannt") +
            (center.availableSlots.map { ". \($0) Plätze verfügbar" } ?? "")
        )
        .accessibilityHint("Doppeltippen um Details zu sehen")
    }
}