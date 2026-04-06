import SwiftUI

struct WeaknessListItemView: View {
    let weakness: WeaknessPattern

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weakness.categoryName)
                        .font(.headline)

                    Text("\(weakness.failedQuestionCount) Frage\(weakness.failedQuestionCount != 1 ? "n" : "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                FocusLevelBadge(level: weakness.recommendedFocusLevel)
            }

            // Confidence Gauge
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Erfolgsquote")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(weakness.formattedSuccessRate)
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                ProgressView(value: weakness.successRate)
                    .tint(weakness.successRate > 0.7 ? Color.green :
                          weakness.successRate > 0.4 ? Color.orange : Color.red)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}