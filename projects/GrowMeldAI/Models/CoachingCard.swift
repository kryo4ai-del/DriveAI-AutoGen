import SwiftUI

struct CoachingCard: View {
    let recommendation: CoachingRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.headline)
                    .font(.headline)
                    .accessibilityLabel("Coaching-Titel")
                    .accessibilityValue(recommendation.headline)
                    .accessibilityAddTraits(.isHeader)

                Text(recommendation.evidence)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Evidenz")
                    .accessibilityValue(recommendation.evidence)
            }
            .accessibilityElement(children: .combine)

            Text(recommendation.psychologicalCue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Lernratschlag")
                .accessibilityValue(recommendation.psychologicalCue)

            VStack(alignment: .leading, spacing: 8) {
                Text("Empfohlene Aktionen")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)

                ForEach(Array(recommendation.actionItems.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .accessibilityHidden(true)

                        Text(item)
                            .font(.caption)
                            .accessibilityLabel("Aktion")
                            .accessibilityValue("\(index + 1). \(item)")
                    }
                }
            }
            .accessibilityElement(children: .contain)

            priorityBadge
                .accessibilityLabel("Priorität")
                .accessibilityValue(recommendation.priority.accessibilityDescription)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isSummaryElement)
    }

    @ViewBuilder
    private var priorityBadge: some View {
        switch recommendation.priority {
        case .immediate:
            Label("Sofort", systemImage: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(4)
                .background(Color.red)
                .cornerRadius(6)
        case .soon:
            Label("Bald", systemImage: "clock.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(4)
                .background(Color.orange)
                .cornerRadius(6)
        case .maintenance:
            Label("Wartung", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(4)
                .background(Color.green)
                .cornerRadius(6)
        }
    }
}

extension CoachingRecommendation.CoachingPriority {
    var accessibilityDescription: String {
        switch self {
        case .immediate: return "Sofort erforderlich"
        case .soon: return "Bald erforderlich"
        case .maintenance: return "Routinewartung"
        }
    }
}