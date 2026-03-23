import Foundation
import Combine

final class FocusTimerViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var isCompleted: Bool = false

    // MARK: - Private Properties

    private let defaultDuration: TimeInterval = 25 * 60
    private var totalDuration: TimeInterval
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let service: FocusTimerServiceProtocol

    // MARK: - Computed Properties

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / totalDuration)
    }

    var elapsedTime: TimeInterval {
        return totalDuration - timeRemaining
    }

    // MARK: - Init

    init(service: FocusTimerServiceProtocol = FocusTimerService()) {
        self.service = service
        self.totalDuration = 25 * 60
        self.timeRemaining = 25 * 60
    }

    // MARK: - Public Methods

    func start() {
        guard !isRunning else { return }

        isRunning = true
        isPaused = false
        isCompleted = false

        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tick()
            }
    }

    func pause() {
        guard isRunning else { return }

        isRunning = false
        isPaused = true
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func reset() {
        isRunning = false
        isPaused = false
        isCompleted = false
        timerCancellable?.cancel()
        timerCancellable = nil
        timeRemaining = totalDuration
    }

    func setDuration(minutes: Int) {
        guard !isRunning else { return }
        let duration = TimeInterval(minutes * 60)
        totalDuration = duration
        timeRemaining = duration
        isCompleted = false
        isPaused = false
    }

    func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Methods

    private func tick() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        timeRemaining -= 1
    }

    private func completeSession() {
        isRunning = false
        isPaused = false
        isCompleted = true
        timerCancellable?.cancel()
        timerCancellable = nil
        timeRemaining = 0

        service.saveFocusSession(
            duration: totalDuration,
            completedAt: Date(),
            isCompleted: true
        )
    }
}