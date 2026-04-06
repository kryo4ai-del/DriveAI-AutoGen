import Foundation
// Infrastructure/Persistence/CoachingRepository.swift

final class CoachingRepository: CoachingRepositoryProtocol {
    private let localService: LocalDataService
    
    init(localService: LocalDataService) {
        self.localService = localService
    }
    
    func fetchRecommendations(for userId: String) async throws -> [CoachingRecommendation] {
        // Query local database
        // Return decoded recommendations
    }
    
    func dismissRecommendation(id: UUID, userId: String) async throws {
        // Update dismissal timestamp in local DB
    }
}