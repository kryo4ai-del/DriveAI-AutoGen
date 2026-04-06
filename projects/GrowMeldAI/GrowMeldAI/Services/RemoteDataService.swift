// When ready to add backend (POST-MVP)
final class RemoteDataService: LocalDataServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func saveUserAnswer(questionId: UUID, selectedIndex: Int) async {
        let request = SaveAnswerRequest(questionId: questionId, selectedIndex: selectedIndex)
        try? await apiClient.post("/answers", body: request)
        // Also save locally for offline resilience
    }
}