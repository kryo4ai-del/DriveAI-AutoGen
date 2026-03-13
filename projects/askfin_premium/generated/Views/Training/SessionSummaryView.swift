import SwiftUI

/// Post-session results with per-topic accuracy and competence changes.
///
/// Shows total accuracy, per-topic breakdown with change indicators,
/// overall readiness delta, and streak counter. German UI text.
struct SessionSummaryView: View {

    let session: TrainingSession
    @ObservedObject var competenceService: TopicCompetenceService
    let preSessionLevels: [TopicArea: CompetenceLevel]
    let onTrainWeaknesses: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Computed

    private var accuracy: Double {
        guard session.totalCount > 0 else { return 0 }
        return Double(session.correctCount) / Double(session.totalCount)
    }

    private var accuracyPercent: String {
        "\(Int(accuracy * 100))%"
    }

    private var hasWeakTopics: Bool {
        !competenceService.weakestTopics().isEmpty
    }

    private var topicResults: [(topic: TopicArea, correct: Int, total: Int)] {
        var grouped: [TopicArea: (correct: Int, total: Int)] = [:]
        for result in session.results {
            let existing = grouped[result.topic, default: (0, 0)]
            grouped[result.topic] = (
                existing.correct + (result.wasCorrect ? 1 : 0),
                existing.total + 1
            )
        }
        return grouped.map { (topic: $0.key, correct: $0.value.correct, total: $0.value.total) }
            .sorted { $0.topic.displayName < $1.topic.displayName }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                accuracyHeader
                Divider().background(Color.white.opacity(0.15))
                topicBreakdown
                Divider().background(Color.white.opacity(0.15))
                actionButtons
            }
            .padding(24)
        }
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Accuracy Header

    private var accuracyHeader: some View {
        VStack(spacing: 8) {
            Text(accuracyPercent)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(accuracy >= 0.7 ? .green : .orange)

            Text("\(session.correctCount) von \(session.totalCount) richtig")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(accuracyPercent) richtig. \(session.correctCount) von \(session.totalCount) Fragen korrekt beantwortet.")
    }

    // MARK: - Topic Breakdown

    private var topicBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Themen-Übersicht")
                .font(.headline)
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)

            ForEach(topicResults, id: \.topic) { item in
                topicRow(item)
            }
        }
    }

    private func topicRow(_ item: (topic: TopicArea, correct: Int, total: Int)) -> some View {
        let currentLevel = competenceService.competences[item.topic]?.competenceLevel ?? .notStarted
        let previousLevel = preSessionLevels[item.topic] ?? .notStarted
        let changeIndicator = competenceChangeSymbol(previous: previousLevel, current: currentLevel)

        return HStack(spacing: 12) {
            // Topic icon + name
            Image(systemName: item.topic.symbolName)
                .font(.caption)
                .foregroundStyle(currentLevel.fillColor)
                .frame(width: 24)

            Text(item.topic.displayName)
                .font(.body)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Score
            Text("\(item.correct)/\(item.total)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(item.correct == item.total ? .green : .white)

            // Change indicator
            Text(changeIndicator)
                .font(.caption)
                .frame(width: 20)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(item.topic.displayName): \(item.correct) von \(item.total) richtig. "
            + "Kompetenz: \(currentLevel.displayName)."
        )
    }

    private func competenceChangeSymbol(previous: CompetenceLevel, current: CompetenceLevel) -> String {
        if current > previous { return "↑" }
        if current < previous { return "↓" }
        return "→"
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if hasWeakTopics {
                Button(action: onTrainWeaknesses) {
                    HStack {
                        Image(systemName: "target")
                        Text("Schwächen trainieren")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.green)
                    )
                }
                .accessibilityLabel("Schwächen trainieren")
                .accessibilityHint("Startet eine neue Session mit deinen schwächsten Themen")
            }

            Button(action: onDismiss) {
                Text("Fertig")
                    .font(.body)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .accessibilityLabel("Fertig")
            .accessibilityHint("Zurück zum Hauptmenü")
        }
    }
}
