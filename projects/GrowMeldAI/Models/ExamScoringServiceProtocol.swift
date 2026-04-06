// Services/Domain/ExamScoringService.swift (Complete)
import Foundation

protocol ExamScoringServiceProtocol {
    func calculateScore(session: ExamSession) throws -> ExamResult
    func isPassing(score: Int, totalQuestions: Int) -> Bool
}
