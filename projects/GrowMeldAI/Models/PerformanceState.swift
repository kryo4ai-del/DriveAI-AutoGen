// ViewModels/State/PerformanceState.swift
@Observable
final class PerformanceState {
    @ObservationIgnored private let manager: PerformanceManager
    
    var categoryProgress: [CategoryProgress] = []
    var userStreak: UserStreak?
    var overallAccuracy: Double = 0
    var isLoading: Bool = false
    var error: PerformanceError?
    
    init(manager: PerformanceManager) {
        self.manager = manager
    }
    
    func recordQuestionResult(_ result: QuestionResult) async {
        // Updates self properties
    }
}