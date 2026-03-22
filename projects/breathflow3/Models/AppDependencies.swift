// AppDependencies.swift
class AppDependencies {
    static let shared = AppDependencies()
    
    private let persistenceController = PersistenceController.shared
    lazy var sessionHistoryService = SessionHistoryService(
        container: persistenceController.container
    )
    lazy var exerciseRepository = ExerciseRepository()
}

// In ExerciseSelectionView:
init(statsService: SessionHistoryService = AppDependencies.shared.sessionHistoryService) {
    _viewModel = StateObject(
        wrappedValue: ExerciseSelectionViewModel(statsService: statsService)
    )
}

// Usage:
ExerciseSelectionView() // ✅ Works