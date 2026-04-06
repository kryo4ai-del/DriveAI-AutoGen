actor LocationDataLoader {
    enum LoadError: LocalizedError {
        case fileNotFound
        case invalidJSON(String)
        case decodingFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "regions.json not found in bundle"
            case .invalidJSON(let msg):
                return "Invalid JSON: \(msg)"
            case .decodingFailed(let msg):
                return "Decoding failed: \(msg)"
            }
        }
    }
    
    static func loadBundledRegions(
        into database: RegionDatabase,
        fallbackRegions: [PostalCodeRegion]? = nil
    ) async throws {
        guard let url = Bundle.main.url(forResource: "regions", withExtension: "json") else {
            // Use fallback if provided
            if let fallback = fallbackRegions {
                for region in fallback {
                    try await database.insert(region)
                }
                return
            }
            throw LoadError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let regions = try JSONDecoder().decode([PostalCodeRegion].self, from: data)
            
            // Insert regions in batches to avoid lock contention
            let batchSize = 50
            for batch in regions.chunked(into: batchSize) {
                for region in batch {
                    try await database.insert(region)
                }
            }
        } catch let decodingError as DecodingError {
            throw LoadError.decodingFailed(decodingError.localizedDescription)
        } catch {
            throw LoadError.invalidJSON(error.localizedDescription)
        }
    }
}

// Helper for chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}