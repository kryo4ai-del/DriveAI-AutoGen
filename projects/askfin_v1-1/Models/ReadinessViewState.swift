import Foundation

@MainActor
enum ReadinessViewState: Sendable {
    case idle
    case loading
    case loaded(ReadinessMetrics)
    case detail(CategoryReadiness)
    case error(ReadinessError)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var metrics: ReadinessMetrics? {
        if case .loaded(let metrics) = self {
            return metrics
        }
        return nil
    }
}
