// ✅ Domain is pure, DI at presentation boundary
class QuizResultViewModel {
    let diagnosticService: DiagnosticService    // Pure domain
    let repository: DiagnosticRepository        // Data access
    let analytics: AnalyticsService             // Side effects
    
    func analyzeQuizResult(_ result: QuizResult) async {
        let diagnosis = diagnosticService.analyze(result)  // Pure
        try? await repository.save(diagnosis)              // Side effect
        analytics.log(.quizCompleted)                      // Side effect
    }
}