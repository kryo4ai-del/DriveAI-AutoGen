final class MemoryCaptureService {
    private var answersSinceLastCapture = 0
    private let captureRatio = 0.1  // Capture ~10%
    
    private func shouldCapture(_ event: QuestionAnsweredEvent) -> Bool {
        // Only capture meaningful moments
        let isMeaningful = event.isCorrect && (
            event.userStreak % 3 == 0 ||  // Every 3-question streak
            event.userStreak == 1          // First of new streak
        )
        
        return isMeaningful && Double.random(in: 0...1) < captureRatio
    }
}