import Foundation

struct FocusSession: Codable, Identifiable {
    let id: UUID
    let duration: TimeInterval
    let completedAt: Date
    let isCompleted: Bool

    init(id: UUID = UUID(), duration: TimeInterval, completedAt: Date, isCompleted: Bool) {
        self.id = id
        self.duration = duration
        self.completedAt = completedAt
        self.isCompleted = isCompleted
    }
}