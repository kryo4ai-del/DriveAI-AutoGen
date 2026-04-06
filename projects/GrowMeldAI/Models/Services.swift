// Simple, explicit DI for SwiftUI (no complex factory)
@MainActor
struct Services {
    let dataService: LocalDataService
    let persistenceStore: PersistenceStore
    let progressTracking: ProgressTrackingService
    
    static func create() async throws -> Services {
        let dataService = LocalDataService()
        try await dataService.loadQuestionsFromBundle()
        
        let progressTracking = ProgressTrackingService(dataService: dataService)
        
        return Services(
            dataService: dataService,
            persistenceStore: .shared,
            progressTracking: progressTracking
        )
    }
}

// In App:
@main

// Access in ViewModels: