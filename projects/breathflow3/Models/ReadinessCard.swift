// Models/ReadinessCard.swift
import SwiftUI

struct ReadinessCardViewModel {
    let state: ReadinessState
    let motivationalMessage: String
    let progressPercentage: Double

    static func build(state: ReadinessState, correctAnswers: Int, totalQuestions: Int) -> ReadinessCardViewModel {
        let progress = totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) : 0
        let message: String
        switch state {
        case .topicsMastered:
            message = "Great job! You've mastered this topic."
        case .stillShaky:
            message = "Keep practicing to improve your confidence."
        case .notStarted:
            message = "Start practicing to track your progress."
        }
        return ReadinessCardViewModel(state: state, motivationalMessage: message, progressPercentage: progress)
    }
}

struct ReadinessCard: View {
    let viewModel: ReadinessCardViewModel
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(viewModel.state.accentColor)
                    .frame(width: 12, height: 12)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.state.displayText)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .accessibilityLabel(viewModel.state.accessibilityLabel)

                    if !viewModel.motivationalMessage.isEmpty {
                        Text(viewModel.motivationalMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.85)
                    }
                }
                Spacer()
            }

            if !isCompact {
                ProgressView(value: viewModel.progressPercentage)
                    .tint(viewModel.state.accentColor)
                    .accessibilityLabel("Progress: \(Int(viewModel.progressPercentage * 100))%")
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
    }
}

#Preview {
    VStack(spacing: 16) {
        ReadinessCard(
            viewModel: .build(state: .topicsMastered, correctAnswers: 10, totalQuestions: 10),
            isCompact: false
        )
        ReadinessCard(
            viewModel: .build(state: .stillShaky, correctAnswers: 5, totalQuestions: 10),
            isCompact: false
        )
    }
    .padding()
}
