import SwiftUI

struct ProgressCardView: View {
    let progress: CategoryProgress
    let examGoal: ExamGoal?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(progress.categoryName)
                    .font(.headline)
                Spacer()
                Text(progress.masteryLevel)
                    .font(.caption)
                    .foregroundColor(progress.examReadiness >= 0.75 ? .green : .orange)
            }

            ProgressView(value: progress.examReadiness)
                .tint(progress.examReadiness >= 0.75 ? .green : .orange)

            Text(progress.motivationalMessage)
                .font(.caption)
                .foregroundColor(.secondary)

            if let examGoal = examGoal {
                Text(progress.examReadinessMessage(examGoal: examGoal))
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}