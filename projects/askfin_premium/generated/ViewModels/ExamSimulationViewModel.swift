// ExamSimulationViewModel.swift
//
// Bug fixes from review:
// - readiness computed BEFORE save so delta is attached to persisted result
// - finalisationTask stored for cancellation on navigation away
// - cancelIfNeeded() exposed for View .onDisappear
// - @MainActor serialises timer expiry + manual submission race

import SwiftUI
import Combine

@MainActor
final class ExamSimulationViewModel: ObservableObject {

    // MARK: - Phase

    enum Phase: Equatable {
        case preStart
        case inProgress
        case submitted(SimulationResult)

        static func == (lhs: Phase, rhs: Phase) -> Bool {
            switch (lhs, rhs) {
            case (.preStart, .preStart),
                 (.inProgress, .inProgress):
                return true
            case (.submitted(let a), .submitted(let b)):
                return a.id == b.id
            default:
                return false
            }
        }
    }

    // MARK: - Published

    @Published private(set) var phase: Phase = .preStart
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var remainingTime: TimeInterval = 0
    @Published private(set) var currentReadiness: ReadinessScore?
    @Published private(set) var lastResult: SimulationResult?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let config: SimulationConfig
    private let simulationService: ExamSimulationServiceProtocol
    private let readinessService: ReadinessScoreServiceProtocol

    // MARK: - Internal State

    private var simulation: ExamSimulation?
    private var timerCancellable: AnyCancellable?
    private var finalisationTask: Task<Void, Never>?
    private var warningFired = false

    // MARK: - Haptics

    private let heavyFeedback   = UIImpactFeedbackGenerator(style: .heavy)
    private let lightFeedback   = UIImpactFeedbackGenerator(style: .light)
    private let warningFeedback = UINotificationFeedbackGenerator()

    // MARK: - Init

    init(
        config: SimulationConfig = .officialExam,
        simulationService: ExamSimulationServiceProtocol,
        readinessService: ReadinessScoreServiceProtocol
    ) {
        self.config = config
        self.simulationService = simulationService
        self.readinessService = readinessService
    }

    // MARK: - Pre-Start

    func loadPreStartData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let readiness = readinessService.loadLatest()
            async let history   = simulationService.loadRecentHistory(limit: 1)
            let (score, recent) = try await (readiness, history)
            currentReadiness = score
            lastResult = recent.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Start

    func startSimulation() {
        do {
            let questions = try simulationService.generateQuestions(for: config)
            simulation = ExamSimulation(config: config, questions: questions)
            remainingTime = config.timeLimit
            currentQuestionIndex = 0
            warningFired = false
            phase = .inProgress
            startTimer()
            heavyFeedback.impactOccurred()
            UIAccessibility.post(
                notification: .announcement,
                argument: "Generalprobe gestartet. \(config.questionCount) Fragen, " +
                    "\(Int(config.timeLimit / 60)) Minuten."
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Question Progression

    var currentQuestion: ExamQuestion? {
        guard let simulation,
              currentQuestionIndex < simulation.questions.count
        else { return nil }
        return simulation.questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        simulation?.questions.count ?? config.questionCount
    }

    var progressFraction: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(totalQuestions)
    }

    func recordAnswer(index: Int) {
        guard var sim = simulation,
              let question = currentQuestion
        else { return }

        do {
            try sim.record(answerIndex: index, for: question)
            simulation = sim
            lightFeedback.impactOccurred()
            advanceQuestion()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func advanceQuestion() {
        guard let simulation else { return }
        if currentQuestionIndex < simulation.questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            submitSimulation()
        }
    }

    // MARK: - Submission

    func submitSimulation() {
        guard var sim = simulation, !sim.isComplete else { return }
        do {
            try sim.complete()
            simulation = sim
            beginFinalisation(simulation: sim)
        } catch ExamSimulationError.simulationAlreadyComplete {
            // @MainActor serialises timer expiry + manual submit.
            // The second call is always a no-op.
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Cancellation

    /// Call from View .onDisappear to prevent stale task completion.
    func cancelIfNeeded() {
        finalisationTask?.cancel()
        timerCancellable?.cancel()
    }

    // MARK: - Timer

    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        guard remainingTime > 0 else {
            timerCancellable?.cancel()
            submitSimulation()
            return
        }
        remainingTime -= 1
        if !warningFired, remainingTime <= 5 * 60 {
            warningFired = true
            warningFeedback.notificationOccurred(.warning)
            UIAccessibility.post(
                notification: .announcement,
                argument: "Noch 5 Minuten verbleibend."
            )
        }
    }

    // MARK: - Finalisation
    //
    // Order matters:
    // 1. Compute new readiness score (reads history BEFORE new result is saved)
    // 2. Attach delta to result
    // 3. Save result with delta attached
    // 4. Transition to .submitted
    //
    // Phase stays .inProgress while isLoading == true.
    // ExamSimulationView renders a submission-pending indicator in that state.

    private func beginFinalisation(simulation: ExamSimulation) {
        timerCancellable?.cancel()
        heavyFeedback.impactOccurred()

        finalisationTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            defer { isLoading = false }

            do {
                let previousScore = currentReadiness?.score

                // Step 1: evaluate raw result (no delta yet)
                var result = try await simulationService.evaluate(
                    simulation,
                    previousScore: previousScore
                )

                // Step 2: compute readiness from history BEFORE saving new result
                let newReadiness = try await readinessService.compute()
                let delta = previousScore.map { newReadiness.score - $0 }

                // Step 3: rebuild result with delta + final score attached
                result = SimulationResult.build(
                    simulationID: result.simulationID,
                    completedAt: result.completedAt,
                    totalFehlerpunkte: result.totalFehlerpunkte,
                    fehlerpunkteByTopic: result.fehlerpunkteByTopic,
                    vorfahrtErrorCount: result.vorfahrtErrorCount,
                    timeTaken: result.timeTaken,
                    enforceInstantFail: config.mode == .realistic,
                    readinessScoreAtTime: newReadiness.score,
                    readinessDelta: delta,
                    questionResults: result.questionResults
                )

                // Step 4: save the complete result
                try await simulationService.save(result)

                guard !Task.isCancelled else { return }

                currentReadiness = newReadiness
                phase = .submitted(result)

                UIAccessibility.post(
                    notification: .screenChanged,
                    argument: result.passed
                        ? "Bestanden"
                        : "Noch nicht bestanden. \(result.failureReason?.displayMessage ?? "")"
                )
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Formatted Display

    var formattedRemainingTime: String {
        let m = Int(remainingTime) / 60
        let s = Int(remainingTime) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var accessibilityTimerLabel: String {
        let m = Int(remainingTime) / 60
        let s = Int(remainingTime) % 60
        if s == 0 {
            return "\(m) Minuten verbleibend"
        }
        return "\(m) Minuten \(s) Sekunden verbleibend"
    }
}