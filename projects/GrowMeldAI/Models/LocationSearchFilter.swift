import Foundation

/// Parameters for filtering location searches
struct LocationSearchFilter: Equatable {
    let query: String
    let state: String?
    
    var isActive: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty || state != nil
    }
    
    init(query: String = "", state: String? = nil) {
        self.query = query.trimmingCharacters(in: .whitespaces)
        self.state = state
    }
}

/// Result of a location search operation with metadata
struct LocationSearchResult: Equatable {
    let locations: [Location]
    let query: String
    let executionTime: TimeInterval
    let resultCount: Int
    
    var isEmpty: Bool {
        locations.isEmpty
    }
}