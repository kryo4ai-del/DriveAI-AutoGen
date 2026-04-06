extension ReviewAnalysis {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let rating = try container.decode(Int.self, forKey: .rating)
        // ... decode others
        
        try self.init(
            id: id,
            rating: rating,
            // ... pass others
        )
    }
}