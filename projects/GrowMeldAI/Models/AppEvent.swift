enum AppEvent: Hashable {
    case quizCompleted(categoryId: String, score: Int, ...)
    // ❌ Associated values make Codable encoding complex
    // ❌ Current implementation doesn't handle Codable protocol
}