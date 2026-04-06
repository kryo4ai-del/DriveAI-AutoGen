// ViewModels/Performance/PerformanceStateManager.swift

import Foundation

// MARK: - PerformanceAction
enum PerformanceAction: Equatable {
    case recordQuestionAttempt(QuestionAttempt)
    case recordExamAttempt(ExamAttempt)
    case loadMetrics
    case loadMetricsSuccess(PerformanceMetrics, StreakData)
    case setError(PerformanceError)
    case clearError
    case resetProgress
    
    static func == (lhs: PerformanceAction, rhs: PerformanceAction) -> Bool {
        switch (lhs, rhs) {
        case (.recordQuestionAttempt(let a), .recordQuestionAttempt(let b)):
            return a.id == b.id
        case (.recordExamAttempt(let a), .recordExamAttempt(let b)):
            return a.id == b.id
        case (.loadMetrics, .loadMetrics):
            return true
        case (.setError(let a), .setError(let b)):
            return a == b
        case (.clearError, .clearError):
            return true
        case (.resetProgress, .resetProgress):
            return true
        case (.loadMetricsSuccess(let m1, let s1), .loadMetricsSuccess(let m2, let s2)):
            return m1 == m2 && s1 == s2
        default:
            return false
        }
    }
}

// MARK: - Pure Reducer
func performanceReducer(state: inout PerformanceState, action: PerformanceAction) {
    switch action {
    case .recordQuestionAttempt(let attempt):
        state.recentAttempts.insert(attempt, at: 0)
        if state.recentAttempts.count > PerformanceConfig.shared.maxRecentAttempts {
            state.recentAttempts.removeLast()
        }
        state.error = nil
        
    case .recordExamAttempt(let exam):
        state.recentExams.insert(exam, at: 0)
        if state.recentExams.count > PerformanceConfig.shared.maxRecentExams {
            state.recentExams.removeLast()
        }
        state.error = nil
        
    case .loadMetrics:
        state.isLoading = true
        state.error = nil
        
    case .loadMetricsSuccess(let metrics, let streak):
        state.metrics = metrics
        state.streak = streak
        state.isLoading = false
        state.error = nil
        
    case .setError(let error):
        state.error = error
        state.isLoading = false
        
    case .clearError:
        state.error = nil
        
    case .resetProgress:
        state = PerformanceState()
    }
}

// MARK: - PerformanceStateManager
@MainActor