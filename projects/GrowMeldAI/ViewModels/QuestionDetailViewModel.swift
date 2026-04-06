@MainActor
class QuestionDetailViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    func loadQuestions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            questions = try await dataService.fetchQuestions(categoryId: categoryId)
            totalQuestions = questions.count
            if !questions.isEmpty {
                currentQuestion = questions[0]
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}