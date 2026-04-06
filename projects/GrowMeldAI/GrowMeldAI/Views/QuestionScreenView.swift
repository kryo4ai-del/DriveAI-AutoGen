// Base ViewModel protocol
protocol BaseViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func send(_ action: Action)
    func cancel()  // Cleanup hook
}

// Concrete implementation

// Usage in View
struct QuestionScreenView: View {
    @StateObject private var viewModel: QuestionViewModel
    
    init(repository: QuestionRepository) {
        _viewModel = StateObject(wrappedValue: QuestionViewModel(repository: repository))
    }
    
    var body: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
                .onAppear { viewModel.send(.load(1)) }
        case .loading:
            ProgressView()
        case .loaded(let question):
            QuestionContent(question: question)
        case .error(let error):
            ErrorView(error: error)
        }
    }
}