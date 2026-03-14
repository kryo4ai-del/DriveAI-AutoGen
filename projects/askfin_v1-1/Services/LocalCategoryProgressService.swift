class LocalCategoryProgressService: CategoryProgressServiceProtocol {
    func fetchAllProgress() async throws -> [CategoryProgress] {
        // Read from SQLite/JSON
        // For now: synchronous wrapper around existing data layer
        return try await Task { 
            // your data fetch logic
        }.value
    }
}