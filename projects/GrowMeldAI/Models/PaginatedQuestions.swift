import Foundation

struct PaginatedQuestions {
    let questions: [Question]
    let hasMore: Bool
    let pageSize: Int
}