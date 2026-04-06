import Foundation

struct Question {
    let id: UUID
    let text: String
}

enum AppError: Error {
    case unknown
}

struct PaginatedQuestions {
    let questions: [Question]
    let hasMore: Bool
    let pageSize: Int
}

func loadQuestions(
    categoryId: UUID,
    pageSize: Int = 25,
    offset: Int = 0
) async -> Result<PaginatedQuestions, AppError> {
    // Implementation with LIMIT/OFFSET
    return .success(PaginatedQuestions(questions: [], hasMore: false, pageSize: pageSize))
}

@Observable
class QuizViewModel {
    var paginatedQuestions: PaginatedQuestions?
}