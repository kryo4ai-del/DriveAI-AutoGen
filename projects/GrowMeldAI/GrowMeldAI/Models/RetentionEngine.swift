import Foundation

/// Spaced Repetition algorithm implementation (SM-2)
struct RetentionEngine {
    /// SM-2 algorithm for calculating next review interval
    /// - quality: 0-5 (5=perfect, 2=incorrect, 0=complete blank)
    func calculateNextInterval(
        currentInterval: Int,
        easeFactor: Double,
        quality: Int
    ) -> Int {
        let quality = min(max(quality, 0), 5)
        
        if quality < 3 {
            // Wrong answer, reset to 1 day
            return 1
        }
        
        // Correct answer
        switch currentInterval {
        case 0, 1:
            return 3
        default:
            return Int(Double(currentInterval) * adjustEaseFactor(quality))
        }
    }
    
    func adjustEaseFactor(_ quality: Int) -> Double {
        // SM-2 ease factor adjustment
        let adjustment = Double(quality - 3) * 0.1
        return max(1.3, 2.5 + adjustment)
    }
}

/// Stub for event logging