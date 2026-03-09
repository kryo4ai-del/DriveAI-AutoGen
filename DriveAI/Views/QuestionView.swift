// Views/QuestionView.swift
import SwiftUI

// MARK: - QuestionView

struct QuestionView: View {
    @StateObject var viewModel = QuestionViewModel()
    var question: Question
    var mode: LearningMode = .assist

    @State private var isResultPresented = false
    @State private var buttonState: ButtonState = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Question text
            Text(question.text)
                .font(.title3)
                .bold()
                .padding(.horizontal)
                .padding(.top)

            // Answer options
            ForEach(question.options) { option in
                answerButton(for: option)
            }

            // Submit — Learning Mode only, after selection
            if mode == .learning,
               viewModel.selectedAnswer != nil,
               !viewModel.userSubmitted {
                Button(action: {
                    viewModel.submitAnswer()
                    buttonState = .loading
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isResultPresented = true
                        buttonState = .ready
                    }
                }) {
                    Text("Submit Answer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(buttonState == .loading)
            }

            Spacer()
        }
        .navigationTitle("Question")
        .onAppear { viewModel.load(question, mode: mode) }
        .sheet(isPresented: $isResultPresented) {
            LearningResultView(viewModel: viewModel)
        }
        .padding(.bottom)
    }

    @ViewBuilder
    private func answerButton(for option: Answer) -> some View {
        let isSelected = viewModel.selectedAnswer?.id == option.id
        let isCorrect  = option.id == question.correctAnswerId
        let submitted  = viewModel.userSubmitted

        Button(action: {
            switch mode {
            case .assist:
                viewModel.submitAnswerImmediate(option)
                buttonState = .loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isResultPresented = true
                    buttonState = .ready
                }
            case .learning:
                viewModel.selectAnswer(option)
            }
        }) {
            HStack {
                Text(option.text)
                    .foregroundColor(.primary)
                Spacer()
                if submitted {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : ""))
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(buttonBackground(isSelected: isSelected, isCorrect: isCorrect, submitted: submitted))
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .disabled(submitted || buttonState == .loading)
    }

    private func buttonBackground(isSelected: Bool, isCorrect: Bool, submitted: Bool) -> Color {
        if submitted {
            if isCorrect  { return Color.green.opacity(0.2) }
            if isSelected { return Color.red.opacity(0.2) }
            return Color(.systemGray6)
        }
        return isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6)
    }
}

// MARK: - LearningResultView

struct LearningResultView: View {
    @ObservedObject var viewModel: QuestionViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Result header
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                    Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                }
                .padding(.top, 4)

                // Answer comparison card
                if viewModel.selectedAnswer != nil || viewModel.correctAnswer != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        if let userAnswer = viewModel.selectedAnswer {
                            answerRow(label: "Your Answer", value: userAnswer.text,
                                      color: viewModel.isCorrect ? .green : .red)
                        }
                        if viewModel.selectedAnswer != nil, viewModel.correctAnswer != nil {
                            Divider()
                        }
                        if let correct = viewModel.correctAnswer {
                            answerRow(label: "Correct Answer", value: correct.text, color: .green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Explanation card
                if let result = viewModel.answerResult {
                    explanationCard(result.explanation)
                    confidenceCard(score: result.confidence.score,
                                   label: result.confidence.label,
                                   percentage: result.confidence.percentage)
                } else if let question = viewModel.question {
                    explanationCard(question.explanation)
                }
            }
            .padding()
        }
        .navigationTitle("Result")
    }

    // MARK: - Sub-views

    private func answerRow(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .bold()
                .foregroundColor(color)
        }
    }

    private func explanationCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explanation")
                .font(.headline)
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func confidenceCard(score: Double, label: String, percentage: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confidence")
                .font(.headline)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(confidenceColor(score))
                        .frame(width: geo.size.width * score, height: 8)
                }
            }
            .frame(height: 8)
            Text("\(label) – \(percentage)%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}
