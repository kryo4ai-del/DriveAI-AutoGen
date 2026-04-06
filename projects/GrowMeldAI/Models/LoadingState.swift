// ✅ Explicit state machine
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
}

@MainActor

// In View
switch viewModel.state {
case .idle, .loading:
    ProgressView()
case .success(let question):
    QuestionContent(question: question)
case .error(let error):
    ErrorView(error: error, retry: viewModel.reload)
}