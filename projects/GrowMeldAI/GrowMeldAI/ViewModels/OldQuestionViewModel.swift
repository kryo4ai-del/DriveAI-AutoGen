class OldQuestionViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var selectedAnswer: Int?
    // ❌ Manual @Published, NSObject overhead
}