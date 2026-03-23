import Foundation

protocol FocusTimerServiceProtocol {
    func saveFocusSession(duration: TimeInterval, completedAt: Date, isCompleted: Bool)
    func getFocusHistory() -> [FocusSession]
}