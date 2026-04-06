struct MemoryMetadata: Codable {
    let detail: String
    let emoji: String
    let categoryName: String?
    let streakDays: Int?
    let score: Int?
    let timeContext: String?  // e.g., "3 weeks before exam"
    let additionalInfo: [String: String]?
}