import SwiftUI

// MARK: - RecommendationsSection

/// Displays up to three prioritised recommendations from `snapshot.topRecommendations`.
struct RecommendationsSection: View {

    let snapshot: ExamReadinessSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Empfehlungen")
                .font(.title3.weight(.semibold))

            if snapshot.topRecommendations.isEmpty {
                emptyState
            } else {
                ForEach(snapshot.topRecommendations) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            }
        }
    }

    private var emptyState: some View {
        Text("Keine Empfehlungen – du bist bestens vorbereitet! 🎯")
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
    }
}