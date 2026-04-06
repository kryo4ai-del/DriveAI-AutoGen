import Foundation

enum LearningPlanState: Equatable {
    case idle
    case loading
    case loaded(LearningPlan)
    case error(LearningPlanError)
    case empty

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var hasError: Bool {
        if case .error = self { return true }
        return false
    }
}