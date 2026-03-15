import Foundation

/// Preview and test double for ReadinessService
final class MockReadinessService: ReadinessServiceProtocol {

    var snapshotToReturn: ExamReadinessSnapshot = .preview
    var shouldThrow: Bool = false

    func fetchLatestSnapshot() async throws -> ExamReadinessSnapshot {
        if shouldThrow { throw MockError.intentional }
        try await Task.sleep(for: .milliseconds(600)) // simulate latency
        return snapshotToReturn
    }

    func computeScore(
        from categories: [CategoryReadiness],
        streak: Int,
        daysUntilExam: Int?
    ) -> ReadinessScore {
        ReadinessScore(value: 0.72, computedAt: .now, trend: .improving)
    }

    func generateRecommendations(
        snapshot: ExamReadinessSnapshot
    ) -> [ReadinessRecommendation] {
        snapshot.topRecommendations
    }

    enum MockError: Error { case intentional }
}

// MARK: - Preview Fixtures

extension ExamReadinessSnapshot {
    static var preview: ExamReadinessSnapshot {
        let categories: [CategoryReadiness] = [
            CategoryReadiness(
                id: UUID(), categoryID: "traffic-signs",
                categoryName: "Verkehrszeichen",
                questionsTotal: 80, questionsAttempted: 60, correctAnswers: 48,
                lastAttempted: .now
            ),
            CategoryReadiness(
                id: UUID(), categoryID: "right-of-way",
                categoryName: "Vorfahrt",
                questionsTotal: 40, questionsAttempted: 15, correctAnswers: 8,
                lastAttempted: Calendar.current.date(byAdding: .day, value: -2, to: .now)
            ),
            CategoryRead

The implementation is **well-structured and largely production-ready**. Architecture decisions are sound, naming is consistent, and the MVVM separation is clean. Below are concrete issues and improvements organized by severity.

`ExamReadinessSnapshot` conforms to `Equatable` but not `Codable`, yet it contains `Codable` models. If this snapshot is ever cached or persisted (likely), this will silently fail at the call site.

**Fix:** Add `Codable` explicitly, or document intentional omission.