import Foundation

struct QuestionDomain: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let description: String?
    let iconName: String?
    let sortOrder: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        iconName: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.sortOrder = sortOrder
    }
}