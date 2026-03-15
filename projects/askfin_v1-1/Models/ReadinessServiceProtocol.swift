import Foundation

protocol ReadinessServiceProtocol: AnyObject {
    func fetchLatestSnapshot() async throws -> ExamReadinessSnapshot
    func generateRecommendations(
        snapshot: ExamReadinessSnapshot
    ) -> [ReadinessRecommendation]
}