import Foundation

@MainActor
protocol MeditationSessionServiceProtocol: AnyObject {
    /// Returns all saved sessions, sorted newest first.
    func loadSessions() -> [MeditationSession]

    /// Persists a session. Silently ignores duplicate IDs.
    func save(session: MeditationSession)

    /// Total number of fully completed sessions.
    var completedSessionCount: Int { get }

    /// Consecutive calendar days with at least one completed session.
    /// Counts from today or yesterday, so a streak is not broken
    /// on a day where the user has not yet meditated.
    var currentStreak: Int { get }
}