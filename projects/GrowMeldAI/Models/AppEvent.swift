import Foundation

enum AppEvent: Hashable {
    case quizCompleted(categoryId: String, score: Int)
}