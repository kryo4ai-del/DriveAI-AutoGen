// Shared protocol in core domain
protocol QuestionsServiceProtocol {
    func fetchQuestions(forSignID: String) async throws -> [Question]
    func addToLearningQueue(_ questions: [Question])
}

// Usage in CameraPreviewViewModel
func addRecognizedSignToQueue() async {
    guard let sign = recognizedSign else { return }
    
    do {
        let relatedQuestions = try await questionsService
            .fetchQuestions(forSignID: sign.signID)
        questionsService.addToLearningQueue(relatedQuestions)
        
        // Navigate to question list
        // (parent coordinator handles navigation)
    } catch {
        errorMessage = "Could not load questions."
    }
}