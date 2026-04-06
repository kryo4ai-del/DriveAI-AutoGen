struct CategoriesStatsContainer: Codable {
    let stats: [String: CategoryStats]
    
    enum CodingKeys: String, CodingKey {
        case stats = "statistics"
    }
}

// Use this in ProgressTracker instead of direct [String: CategoryStats]