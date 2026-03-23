import Foundation

@MainActor
final class MeditationCompletionViewModel: ObservableObject {

    // MARK: - State
    let wasCompleted: Bool
    let durationSeconds: Int
    let newStreak: Int
    let totalSessions: Int

    // MARK: - Display

    var headlineText: String {
        wasCompleted ? "Gut gemacht! 🌿" : "Sitzung beendet"
    }

    var messageText: String {
        wasCompleted ? streakMessage : "Auch eine kurze Pause hilft. Versuche es erneut, wenn du bereit bist."
    }

    var durationLabel: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        switch (m, s) {
        case (0, _):        return "\(s) Sekunden"
        case (_, 0):        return "\(m) Minuten"
        default:            return "\(m) min \(s) s"
        }
    }

    var streakAccessibilityLabel: String {
        "\(newStreak) Tage in Folge meditiert"
    }

    // MARK: - Private

    private var streakMessage: String {
        switch newStreak {
        case 1:
            return "Deine erste Meditation – ein guter Start in die Prüfungsvorbereitung."
        case 2...4:
            return "\(newStreak) Tage in Folge. Du baust eine starke Gewohnheit auf."
        case 5...9:
            return "\(newStreak) Tage! Regelmäßige Ruhe schärft deine Konzentration."
        default:
            return "\(newStreak) Tage Streak 🔥 – du bist bestens für die Prüfung vorbereitet."
        }
    }

    // MARK: - Init

    init(
        session: MeditationSession,
        service: MeditationSessionServiceProtocol = MeditationSessionService()
    ) {
        self.wasCompleted = session.wasCompleted
        self.durationSeconds = session.durationSeconds
        self.newStreak = service.currentStreak
        self.totalSessions = service.completedSessionCount
    }
}