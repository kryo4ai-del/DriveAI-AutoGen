import Foundation

/// Represents a completed or partial meditation session stored locally.
struct MeditationSession: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let durationSeconds: Int
    let targetDurationSeconds: Int
    let wasCompleted: Bool

    init(
        id: UUID = UUID(),
        date: Date = .now,
        durationSeconds: Int,
        targetDurationSeconds: Int,
        wasCompleted: Bool
    ) {
        self.id = id
        self.date = date
        self.durationSeconds = durationSeconds
        self.targetDurationSeconds = targetDurationSeconds
        self.wasCompleted = wasCompleted
    }
}