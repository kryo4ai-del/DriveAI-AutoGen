import Foundation
struct EmotionalOutcome: Identifiable, Codable, Equatable {
    let id: UUID
    let label: String
    let icon: String
    private(set) var relevance: Double
    
    init(id: UUID, label: String, icon: String, relevance: Double) {
        self.id = id
        self.label = label
        self.icon = icon
        self.relevance = max(0, min(1, relevance))  // Clamp to [0, 1]
    }
    
    // For Codable
    enum CodingKeys: CodingKey {
        case id, label, icon, relevance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.label = try container.decode(String.self, forKey: .label)
        self.icon = try container.decode(String.self, forKey: .icon)
        let raw = try container.decode(Double.self, forKey: .relevance)
        self.relevance = max(0, min(1, raw))
    }
}