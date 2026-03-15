// streakBonus scales linearly: full bonus (0.05) reached at streak == 7 days
// Formula: streak × (maxBonus / daysForFullBonus) = streak × (0.05 / 7)
// Equivalent: streak / (7 / 0.05) = streak / 140
private enum ScoreWeights {
    /// Maximum bonus contribution from daily streak
    static let streakBonusCap: Double = 0.05
    /// Days of consecutive practice to earn full streak bonus
    static let streakFullBonusDays: Double = 7.0
    /// Derived divisor — do not set independently
    static var streakDivisor: Double { streakFullBonusDays / streakBonusCap }
}

let streakBonus = min(Double(streak) / ScoreWeights.streakDivisor, ScoreWeights.streakBonusCap)