final class UserMetricsModel {
    private let queue = DispatchQueue(label: "metrics.queue", attributes: .concurrent)
    
    func recordQuestion(correct: Bool, ...) {
        queue.async(flags: .barrier) {
            self.totalQuestionsAnswered += 1
            // ...
        }
    }
}