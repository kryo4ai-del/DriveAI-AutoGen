import Foundation
import Combine
@MainActor
final class BreathFlowSessionViewModel: ObservableObject {

    // MARK: - Published State
    @Published private(set) var state: SessionState = .idle
    @Published private(set) var currentPhase: BreathPhase = .inhale
    @Published private(set) var phaseProgress: Double = 0.0     // 0.0–1.0
    @Published private(set) var cycleProgress: Double = 0.0     // 0.0–1.0
    @Published private(set) var completedCycles: Int = 0
    @Published private(set) var countdownValue: Int = 3
    @Published private(set) var phaseLabel: String = ""
    @Published private(set) var sessionDuration: TimeInterval = 0

    // MARK: - Configuration
    let pattern: BreathPattern
    let totalCycles: Int

    // MARK: - Initializer
    init(pattern: BreathPattern, totalCycles: Int) {
        self.pattern = pattern
        self.totalCycles = totalCycles
    }

    // MARK: - Session Lifecycle
    func startSession() {
        // TODO: implement
    }

    func pauseSession() {
        // TODO: implement
    }

    func resumeSession() {
        // TODO: implement
    }

    func skipToEnd() {
        // TODO: implement
    }

    func endEarly() -> BreathSession {
        // TODO: implement
        fatalError("Not yet implemented")
    }

    // MARK: - Internal
    // Timer using Swift Concurrency (Task + clock)
    // Phase index advances through pattern.phases repeatedly
    // phaseProgress drives animation interpolation
}