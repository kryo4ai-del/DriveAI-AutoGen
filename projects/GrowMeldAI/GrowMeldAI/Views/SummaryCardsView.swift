import SwiftUI

struct SummaryCardsView: View {
    let criticalCount: Int
    let importantCount: Int
    let monitorCount: Int
    let nextReviewDate: Date?
    let daysUntilReview: Int?
    let overallSuccessRate: Double
    let readinessProgress: Double

    var body: some View {
        VStack(spacing: 12) {
            // Progress Card
            VStack(alignment: .leading, spacing: 8) {
                Text("Prüfungsreife")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ProgressView(value: readinessProgress)
                    .tint(Color.green)

                HStack {
                    Text("\(Int(readinessProgress * 100))% bereit")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(Int(overallSuccessRate * 100))% Erfolg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            // Focus Level Cards
            HStack(spacing: 12) {
                FocusLevelSummaryCard(
                    level: .critical,
                    count: criticalCount,
                    color: Color(red: 1.0, green: 0.2, blue: 0.2)
                )

                FocusLevelSummaryCard(
                    level: .important,
                    count: importantCount,
                    color: Color(red: 1.0, green: 0.6, blue: 0.2)
                )

                FocusLevelSummaryCard(
                    level: .monitor,
                    count: monitorCount,
                    color: Color(red: 1.0, green: 0.85, blue: 0.2)
                )
            }
            .padding(.horizontal)

            // Next Review Card
            if let daysUntil = daysUntilReview, daysUntil >= 0 {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.accentColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nächste Wiederholung")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(daysUntil == 0 ? "Heute" : "in \(daysUntil) Tag\(daysUntil != 1 ? "en" : "")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

struct FocusLevelSummaryCard: View {
    let level: FocusLevel
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)

            Text(level.displayName)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}