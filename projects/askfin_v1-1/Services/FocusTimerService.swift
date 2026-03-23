import Foundation

final class FocusTimerService: FocusTimerServiceProtocol {

    private let userDefaults: UserDefaults
    private let storageKey = "focus_timer_sessions"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveFocusSession(duration: TimeInterval, completedAt: Date, isCompleted: Bool) {
        let session = FocusSession(
            id: UUID(),
            duration: duration,
            completedAt: completedAt,
            isCompleted: isCompleted
        )

        var sessions = getFocusHistory()
        sessions.append(session)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("[FocusTimerService] Failed to save session: \(error.localizedDescription)")
        }
    }

    func getFocusHistory() -> [FocusSession] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let sessions = try decoder.decode([FocusSession].self, from: data)
            return sessions
        } catch {
            print("[FocusTimerService] Failed to decode sessions: \(error.localizedDescription)")
            return []
        }
    }
}