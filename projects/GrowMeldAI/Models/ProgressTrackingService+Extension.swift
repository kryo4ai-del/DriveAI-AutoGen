extension ProgressTrackingService {
    var progressUpdatedPublisher: AnyPublisher<Void, Never> {
        progressUpdatedSubject.eraseToAnyPublisher()
    }
    
    private let progressUpdatedSubject = PassthroughSubject<Void, Never>()
    
    func recordAnswer(questionId: Int, isCorrect: Bool) {
        // ... existing logic ...
        progressUpdatedSubject.send()
    }
}