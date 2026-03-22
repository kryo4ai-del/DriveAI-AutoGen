@Observable @MainActor
final class BreathingViewModel: Sendable {
    private var cancellables = Set<AnyCancellable>()
    
    private func startTimer() {
        cancellables.removeAll()
        
        Timer.publish(every: timerInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }
            .store(in: &cancellables)
    }
    
    private func tick() {
        phaseElapsedTime += Float(timerInterval)
        timeRemaining = max(0, totalPhaseTime - Int(phaseElapsedTime))
        updateProgress()
        
        if timeRemaining == 0 {
            transitionPhase()
        }
    }
}