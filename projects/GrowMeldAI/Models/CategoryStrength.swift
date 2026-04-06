import Foundation

struct CategoryStrength: Identifiable {
    let id = UUID()
    let categoryName: String
    let accuracy: Double
    let questionCount: Int
    var accessibilityLabel: String { categoryName }
    var accessibilityHint: String { "\(questionCount) questions" }
}
