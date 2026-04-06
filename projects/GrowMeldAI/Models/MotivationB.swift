import Foundation

struct MotivationB: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let variant: String
    let createdAt: Date

    var isActive: Bool {
        return !message.isEmpty && !title.isEmpty
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        variant: String = "B",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.variant = variant
        self.createdAt = createdAt
    }
}