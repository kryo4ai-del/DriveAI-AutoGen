import Foundation
struct BreathPattern: Codable, Equatable {
    let inhale: Int
    let hold: Int
    let exhale: Int
    
    init(inhale: Int, hold: Int, exhale: Int) throws {
        guard inhale > 0, exhale > 0 else {
            throw BreathPatternError.invalidTiming
        }
        guard inhale < 60, exhale < 60 else {  // Sanity bounds
            throw BreathPatternError.unrealisticTiming
        }
        self.inhale = inhale
        self.hold = max(0, hold)
        self.exhale = exhale
    }
    
    var cycleLength: Int {
        inhale + hold + exhale
    }
}

enum BreathPatternError: LocalizedError {
    case invalidTiming
    case unrealisticTiming
    
    var errorDescription: String? {
        switch self {
        case .invalidTiming:
            return "Inhale and exhale must be positive"
        case .unrealisticTiming:
            return "Breath timing seems unrealistic (>60s)"
        }
    }
}