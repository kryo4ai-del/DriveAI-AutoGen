// Add to AppDelegate or main App struct
class ServiceContainer {
    static let shared = ServiceContainer()
    
    let localDataService = LocalDataService()
    let categoryPerformanceService = CategoryPerformanceService(
        localDataService: localDataService
    )
    
    lazy var examReadinessService = ExamReadinessService(
        categoryPerformanceService: categoryPerformanceService,
        localDataService: localDataService
    )
}

// In ExamReadinessView initializer:
.onAppear {
    let container = ServiceContainer.shared
    let vm = ExamReadinessViewModel(
        examReadinessService: container.examReadinessService,
        navigationService: NavigationService.shared
    )
    // ...
}