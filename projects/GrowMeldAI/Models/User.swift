import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String?
    var examDate: Date?
    var createdAt: Date
    var lastActiveDate: Date
    
    init(
        id: UUID = UUID(),
        name: String? = nil,
        examDate: Date? = nil,
        createdAt: Date = Date(),
        lastActiveDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.examDate = examDate
        self.createdAt = createdAt
        self.lastActiveDate = lastActiveDate
    }
    
    var daysUntilExam: Int? {
        guard let examDate = examDate else { return nil }
        let components = Calendar.current.dateComponents([.day], from: Date(), to: examDate)
        return max(components.day ?? 0, 0)
    }
}