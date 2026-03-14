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

    private var totalCount: Int {
        session.completedQuestions.count
    }

    private var correctCount: Int {
        session.correctAnswerCount
    }

    private var accuracy: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount)
    }

    private var accuracyPercent: String {
        "\(Int(accuracy * 100))%"
    }

    private var hasWeakTopics: Bool {
        !competenceService.weakestTopics().isEmpty
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                accuracyHeader
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

            Text("\(correctCount) von \(totalCount) richtig")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(accuracyPercent) richtig. \(correctCount) von \(totalCount) Fragen korrekt beantwortet.")
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
