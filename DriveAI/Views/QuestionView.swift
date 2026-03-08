// Views/QuestionView.swift
import SwiftUI

// MARK: - ButtonState
enum ButtonState {
    case idle, loading, ready
}

// MARK: - QuestionView
struct QuestionView: View {
    @StateObject var viewModel = QuestionViewModel()
    var question: Question
    var mode: LearningMode = .assist

    @State private var isResultPresented = false
    @State private var buttonState: ButtonState = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.text)
                .font(.title3)
                .bold()
                .padding(.horizontal)
                .padding(.top)

            ForEach(question.options) { option in
                answerButton(for: option)
            }

            // Submit button — Learning Mode only, after selection, before submit
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
                        .bold()
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
            if isCorrect { return Color.green.opacity(0.25) }
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
                HStack {
                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                    Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                }
                .padding(.top)

                if let userAnswer = viewModel.selectedAnswer {
                    resultRow(label: "Your Answer", value: userAnswer.text,
                              color: viewModel.isCorrect ? .green : .red)
                }

                if let correct = viewModel.correctAnswer {
                    resultRow(label: "Correct Answer", value: correct.text, color: .green)
                }

                if let result = viewModel.answerResult {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Explanation").font(.headline)
                        Text(result.explanation).font(.body).foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confidence: \(result.confidence.label) (\(result.confidence.percentage)%)")
                            .font(.subheadline).foregroundColor(.secondary)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5)).frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(confidenceColor(result.confidence.score))
                                    .frame(width: geo.size.width * result.confidence.score, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                } else if let question = viewModel.question {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Explanation").font(.headline)
                        Text(question.explanation).font(.body).foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Result")
    }

    private func resultRow(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value).font(.body).bold().foregroundColor(color)
        }
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}
