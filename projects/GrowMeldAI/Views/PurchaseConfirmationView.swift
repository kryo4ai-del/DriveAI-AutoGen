struct PurchaseConfirmationView: View {
    let previousProgress: Int  // e.g., 42%
    let examDate: Date
    let daysRemaining: Int
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Du bist bereit!")  // "You're ready!"
                        .font(.headline)
                    Text("Dein Fortschritt: \(previousProgress)% → Ziel: 95%+")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.green)
            }
            
            ProgressView(value: Double(previousProgress) / 100)
                .tint(.green)
            
            Text("Mit Premium und \(daysRemaining) Tagen bis zur Prüfung:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Vollständiger Fragenkatalog", systemImage: "checkmark")
                Label("Unbegrenzte Testversuche", systemImage: "checkmark")
                Label("Detaillierte Auswertungen", systemImage: "checkmark")
            }
            .font(.body)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Jetzt durchstarten!")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}