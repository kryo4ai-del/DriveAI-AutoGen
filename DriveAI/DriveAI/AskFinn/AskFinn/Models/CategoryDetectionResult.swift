import Foundation

struct CategoryDetectionResult {
    let category: QuestionCategory
    let confidence: Double
    let matchedKeywords: [String]
}
