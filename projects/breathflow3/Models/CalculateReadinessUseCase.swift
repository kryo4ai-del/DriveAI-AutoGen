// ❌ BROKEN - Hard-coded, scattered, not configurable
final class CalculateReadinessUseCase: Sendable {
    private let masteryThreshold: Double = 85.0
    private let almostReadyThreshold: Double = 70.0
    private let targetSessions: Int = 5
    private let minimumSessionsForReady: Int = 3
    private let minimumSessionsForAlmostReady: Int = 2
}