@MainActor
final class ExamReadinessViewModel: ObservableObject {
    
    enum State {
        case idle
        case loading
        case success(ExamReadinessResult)
        case failure(ReadinessError)
    }
    
    @Published var state: State = .idle
    @Published var selectedWeakCategoryID: UUID?
    
    // Computed convenience properties
    var readinessResult: ExamReadinessResult? {
        guard case .success(let result) = state else { return nil }
        return result
    }
    
    var isLoading: Bool {
        guard case .loading = state else { return false }
        return true
    }
    
    var error: ReadinessError? {
        guard case .failure(let error) = state else { return nil }
        return error
    }
    
    // Clear actions
    func loadReadiness(forceRefresh: Bool = false) async {
        state = .loading
        do {
            let result = try await analysisService.calculateReadiness(forceRefresh: forceRefresh)
            state = .success(result)
        } catch {
            state = .failure(ReadinessError(from: error))
        }
    }
    
    func reset() {
        state = .idle
        selectedWeakCategoryID = nil
    }
}

// Use in view
switch viewModel.state {
case .idle, .loading:
    ProgressView()
case .success(let result):
    ReadinessScoreView(result: result)
case .failure(let error):
    ErrorBanner(error: error)
}