import SwiftUI

// ✅ CORRECT: Domain state in ViewModel

struct QuizQuestion {
    let text: String
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id: UUID
    let text: String
}

@MainActor
class QuizViewModelMain: ObservableObject {
    @Published var currentQuestion: QuizQuestion = QuizQuestion(text: "", options: [])
    @Published var selectedAnswer: UUID? = nil

    func submitAnswer() async {
        // Submit answer logic here
    }
}

// View uses ViewModel
struct QuestionView: View {
    @StateObject var viewModel: QuizViewModelMain
    
    var body: some View {
        VStack {
            Text(viewModel.currentQuestion.text)
            ForEach(viewModel.currentQuestion.options, id: \.id) { option in
                Button(option.text) {
                    viewModel.selectedAnswer = option.id
                    Task { await viewModel.submitAnswer() }
                }
            }
        }
    }
}