@MainActor
final class QuestionVM: ObservableObject {
    @Published var errorMessage: String?
    @Published var isRetrying = false
    
    func loadNextQuestion() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let next = quizSession.nextQuestion() {
                currentQuestion = try await dataService.fetchQuestion(next.id)
            }
        } catch let error as LocalizedError {
            errorMessage = error.errorDescription ?? "Ein Fehler ist aufgetreten"
            // Retry available
        } catch {
            errorMessage = "Unbekannter Fehler"
        }
        
        isLoading = false
    }
    
    func retryLoadingQuestion() async {
        isRetrying = true
        await loadNextQuestion()
        isRetrying = false
    }
}