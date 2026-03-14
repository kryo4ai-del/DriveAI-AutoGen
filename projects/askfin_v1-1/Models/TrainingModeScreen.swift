import Foundation

/// Identifies which screen is active in the Training Mode flow.
enum TrainingModeScreenType: Hashable {
    case categorySelection
    case sessionActive(categoryId: String, categoryName: String)
    case sessionResults(sessionId: UUID)
}
