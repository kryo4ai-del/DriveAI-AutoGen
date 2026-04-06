// Services/ExamSimulatorService.swift
import SwiftUI
import Combine

@MainActor
final class ExamSimulatorService: ObservableObject {
    @Published var timeRemaining: Int = 1800 // 30 minutes
    @Published var isPaused = false
    @Published var examComplete = false

    private var timerTask: Task<Void, Never>?
    private var startTime: Date?
    private var warningTime: Int = 300 // 5 minutes warning

    private let dataService: LocalDataService
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .warning)

    init(dataService: LocalDataService) {
        self.dataService = dataService
    }

    deinit {
        timerTask?.cancel()
    }

    func startExam() {
        guard timerTask == nil else { return }

        startTime = Date()
        examComplete = false
        timeRemaining = 1800
        isPaused = false

        timerTask = Task { [weak self] in
            while !(Task.isCancelled) {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

                guard let self = self, !self.isPaused else { continue }

                self.timeRemaining -= 1

                if self.timeRemaining <= self.warningTime {
                    self.hapticGenerator.impactOccurred()
                }

                if self.timeRemaining <= 0 {
                    self.examComplete = true
                    self.timerTask?.cancel()
                    self.timerTask = nil
                    break
                }
            }
        }
    }

    func pauseExam() {
        isPaused = true
        timerTask?.cancel()
        timerTask = nil
    }

    func resumeExam() {
        guard isPaused else { return }
        startExam()
    }

    func exitExam() {
        timerTask?.cancel()
        timerTask = nil
        examComplete = false
        timeRemaining = 1800
        isPaused = false
    }

    func resetExam() {
        exitExam()
    }
}