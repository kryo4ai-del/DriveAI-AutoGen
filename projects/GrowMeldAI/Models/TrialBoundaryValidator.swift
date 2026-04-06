struct TrialBoundaryValidator {
    let coordinator: TrialCoordinator
    
    func canAnswerQuestion(inMode mode: QuestionMode) -> Bool {
        switch mode {
        case .practice:
            return !coordinator.journey.hasExceededQuotaToday
        case .exam:
            return coordinator.journey.purchaseToken != nil
        }
    }
}