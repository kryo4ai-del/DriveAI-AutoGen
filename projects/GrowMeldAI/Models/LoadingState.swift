import SwiftUI

// ✅ Explicit state machine
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
}

struct Question {
    let text: String
}

struct QuestionContent: View {
    let question: Question
    var body: some View {
        Text(question.text)
    }
}

struct ErrorView: View {
    let error: Error
    let retry: () -> Void
    var body: some View {
        VStack {
            Text(error.localizedDescription)
            Button("Retry", action: retry)
        }
    }
}

@MainActor
class ViewModel: ObservableObject {
    @Published var state: LoadingState<Question> = .idle

    func reload() {
        // reload logic
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .success(let question):
            QuestionContent(question: question)
        case .error(let error):
            ErrorView(error: error, retry: viewModel.reload)
        }
    }
}