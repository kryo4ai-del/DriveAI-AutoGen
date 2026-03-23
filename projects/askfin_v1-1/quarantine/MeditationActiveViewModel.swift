import Foundation
import Combine

@MainActor
final class MeditationActiveViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var breathState: BreathState = .initial
    @Published private(set) var sessionProgress: Double = 0.0
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isFinished: Bool = false

    // MARK: - Derived

    var remainingLabel: String {
        let remaining = max(targetSeconds - elapsedSeconds, 0)
        return String(format: "%d:%02d", remaining / 60, remaining % 60)
    }

    // MARK: - Private State

    private let targetSeconds: Int
    private let service: MeditationSessionServiceProtocol

    private var sessionTimer: AnyCancellable?
    private var phaseTimer: AnyCancellable?

    /// Wall-clock anchor for the current session segment (resets on resume).
    private var sessionStartDate: Date = .now
    /// Wall-clock anchor for the current phase segment (resets on advance or resume).
    private var phaseStartDate: Date = .now
    /// Elapsed seconds before the most recent pause.
    private var accumulatedSeconds: Int = 0
    /// Elapsed time within the current phase before the most recent pause.
    private var pausedPhaseElapsed: TimeInterval = 0

    private var hasStarted = false
    private var isFinalized = false
    private var completedSession: MeditationSession?

    // MARK: - Init

    init(
        duration: MeditationDuration,
        service: MeditationSessionServiceProtocol = MeditationSessionService()
    ) {
        self.targetSeconds = duration.seconds
        self.service = service
    }

    // MARK: - Lifecycle

    func start() {
        guard !hasStarted, !isFinalized else { return }
        hasStarted = true
        sessionStartDate = .now
        phaseStartDate = .now
        startTimers()
    }

    func togglePause() {
        guard !isFinalized else { return }
        isPaused.toggle()
        if isPaused {
            accumulatedSeconds = elapsedSeconds
            pausedPhaseElapsed = Date.now.timeIntervalSince(phaseStartDate)
            cancelTimers()
        } else {
            sessionStartDate = .now
            // Shift phaseStartDate back so the resumed phase continues
            // from where it was when paused, with no visual snap.
            phaseStartDate = Date.now.addingTimeInterval(-pausedPhaseElapsed)
            startTimers()
        }
    }

    func stop() {
        guard !isFinalized else { return }
        finalizeSession(completed: false)
    }

    // MARK: - Factory

    /// Returns a CompletionViewModel for the finished session,
    /// sharing this service instance. Returns nil before the session ends.
    func makeCompletionViewModel() -> MeditationCompletionViewModel? {
        guard let session = completedSession else { return nil }
        return MeditationCompletionViewModel(session: session, service: service)
    }

    // MARK: - Private — Timers

    private func startTimers() {
        startSessionTimer()
        startPhaseTimer()
    }

    private func cancelTimers() {
        sessionTimer?.cancel()
        sessionTimer = nil
        phaseTimer?.cancel()
        phaseTimer = nil
    }

    private func startSessionTimer() {
        sessionTimer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, !self.isFinalized else { return }
                let liveSeconds = Int(Date.now.timeIntervalSince(self.sessionStartDate))
                self.elapsedSeconds = self.accumulatedSeconds + liveSeconds
                self.sessionProgress = min(
                    Double(self.elapsedSeconds) / Double(self.targetSeconds),
                    1.0
                )
                if self.elapsedSeconds >= self.targetSeconds {
                    self.finalizeSession(completed: true)
                }
            }
    }

    private func startPhaseTimer() {
        let tick: TimeInterval = 0.05
        phaseTimer = Timer
            .publish(every: tick, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, !self.isFinalized else { return }
                let elapsed = Date.now.timeIntervalSince(self.phaseStartDate)
                // Advance phase first, then update progress.
                // This ensures breathState is always written once per tick
                // and the transition tick writes (newPhase, 0) atomically.
                if elapsed >= self.breathState.phase.duration {
                    self.advancePhase()
                } else {
                    self.breathState = BreathState(
                        phase: self.breathState.phase,
                        progress: elapsed / self.breathState.phase.duration
                    )
                }
            }
    }

    private func advancePhase() {
        phaseStartDate = .now
        breathState = BreathState(phase: breathState.phase.next, progress: 0)
    }

    private func finalizeSession(completed: Bool) {
        guard !isFinalized else { return }
        isFinalized = true
        cancelTimers()

        let session = MeditationSession(
            durationSeconds: min(elapsedSeconds, targetSeconds),
            targetDurationSeconds: targetSeconds,
            wasCompleted: completed
        )
        service.save(session: session)
        completedSession = session
        isFinished = true
    }
}