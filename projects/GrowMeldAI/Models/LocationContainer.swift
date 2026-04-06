import SwiftUI
final class LocationContainer: Sendable {
    let repository: LocationRepository
    let locationPickerViewModel: LocationPickerViewModel
    let examContextViewModel: ExamContextViewModel
    
    private let databasePath: String
    
    init() throws {
        // Set up database path in app's Documents directory
        let docURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        databasePath = docURL.appendingPathComponent("regions.db").path
        
        // Initialize database and service
        let database = try RegionDatabase(path: databasePath)
        let dataService = LocalRegionDataService(database: database)
        
        // Load bundled data if first launch
        if !UserDefaults.standard.bool(forKey: "locationsInitialized") {
            try await LocationDataLoader.loadBundledRegions(into: database)
            UserDefaults.standard.set(true, forKey: "locationsInitialized")
        }
        
        try await dataService.initializeDatabase()
        
        // Assemble repository and ViewModels
        self.repository = LocationRepository(dataService: dataService)
        self.locationPickerViewModel = LocationPickerViewModel(repository: repository)
        self.examContextViewModel = ExamContextViewModel()
    }
}