// Views/Dashboard/CategoryGridItemView.swift
struct CategoryGridItemView: View {
    let categoryStats: CategoryStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category Name
            Text(categoryStats.categoryName)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            // Mastery Progress
            ProgressView(value: categoryStats.masteryPercentage)
                .accessibilityLabel("Beherrschungsgrad")
                .accessibilityValue("\(Int(categoryStats.masteryPercentage * 100))%")
                .accessibilityHint("Zeigt Ihren Fortschritt in dieser Kategorie")
            
            // Stats Row
            HStack(spacing: 12) {
                Label(
                    "\(categoryStats.correctAttempts)/\(categoryStats.totalAttempts)",
                    systemImage: "checkmark.circle.fill"
                )
                .accessibilityLabel(
                    "\(categoryStats.correctAttempts) von \(categoryStats.totalAttempts) Fragen korrekt"
                )
                
                Spacer()
                
                if let lastReview = categoryStats.lastReviewDate {
                    Label(
                        RelativeDateTimeFormatter().localizedString(for: lastReview, relativeTo: Date()),
                        systemImage: "calendar"
                    )
                    .accessibilityLabel("Zuletzt überprüft: \(formatDate(lastReview))")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}