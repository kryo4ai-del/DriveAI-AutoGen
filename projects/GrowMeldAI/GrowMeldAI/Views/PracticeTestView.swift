// File: PracticeTestView.swift
import SwiftUI

struct PracticeTestView: View {
    @StateObject private var viewModel: PracticeTestViewModel
    @Environment(\.dismiss) private var dismiss

    init(testType: TestType) {
        _viewModel = StateObject(wrappedValue: PracticeTestViewModel(testType: testType))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressIndicatorView(progress: viewModel.progress)

                TabView(selection: $viewModel.currentQuestionIndex) {
                    ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionView(question: question,
                                    isLastQuestion: index == viewModel.questions.count - 1,
                                    answerSelected: { selectedOption in
                            viewModel.selectAnswer(selectedOption, for: question.id)
                        })
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(viewModel.testType.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(viewModel.isLastQuestion ? "Submit" : "Next") {
                        viewModel.handleNext()
                    }
                    .disabled(!viewModel.canProceed)
                }
            }
            .interactiveDismissDisabled()
            .alert("Submit Test", isPresented: $viewModel.showingSubmitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Submit", role: .destructive) {
                    viewModel.submitTest()
                }
            } message: {
                Text("Are you sure you want to submit your test?")
            }
            .sheet(isPresented: $viewModel.showingResults) {
                TestResultsView(results: viewModel.results,
                              onRetry: { viewModel.resetTest() },
                              onReview: { viewModel.resetTest() })
            }
        }
    }
}

// MARK: - View Components

private struct ProgressIndicatorView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 4)
                    .foregroundColor(Color(.systemGray5))

                Rectangle()
                    .frame(width: geometry.size.width * progress, height: 4)
                    .foregroundColor(.accentColor)
                    .animation(.linear, value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - ViewModel

@MainActor
final class PracticeTestViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: [UUID: String] = [:]
    @Published var showingSubmitAlert = false
    @Published var showingResults = false

    let testType: TestType
    let questions: [Question]
    private(set) var results: TestResults?

    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var canProceed: Bool {
        guard let selected = selectedAnswers[questions[currentQuestionIndex].id] else {
            return false
        }
        return !selected.isEmpty
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }

    init(testType: TestType) {
        self.testType = testType
        self.questions = Self.generateQuestions(for: testType)
    }

    func selectAnswer(_ answer: String, for questionId: UUID) {
        selectedAnswers[questionId] = answer
    }

    func handleNext() {
        guard canProceed else { return }

        if isLastQuestion {
            showingSubmitAlert = true
        } else {
            currentQuestionIndex += 1
        }
    }

    func submitTest() {
        let score = calculateScore()
        results = TestResults(score: score, total: questions.count, testType: testType)
        showingResults = true
    }

    func resetTest() {
        currentQuestionIndex = 0
        selectedAnswers.removeAll()
        results = nil
    }

    private func calculateScore() -> Int {
        questions.reduce(0) { score, question in
            guard let selected = selectedAnswers[question.id],
                  selected == question.correctAnswer else {
                return score
            }
            return score + 1
        }
    }

    private static func generateQuestions(for testType: TestType) -> [Question] {
        // In a real app, this would come from a service or data store
        switch testType {
        case .signs:
            return [
                Question(text: "What does this traffic sign indicate?",
                        options: ["Stop", "Yield", "No entry", "Speed limit"],
                        correctAnswer: "Yield"),
                Question(text: "This blue sign with a white arrow pointing right means:",
                        options: ["Right turn only", "Keep right", "No right turn", "Roundabout ahead"],
                        correctAnswer: "Keep right")
            ]
        case .rules:
            return [
                Question(text: "At a red traffic light, you should:",
                        options: ["Stop completely", "Slow down and proceed carefully", "Stop only if other cars are present", "Speed up to pass before it changes"],
                        correctAnswer: "Stop completely"),
                Question(text: "When parking downhill, you should turn your wheels:",
                        options: ["Toward the curb", "Away from the curb", "Straight ahead", "It doesn't matter"],
                        correctAnswer: "Toward the curb")
            ]
        }
    }
}

// MARK: - Models

struct TestResults {
    let score: Int
    let total: Int
    let testType: TestType
}

enum TestType {
    case signs, rules

    var title: String {
        switch self {
        case .signs: return "Traffic Signs"
        case .rules: return "Rules of the Road"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PracticeTestView(testType: .signs)
    }
}