// Features/ExerciseSelection/Resources/ExerciseData.swift
import Foundation

// MARK: - Protocol
protocol ExerciseDataProvider: Sendable {
    func fetchExercises() async throws -> [BreathingExercise]
}

// MARK: - Default Implementation
@MainActor

// MARK: - Sample Exercises
extension BreathingExercise {
    static let boxBreathing = BreathingExercise(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        name: "Box Breathing",
        description: "Equal-length inhale, hold, exhale cycle. Military & first responder favorite.",
        category: .calm,
        duration: 240,
        cycles: 4,
        emotionalOutcomes: [
            EmotionalOutcome(id: UUID(), label: "Reduce Anxiety", icon: "heart.fill", relevance: 0.95),
            EmotionalOutcome(id: UUID(), label: "Mental Clarity", icon: "brain.head.profile", relevance: 0.80)
        ],
        microcopy: "For immediate calm",
        difficulty: .beginner,
        breathPattern: BreathPattern(inhale: 4, hold: 4, exhale: 4)
    )
    
    static let fourSevenEight = BreathingExercise(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
        name: "4-7-8 Breathing",
        description: "Extended exhale promotes relaxation & sleep.",
        category: .sleep,
        duration: 360,
        cycles: 3,
        emotionalOutcomes: [
            EmotionalOutcome(id: UUID(), label: "Better Sleep", icon: "moon.stars.fill", relevance: 0.92),
            EmotionalOutcome(id: UUID(), label: "Deep Relaxation", icon: "wind", relevance: 0.88)
        ],
        microcopy: "For deep sleep",
        difficulty: .intermediate,
        breathPattern: BreathPattern(inhale: 4, hold: 7, exhale: 8)
    )
    
    // Add 3+ more...
}