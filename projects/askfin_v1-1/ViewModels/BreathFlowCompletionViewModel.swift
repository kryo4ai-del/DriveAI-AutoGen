// ViewModels/BreathFlow/BreathFlowCompletionViewModel.swift

import Foundation

/// Manages the post-session completion screen.
/// Closes the anxiety feedback loop by capturing post-session state
/// and presenting the calming delta to the user.
@MainActor
final class BreathFlowCompletionViewModel: ObservableObject {

    // MARK: - Published State

    @Published var selectedAfterAnxiety: AnxietyLevel

    // MARK: - Private

    private var session: BreathSession
    private let service: BreathFlowService
    private let isFromExam: Bool

    // MARK: - Init

    init(
        session: BreathSession,
        isFromExam: Bool = false,
        service: BreathFlowService = .shared
    ) {
        self.session = session
        self.isFromExam = isFromExam
        self.service = service
        // Pre-select same level — user sees the change clearly
        self._selectedAfterAnxiety = Published(
            initialValue: session.anxietyBefore
        )
    }

    // MARK: - Computed Properties

    var patternName: String {
        session.pattern.name
    }

    var anxietyBefore: AnxietyLevel {
        session.anxietyBefore
    }

    /// Calming delta based on current after-selection (live, before confirm).
    var liveCalmingDelta: Int {
        selectedAfterAnxiety.rawValue - session.anxietyBefore.rawValue
    }

    var deltaLabel: String {
        switch liveCalmingDelta {
        case ..<(-1): return "Deutlich ruhiger 🎉"
        case -1:      return "Etwas ruhiger 😌"
        case 0:       return "Gleich geblieben"
        case 1:       return "Etwas angespannter"
        default:      return "Deutlich angespannter"
        }
    }

    var deltaIsPositive: Bool {
        liveCalmingDelta < 0
    }

    var sessionDurationLabel: String {
        guard let duration = session.duration else { return "" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes) Min \(seconds) Sek"
        }
        return "\(seconds) Sekunden"
    }

    var ctaLabel: String {
        isFromExam ? "Zur Prüfung" : "Fertig"
    }

    var examContextMessage: String? {
        guard isFromExam else { return nil }
        return "Du hast dich gut vorbereitet. Deine Prüfungssimulation wartet."
    }

    // MARK: - Actions

    /// Saves the after-anxiety rating and finalises the session record.
    func confirmAfterAnxiety() {
        session.anxietyAfter = selectedAfterAnxiety
        service.save(session: session)
    }
}