enum UserConfidence: Int, CaseIterable {
    case veryUnsure = 1    // "Ich weiß das nicht"
    case unsure = 2        // "Ich bin mir nicht sicher"
    case neutral = 3       // "Geht so"
    case confident = 4     // "Ich bin mir sicher"
    case veryConfident = 5 // "Ich weiß das genau"
    
    /// Map user confidence (1-5) to SM-2 quality (0-5)
    /// 1-2 (unsure) → 1 (failed/difficult)
    /// 3 (neutral) → 3 (difficult)
    /// 4-5 (confident) → 4-5 (easy/perfect)
    var sm2Quality: Float {
        switch self {
        case .veryUnsure: return 1.0   // Failed/difficult
        case .unsure: return 2.0       // Very difficult
        case .neutral: return 3.0      // Difficult
        case .confident: return 4.0    // Easy
        case .veryConfident: return 5.0 // Perfect
        }
    }
}

struct SM2Calculator {
    static func calculateNextReview(
        userConfidence: UserConfidence,
        currentInterval: Int = 0,
        currentEaseFactor: Float = 2.5
    ) -> (interval: Int, easeFactor: Float) {
        let quality = userConfidence.sm2Quality
        
        // Proper SM-2 thresholds
        var newEaseFactor = currentEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
        newEaseFactor = max(1.3, newEaseFactor)
        
        let nextInterval: Int
        if quality < 3 {
            // Failed: aggressive restart
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

// ✅ Test now catches SM-2 violations
func test_sm2_failureRestarts() {
    let (interval, _) = SM2Calculator.calculateNextReview(
        userConfidence: .veryUnsure,  // User doesn't know it
        currentInterval: 30,           // Has been 30 days
        currentEaseFactor: 2.8
    )
    assert(interval == 1)  // Must restart to 1 day
}