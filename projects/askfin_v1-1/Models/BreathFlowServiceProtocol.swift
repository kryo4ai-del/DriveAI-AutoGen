import Foundation

protocol BreathFlowServiceProtocol: Actor {
    func saveSession(_ session: BreathSession) throws
    func fetchRecentSessions(limit: Int) -> [BreathSession]
    func fetchLastSession() -> BreathSession?
    func averagePreAnxiety(lastN n: Int) -> Double?
    func streakCount() -> Int
}
