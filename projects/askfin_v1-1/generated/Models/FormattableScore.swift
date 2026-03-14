// Shared protocol for formatted display
protocol FormattableScore {
    var correctPercentage: Int { get }
    var formattedScore: String { get }
}

extension FormattableScore {
    var formattedScore: String { "\(correctPercentage)%" }
}

// Apply to CategoryMetric, WeakCategory, etc.
struct WeakCategory: FormattableScore, Codable, Equatable, Identifiable {
    let correctPercentage: Int
    // formattedScore now inherited
}