// ✅ CORRECT: Async/await in ViewModel
class QuizViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    
    func loadQuestions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let questions = try await quizService.fetchQuestions(mode: .practice)
            DispatchQueue.main.async {
                self.questions = questions
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
            }
        }
    }
    
    // Call from view
    .onAppear {
        Task {
            await loadQuestions()  // ← Structured task, auto-cancels on view dismiss
        }
    }
}