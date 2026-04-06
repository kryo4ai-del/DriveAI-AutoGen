class SpacedRepetitionService {
    private let progressService: ProgressService
    
    func getWeakAreas() -> [Question] {
        let incorrect = progressService.incorrectAnswers
        return incorrect.filter { answer in
            let lastSeen = answer.timestamp
            let daysSince = Calendar.current.dateComponents([.day], from: lastSeen, to: Date()).day ?? 0
            
            // Schedule: 1-day, 3-day, 7-day intervals
            return (daysSince >= 1 && !answer.reviewedAt1Day) ||
                   (daysSince >= 3 && !answer.reviewedAt3Day) ||
                   (daysSince >= 7)
        }
    }
}