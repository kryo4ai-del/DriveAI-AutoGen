import Foundation

struct TrafficSignWeaknessCategory: Identifiable {
    let id = UUID()
    let categoryName: String
    let incorrectCount: Int
    let totalAttempts: Int

    var accuracyRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(totalAttempts - incorrectCount) / Double(totalAttempts)
    }

    var accuracyPercentage: Int { Int(accuracyRate * 100) }
}
