import Foundation

/// Immutable record of a completed or stopped BreathFlow session.
struct BreathSession: Identifiable {
    let id: UUID
    let date: Date
    let pattern: BreathPattern
    let cyclesCompleted: Int
    let durationSeconds: Double
    let anxietyBefore: AnxietyLevel?
    let anxietyAfter: AnxietyLevel?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        pattern: BreathPattern,
        cyclesCompleted: Int,
        durationSeconds: Double,
        anxietyBefore: AnxietyLevel?,
        anxietyAfter: AnxietyLevel?
    ) {
        self.id = id
        self.date = date
        self.pattern = pattern
        self.cyclesCompleted = cyclesCompleted
        self.durationSeconds = durationSeconds
        self.anxietyBefore = anxietyBefore
        self.anxietyAfter = anxietyAfter
    }

    /// Positive value means the user reported feeling calmer after the session.
    /// `nil` if either measurement is missing.
    var calmingDelta: Int? {
        guard let before = anxietyBefore, let after = anxietyAfter else { return nil }
        return before.rawValue - after.rawValue
    }
}