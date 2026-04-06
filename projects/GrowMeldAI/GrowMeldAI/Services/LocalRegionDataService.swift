@MainActor
final class LocalRegionDataService: LocationDataServiceProtocol {
    nonisolated private let database: RegionDatabase
    private var initTask: Task<Void, Error>?
    private var isReady = false
    
    init(database: RegionDatabase) {
        self.database = database
    }
    
    // Idempotent initialization with proper synchronization
    func initializeDatabase() async throws {
        // Return immediately if already initialized
        if isReady { return }
        
        // If initialization is in progress, wait for it
        if let existingTask = initTask {
            try await existingTask.value
            return
        }
        
        // Start new initialization
        let task = Task {
            try await LocationDataLoader.loadBundledRegions(into: database)
            self.isReady = true
        }
        
        self.initTask = task
        try await task.value
    }
    
    func getRegion(plz: String) async throws -> PostalCodeRegion {
        guard isReady else {
            throw LocationError.offlineUnavailable
        }
        
        guard let region = try await database.getRegion(plz: plz) else {
            throw LocationError.plzNotFound(plz)
        }
        
        return region
    }
    
    func searchByName(_ query: String) async throws -> [PostalCodeRegion] {
        guard isReady else { throw LocationError.offlineUnavailable }
        return try await database.searchByName(query)
    }
    
    func listByState(_ state: String) async throws -> [PostalCodeRegion] {
        guard isReady else { throw LocationError.offlineUnavailable }
        return try await database.listByState(state)
    }
    
    func getAllStates() async throws -> [String] {
        guard isReady else { throw LocationError.offlineUnavailable }
        return try await database.getAllStates()
    }
    
    func isInitialized() -> Bool {
        isReady
    }
}