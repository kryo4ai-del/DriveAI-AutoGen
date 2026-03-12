import Foundation

struct WeaknessCategory: Identifiable {
    let id = UUID()
    let categoryName: String
    let incorrectCount: Int
    let totalAttempts: Int

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(totalAttempts - incorrectCount) / Double(totalAttempts)
    }

    var accuracyPercentage: Int { Int(accuracy * 100) }
}
