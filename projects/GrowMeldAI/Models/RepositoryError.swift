enum RepositoryError: LocalizedError {
    case fileNotFound(Region)
    case decodingFailed(String)
    case invalidRegion
    case cacheFailed(String)
    case noQuestionsFound(Region)
    case categoryNotFound(String, Region)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let region):
            return "Question data for \(region.displayName) not found in bundle"
        case .decodingFailed(let fileName):
            return "Failed to parse \(fileName).json - check JSON format"
        case .invalidRegion:
            return "The selected region is not supported"
        case .cacheFailed(let reason):
            return "Cache operation failed: \(reason)"
        case .noQuestionsFound(let region):
            return "No questions loaded for region: \(region.displayName)"
        case .categoryNotFound(let categoryId, let region):
            return "Category '\(categoryId)' not found for region \(region.displayName)"
        }
    }
}