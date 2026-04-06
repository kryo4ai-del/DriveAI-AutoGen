@MainActor
final class QuizSessionManager: ObservableObject {
    @Published var session: QuizSession
    
    init(categoryId: String? = nil) {
        self.session = QuizSession(categoryId: categoryId)
    }
    
    func recordAnswer(_ answer: QuestionAnswer) {
        session.answers.append(answer)
    }
    
    func resetSession() {
        session = QuizSession(categoryId: session.categoryId)
    }
}