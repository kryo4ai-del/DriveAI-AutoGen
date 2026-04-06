import Foundation

enum UserConfidence: Int, CaseIterable {
    case veryUnsure = 1
    case unsure = 2
    case neutral = 3
    case confident = 4
    case veryConfident = 5

    var sm2Quality: Float {
        switch self {
        case .veryUnsure: return 1.0
        case .unsure: return 2.0
        case .neutral: return 3.0
        case .confident: return 4.0
        case .veryConfident: return 5.0
        }
    }

    static func calculateNextReview(
        userConfidence: UserConfidence,
        currentInterval: Int = 0,
        currentEaseFactor: Float = 2.5
    ) -> (interval: Int, easeFactor: Float) {
        let quality = userConfidence.sm2Quality

        var newEaseFactor = currentEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
        newEaseFactor = max(1.3, newEaseFactor)

        let nextInterval: Int
        if quality < 3 {
            nextInterval = 1
        } else if currentInterval == 0 {
            nextInterval = 1
        } else if currentInterval == 1 {
            nextInterval = 3
        } else {
            nextInterval = Int(Float(currentInterval) * newEaseFactor)
        }

        return (interval: nextInterval, easeFactor: newEaseFactor)
    }
}