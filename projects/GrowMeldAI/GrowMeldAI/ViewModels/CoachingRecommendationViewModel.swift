@MainActor
final class CoachingRecommendationViewModel: ObservableObject {
    private let useCase: GenerateCoachingRecommendationsUseCase
    
    func loadRecommendations(user: User) async {
        do {
            let recs = try await useCase.execute(user: user)
            self.recommendations = recs  // Safe: await handles context
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}