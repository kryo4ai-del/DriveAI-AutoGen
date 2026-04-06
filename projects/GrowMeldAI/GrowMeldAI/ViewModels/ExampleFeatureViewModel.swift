// ViewModels/Base/FeatureViewModelTemplate.swift
@MainActor
final class ExampleFeatureViewModel: BaseViewModel<ExampleFeatureState, ExampleFeatureAction> {
    
    private let progressService: ProgressService
    private let dataService: LocalDataService
    
    init(progressService: ProgressService, dataService: LocalDataService) {
        self.progressService = progressService
        self.dataService = dataService
        super.init(initialState: ExampleFeatureState())
    }
    
    override func handle(_ action: ExampleFeatureAction) async {
        switch action {
        case .loadData:
            isLoading = true
            defer { isLoading = false }
            
            do {
                // Fetch from services
                let stats = await progressService.getOverallStats()
                updateState { $0.stats = stats }
            } catch {
                handleError(error)
            }
        }
    }
}

// MARK: - State & Action
struct ExampleFeatureState: Sendable {
    var stats: UserStatistics?
}

enum ExampleFeatureAction: Sendable {
    case loadData
}