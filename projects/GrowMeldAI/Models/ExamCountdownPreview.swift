struct ExamCountdownPreview: View {
    let daysUntilExam: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("In \(daysUntilExam) Tagen")
                        .font(.title2.bold())
                    Text("Du wirst bereit sein")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1.5))
        }
        // ✅ ADD ACCESSIBILITY WRAPPER
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prüfungs-Countdown")
        .accessibilityValue("\(daysUntilExam) Tage verbleibend")
        .accessibilityHint("Mit diesem Lernplan wirst du bereit sein")
    }
}