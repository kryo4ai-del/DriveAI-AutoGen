import Foundation

public struct ExamResultAnalysis: Sendable {
    public let categoryPerformance: [CategoryScore]
    public let weakestCategory: QuestionCategory?
    public let strongestCategory: QuestionCategory?

    public struct CategoryScore: Sendable {
        public let category: QuestionCategory
        public let score: Int
        public let total: Int
        public var accuracy: Double { total > 0 ? Double(score) / Double(total) : 0 }
    }
}
