import SwiftUI

struct ProgressGridCard: View {
    let summary: ProgressSummary

    private let columns = [
        GridItem(.flexible(minimum: 80), spacing: 12),
        GridItem(.flexible(minimum: 80), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fortschritt")
                .font(.headline)
                .foregroundColor(.primary)

            LazyVGrid(columns: columns, spacing: 12) {
                PremiumStatCard(
                    label: "Kategorien",
                    value: "\(summary.completedCategories)/\(summary.totalCategories)",
                    percentage: summary.completionPercentage,
                    icon: "list.bullet.circle.fill",
                    color: .blue,
                    accessibilityDescription: "\(summary.completedCategories) von \(summary.totalCategories) Kategorien abgeschlossen"
                )

                PremiumStatCard(
                    label: "Genauigkeit",
                    value: "\(summary.accuracyPercentage)%",
                    percentage: summary.accuracyPercentage,
                    icon: "target",
                    color: .green,
                    accessibilityDescription: "\(summary.accuracyPercentage) Prozent Genauigkeit"
                )

                PremiumStatCard(
                    label: "Beantwortet",
                    value: "\(summary.questionsAnswered)",
                    percentage: nil,
                    icon: "checkmark.circle.fill",
                    color: .purple,
                    accessibilityDescription: "\(summary.questionsAnswered) Fragen beantwortet"
                )

                PremiumStatCard(
                    label: "Durchschnitt",
                    value: "\(summary.averageScore)",
                    percentage: summary.averageScore,
                    icon: "star.fill",
                    color: .orange,
                    accessibilityDescription: "Durchschnitt \(summary.averageScore) Prozent"
                )
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - PremiumStatCard Component

private struct PremiumStatCard: View {
    let label: String
    let value: String
    let percentage: Int?
    let icon: String
    let color: Color
    let accessibilityDescription: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .accessibilityHidden(true)

            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityHidden(true)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)

            if let percentage = percentage, percentage > 0 {
                ProgressView(value: Double(percentage), total: 100)
                    .frame(height: 4)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityDescription))
    }
}

#Preview {
    ProgressGridCard(
        summary: ProgressSummary(
            totalCategories: 12,
            completedCategories: 7,
            averageScore: 82,
            questionsAnswered: 156,
            correctAnswers: 128
        )
    )
    .padding()
}
