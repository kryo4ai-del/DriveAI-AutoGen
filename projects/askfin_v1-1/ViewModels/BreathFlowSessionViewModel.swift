// ViewModels/BreathFlow/BreathFlowSessionViewModel.swift

import Foundation
import Combine

/// Drives the animated breathing exercise screen.
@MainActor
final class BreathFlowSessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentPhaseIndex: Int = 0
    @Published private(set) var currentCycle: Int = 1
    @Published private(set) var phaseProgress: Double = 0.0    // 0.0 → 1.0
    @Published private(set) var sessionProgress: Double = 0.0  // 0.0 → 1.0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isComplete: Bool = false

    // MARK: - Public Accessors

    var currentPhase: BreathPhase {
        session.pattern.phases[currentPhaseIndex]
    }

    var totalCycles: Int {
        session.pattern.recommendedCycles
    }

    var patternName: String {
        session.pattern.name
    }

    var phaseInstruction: String {
        currentPhase.instruction
    }

    var phaseLabel: String {
        currentPhase.label
    }

    var cycleLabel: String {
        "Runde \(currentCycle) von \(totalCycles)"
    }

    // MARK: - Private

    private(set) var session: BreathSession
    private var timer: AnyCancellable?
    private var elapsedInPhase: TimeInterval = 0
    private let tickInterval: TimeInterval = 0.05

    private let service: BreathFlowService
    private let haptics = BreathHapticEngine()

    private var totalSessionTicks: Double {
        let totalDuration = session.pattern.estimatedDuration
        return totalDuration / tickInterval
    }

    private var ticksElapsed: Double = 0

    // MARK: - Init

    init(session: BreathSession, service: BreathFlowService = .shared) {
        self.session = session
        self.service = service
    }

    // MARK: - Control

    func start() {
        guard !isRunning else { return }
        isRunning = true
        haptics.phaseStart()
        startTick()
    }

    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    func resume() {
        guard !isComplete, !isRunning else { return }
        isRunning = true
        startTick()
    }

    func skipToCompletion() {
        timer?.cancel()
        timer = nil
        finish()
    }

    // MARK: - Timer Engine

    private func startTick() {
        timer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        let phaseDuration = currentPhase.duration

        elapsedInPhase += tickInterval
        ticksElapsed += 1

        // Phase progress (0 → 1 within current phase)
        phaseProgress = min(elapsedInPhase / phaseDuration, 1.0)

        // Overall session progress
        sessionProgress = min(ticksElapsed / totalSessionTicks, 1.0)

        // Advance phase if complete
        if elapsedInPhase >= phaseDuration {
            advancePhase()
        }
    }

    private func advancePhase() {
        let phases = session.pattern.phases
        elapsedInPhase = 0
        phaseProgress = 0

        let nextPhaseIndex = currentPhaseIndex + 1

        if nextPhaseIndex < phases.count {
            // Move to next phase in same cycle
            currentPhaseIndex = nextPhaseIndex
            haptics.phaseStart()
        } else {
            // Cycle complete
            let nextCycle = currentCycle + 1
            if nextCycle <= totalCycles {
                currentPhaseIndex = 0
                currentCycle = nextCycle
                haptics.cycleComplete()
            } else {
                // All cycles done
                finish()
            }
        }
    }

    private func finish() {
        timer?.cancel()
        timer = nil
        isRunning = false
        isComplete = true
        phaseProgress = 1.0
        sessionProgress = 1.0
        haptics.sessionComplete()

        // Record completion timestamp
        session.completedAt = .now
        service.save(session: session)
    }
}