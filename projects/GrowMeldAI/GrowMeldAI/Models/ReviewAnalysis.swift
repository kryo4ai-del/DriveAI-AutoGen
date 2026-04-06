// ✅ INVARIANT VALIDATION

struct ReviewAnalysis: Codable, Hashable {
    let id: String
    let rating: Int
    let title: String
    let body: String
    let sentiment: Sentiment
    // ... other fields
    
    init(
        id: String,
        rating: Int,
        title: String,
        body: String,
        sentiment: Sentiment,
        // ... others
    ) throws {
        guard (1...5).contains(rating) else {
            throw ValidationError.invalidRating(rating)
        }
        guard !title.isEmpty, !body.isEmpty else {
            throw ValidationError.emptyContent
        }
        
        self.id = id
        self.rating = rating
        self.title = title
        self.body = body
        self.sentiment = sentiment
        // ... assign others
    }
    
    enum ValidationError: LocalizedError {
        case invalidRating(Int)
        case emptyContent
        
        var errorDescription: String? {
            switch self {
            case .invalidRating(let r):
                return "Bewertung \(r) ungültig (erwartet 1–5)"
            case .emptyContent:
                return "Titel oder Text darf nicht leer sein"
            }
        }
    }
}
