// MARK: - Features/Quiz/Views/QuizResultsView.swift
import SwiftUI

// MARK: - Supporting Types

private enum ReadinessLevel {
    case low, medium, high

    var color: Color {
        switch self {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        }
    }

    var label: String {
        switch self {
        case .low: return "Niedrig"
        case .medium: return "Mittel"
        case .high: return "Hoch"
        }
    }
}

private struct LocalQuizQuestion {
    let text: String
    let topic: String
}

private struct LocalQuizState {
    var questions: [LocalQuizQuestion] = []
    var currentIndex: Int = 0
    var answers: [Bool] = []
}

// MARK: - ViewModel

private class QuizViewModel: ObservableObject {
    @Published var state: LocalQuizState = LocalQuizState()
    @Published var score: Int = 0

    var scorePercentage: Int {
        guard !state.questions.isEmpty else { return 0 }
        return Int((Double(score) / Double(state.questions.count)) * 100)
    }

    var readinessLevel: ReadinessLevel {
        switch scorePercentage {
        case 0..<40: return .low
        case 40..<70: return .medium
        default: return .high
        }
    }

    var weakTopics: [String] {
        var topicResults: [String: (correct: Int, total: Int)] = [:]
        for (index, question) in state.questions.enumerated() {
            let topic = question.topic
            let isCorrect = index < state.answers.count ? state.answers[index] : false
            if topicResults[topic] == nil {
                topicResults[topic] = (0, 0)
            }
            topicResults[topic]!.total += 1
            if isCorrect { topicResults[topic]!.correct += 1 }
        }
        return topicResults.filter { $0.value.correct < $0.value.total }.map { $0.key }
    }

    func resetQuiz() {
        score = 0
        state = LocalQuizState(questions: state.questions, currentIndex: 0, answers: [])
    }
}

// MARK: - ReadinessIndicatorView

private struct ReadinessIndicatorView: View {
    let level: ReadinessLevel
    let weakTopics: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bereitschaft:")
                    .font(.headline)
                Spacer()
                Text(level.label)
                    .font(.headline)
                    .foregroundColor(level.color)
            }

            if !weakTopics.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Schwache Themen:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ForEach(weakTopics, id: \.self) { topic in
                        Text("• \(topic)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - QuizResultsView

struct QuizResultsView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Ergebnis")
                    .font(.title)
                    .fontWeight(.bold)

                // Score
                VStack(spacing: 8) {
                    Text("\(viewModel.scorePercentage)%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(viewModel.readinessLevel.color)

                    Text("\(viewModel.score) von \(viewModel.state.questions.count) korrekt")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            // Readiness indicator
            ReadinessIndicatorView(
                level: viewModel.readinessLevel,
                weakTopics: viewModel.weakTopics
            )
            .padding(.horizontal)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.resetQuiz()
                }) {
                    Text("Quiz wiederholen")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("Zurück")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .padding()
    }
}