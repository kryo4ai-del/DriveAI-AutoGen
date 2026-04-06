// In ExamResultLogging.swift:
class ExamResultLogging {
    static let shared = ExamResultLogging()
    
    private let abTestService = ABTestingService.shared
    
    func logExamResult(
        score: Int,
        totalQuestions: Int,
        questionsAnswered: [(questionID: String, passed: Bool)]
    ) {
        // 1. Log to A/B tests (existing)
        for (questionID, passed) in questionsAnswered {
            let testID = mapQuestionToTest(questionID)
            let variant = abTestService.assignVariant(testID: testID)
            
            let result = TestResult(
                testID: testID,
                variantID: variant?.id ?? "unknown",
                userIDHash: UserSegmentationService.shared.getUserIDHash(),
                outcome: passed ? "pass" : "fail",
                timestamp: Date()
            )
            
            try? abTestService.logResult(
                testID: testID,
                variantID: variant?.id ?? "unknown",
                outcome: passed ? "pass" : "fail"
            )
        }
        
        // 2. POST-FIX: Announce to VoiceOver
        announceParticipationToAccessibility()
    }
    
    /// Announce A/B test participation to screen readers.
    private func announceParticipationToAccessibility() {
        let announcement = NSLocalizedString(
            "abtesting.result_logged",
            value: "Your exam result helps us improve DriveAI. Thank you for participating in our testing program.",
            comment: "VoiceOver announcement when exam results are logged for A/B testing"
        )
        
        UIAccessibility.post(
            notification: .announcement,
            argument: announcement
        )
    }
}