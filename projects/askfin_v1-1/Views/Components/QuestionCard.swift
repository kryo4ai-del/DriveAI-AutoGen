import SwiftUI

/// A compact card for the dashboard showing a quick practice question preview.
struct QuestionCard: View {
    let categoryName: String
    let questionCount: Int
    let bestScore: Int?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)

                    Spacer()

                    if let score = bestScore {
                        Text("\(score)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(score >= 75 ? .green : .orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill((score >= 75 ? Color.green : Color.orange).opacity(0.15))
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(categoryName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("\(questionCount) Fragen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(categoryName), \(questionCount) Fragen")
        .accessibilityHint("Tippen zum Starten")
    }
}
