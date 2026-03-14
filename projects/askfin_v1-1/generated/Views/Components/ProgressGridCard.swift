import SwiftUI

struct ProgressGridCard: View {
    let summary: ProgressSummary
    
    private let columns = [
        GridItem(.flexible(minimum: 80), spacing: 12),
        GridItem(.flexible(minimum: 80), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "progress.overview", bundle: .module))
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                StatCard(
                    label: "progress.categories.label",
                    value: "\(summary.completedCategories)/\(summary.totalCategories)",
                    percentage: summary.completionPercentage,
                    icon: "list.bullet.circle.fill",
                    color: .blue,
                    accessibilityDescription: String(
                        format: NSLocalizedString(
                            "progress.categories.a11y",
                            bundle: .module,
                            comment: "Accessibility label for category progress"
                        ),
                        summary.completedCategories,
                        summary.totalCategories
                    )
                )
                
                StatCard(
                    label: "progress.accuracy.label",
                    value: "\(summary.accuracyPercentage)%",
                    percentage: summary.accuracyPercentage,
                    icon: "target",
                    color: .green,
                    accessibilityDescription: String(
                        format: NSLocalizedString(
                            "progress.accuracy.a11y",
                            bundle: .module,
                            comment: "Accessibility label for accuracy"
                        ),
                        summary.accuracyPercentage
                    )
                )
                
                StatCard(
                    label: "progress.answered.label",
                    value: "\(summary.questionsAnswered)",
                    percentage: nil,
                    icon: "checkmark.circle.fill",
                    color: .purple,
                    accessibilityDescription: String(
                        format: NSLocalizedString(
                            "progress.answered.a11y",
                            bundle: .module,
                            comment: "Accessibility label for questions answered"
                        ),
                        summary.questionsAnswered
                    )
                )
                
                StatCard(
                    label: "progress.average.label",
                    value: "\(summary.averageScore)",
                    percentage: summary.averageScore,
                    icon: "star.fill",
                    color: .orange,
                    accessibilityDescription: String(
                        format: NSLocalizedString(
                            "progress.average.a11y",
                            bundle: .module,
                            comment: "Accessibility label for average score"
                        ),
                        summary.averageScore
                    )
                )
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - StatCard Component (Accessibility Fixed)

private struct StatCard: View {
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
                .accessibilityHidden(true)  // Decorative
            
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityHidden(true)  // Included in combined label
            
            Text(String(localized: label, bundle: .module))
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)  // Included in combined label
            
            if let percentage = percentage, percentage > 0 {
                ProgressView(value: Double(percentage), total: 100)
                    .frame(height: 4)
                    .accessibilityHidden(true)  // Progress conveyed by label
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        // ✅ CRITICAL: Single accessible element with clear label
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