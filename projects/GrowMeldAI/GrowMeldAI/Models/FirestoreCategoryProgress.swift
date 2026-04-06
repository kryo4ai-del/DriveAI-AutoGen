// Models/DTO/FirestoreCategoryProgress.swift
struct FirestoreCategoryProgress: Codable {
    @DocumentID var id: String?
    var categoryId: String
    var attempted: Int = 0
    var correct: Int = 0
    var updatedAt: Timestamp = Timestamp()
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case attempted
        case correct
        case updatedAt = "updated_at"
    }
}