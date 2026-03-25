import Foundation

@MainActor
final class MeditationSessionService: MeditationSessionServiceProtocol {

    private let storageKey = "meditation_sessions_v1"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // In-memory cache. Invalidated on every save.
    private var cachedSessions: [MeditationSession]?

    // MARK: - Load

    func loadSessions() -> [MeditationSession] {
        if let cached = cachedSessions { return cached }
        let sessions: [MeditationSession]
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? decoder.decode([MeditationSession].self, from: data) {
            sessions = decoded.sorted { $0.date > $1.date }
        } else {
            sessions = []
        }
        cachedSessions = sessions
        return sessions
    }

    // MARK: - Save

    func save(session: MeditationSession) {
        var all = loadSessions()
        guard !all.contains(where: { $0.id == session.id }) else { return }
        all.append(session)
        cachedSessions = nil
        do {
            let data = try encoder.encode(all)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            #if DEBUG
            print("[MeditationSessionService] Save failed: \(error)")
            #endif
        }
    }

    // MARK: - Computed Stats

    var completedSessionCount: Int {
        loadSessions().filter(\.wasCompleted).count
    }

    var currentStreak: Int {
        let calendar = Calendar.current

        // completedDays is sorted descending. The streak loop relies on this
        // ordering — do not change to unordered iteration.
        let completedDays = Set(
            loadSessions()
                .filter(\.wasCompleted)
                .map { calendar.startOfDay(for: $0.date) }
        ).sorted(by: >)

        guard let mostRecent = completedDays.first else { return 0 }

        let today = calendar.startOfDay(for: .now)
        guard
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
            mostRecent >= yesterday
        else { return 0 }

        var streak = 0
        var checkDate = mostRecent

        for day in completedDays {
            if day == checkDate {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                    break
                }
                checkDate = previousDay
            } else {
                break
            }
        }
        return streak
    }
}