import SwiftUI
import Combine

@MainActor
final class BreathFlowViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var phase: BreathPhase = .idle
    @Published private(set) var progress: Double = 0       // 0.0–1.0 within current phase
    @Published private(set) var circleScale: Double = 0.5  // drives the breath circle animation
    @Published private(set) var currentCycle: Int = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isComplete: Bool = false

    // MARK: - Configuration

    let pattern: BreathPattern

    // MARK: - Private

    /// Stored as a Set so AnyCancellable auto-cancels on deallocation.
    /// No manual deinit required.
    private var cancellables = Set<AnyCancellable>()

    private var phaseStartTime: Date = .now
    private var phaseDuration: Double = 0
    private let tickInterval: Double = 0.05

    // MARK: - Init

    init(pattern: BreathPattern = .boxBreathing) {
        self.pattern = pattern
    }

    // MARK: - Public Control

    func start() {
        guard !isRunning, !isComplete else { return }
        isRunning = true
        currentCycle = 1
        beginPhase(.inhale)
    }

    /// Stops the session without triggering the completion screen.
    /// Navigation is the caller's responsibility via the onSkip callback.
    func skip() {
        reset()
    }

    func reset() {
        stopTimer()
        phase = .idle
        progress = 0
        circleScale = 0.5
        currentCycle = 0
        isRunning = false
        isComplete = false
    }

    // MARK: - Phase Management

    private func beginPhase(_ newPhase: BreathPhase) {
        phase = newPhase
        phaseStartTime = .now
        phaseDuration = duration(for: newPhase)
        progress = 0
        circleScale = targetScale(for: newPhase)
        startTimer()
    }

    private func startTimer() {
        stopTimer()
        Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
            .store(in: &cancellables)
    }

    private func stopTimer() {
        cancellables.removeAll()
    }

    private func tick() {
        let elapsed = Date.now.timeIntervalSince(phaseStartTime)
        progress = min(elapsed / max(phaseDuration, tickInterval), 1.0)

        if progress >= 1.0 {
            advancePhase()
        }
    }

    private func advancePhase() {
        stopTimer()

        switch phase {
        case .inhale:
            // Guard: skip hold phase when holdSeconds is 0 to avoid a
            // zero-duration phase that would set phaseDuration to 0,
            // causing progress to compute as elapsed/0 = inf.
            beginPhase(pattern.holdSeconds > 0 ? .hold : .exhale)

        case .hold:
            beginPhase(.exhale)

        case .exhale:
            if currentCycle < pattern.totalCycles {
                currentCycle += 1
                beginPhase(.inhale)
            } else {
                finishSession()
            }

        case .idle, .complete:
            break
        }
    }

    private func finishSession() {
        stopTimer()
        isRunning = false
        // State change only — animation is driven by the View responding to isComplete.
        phase = .complete
        circleScale = 1.0
        isComplete = true
    }

    // MARK: - Duration Helpers

    /// Returns the duration for a phase, clamped to zero to prevent
    /// negative values from misconfigured BreathPattern instances.
    private func duration(for phase: BreathPhase) -> Double {
        let raw: Double
        switch phase {
        case .inhale:  raw = pattern.inhaleSeconds
        case .hold:    raw = pattern.holdSeconds
        case .exhale:  raw = pattern.exhaleSeconds
        default:       raw = 0
        }
        return max(raw, 0)
    }

    private func targetScale(for phase: BreathPhase) -> Double {
        switch phase {
        case .inhale, .hold: return 1.0
        default:             return 0.5
        }
    }

    // MARK: - Display Helpers
    //
    // These are computed properties, not @Published. They update correctly
    // because they depend on `progress`, which is @Published and ticks at
    // 50ms intervals. A future developer should not add @Published here —
    // the values are derived, not stored state.

    var cycleLabel: String {
        guard isRunning else { return "" }
        return "Runde \(currentCycle) von \(pattern.totalCycles)"
    }

    /// Derived from `progress` rather than `Date.now` to stay in sync
    /// with the published tick cycle and avoid independent time reads.
    var phaseTimerLabel: String {
        let remaining = max(0, phaseDuration * (1.0 - progress))
        return String(format: "%.0f", ceil(remaining))
    }

    var totalProgressFraction: Double {
        guard pattern.cycleDuration > 0, pattern.totalCycles > 0 else { return 0 }

        switch phase {
        case .idle:     return 0
        case .complete: return 1.0
        default:        break
        }

        let phaseOffset: Double
        switch phase {
        case .inhale:  phaseOffset = 0
        case .hold:    phaseOffset = pattern.inhaleSeconds
        case .exhale:  phaseOffset = pattern.inhaleSeconds + pattern.holdSeconds
        default:       phaseOffset = 0
        }

        let completedCycleSeconds = Double(currentCycle - 1) * pattern.cycleDuration
        let currentPhaseElapsed = phaseDuration * progress
        let totalElapsed = completedCycleSeconds + phaseOffset + currentPhaseElapsed
        let totalSeconds = Double(pattern.totalCycles) * pattern.cycleDuration

        return min(totalElapsed / totalSeconds, 1.0)
    }
}