import Foundation
import SwiftUI

// MARK: - Protocol Definition

protocol DiagnoseLearningGapsUseCase {
    func diagnose(userId: String) async throws -> [LearningGap]
}

// MARK: - Supporting Models

struct LearningGap: Identifiable, Codable {
    let id: String
    let topic: String
    let severity: GapSeverity
    let recommendedActions: [String]

    enum GapSeverity: String, Codable {
        case low, medium, high
    }
}

// MARK: - Repository Protocol

protocol QuestionRepository {
    func fetchQuestions(for userId: String) async throws -> [Question]
}

struct Question: Identifiable, Codable {
    let id: String
    let topic: String
    let wasAnsweredCorrectly: Bool
}

// MARK: - Local Repository Implementation

class LocalQuestionRepository: QuestionRepository {
    private let storageKey = "com.growmeld.local_questions"

    func fetchQuestions(for userId: String) async throws -> [Question] {
        guard let data = UserDefaults.standard.data(forKey: "\(storageKey).\(userId)"),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return []
        }
        return questions
    }

    func saveQuestions(_ questions: [Question], for userId: String) throws {
        let data = try JSONEncoder().encode(questions)
        UserDefaults.standard.set(data, forKey: "\(storageKey).\(userId)")
    }
}

// MARK: - Logger Protocol

protocol DiagnosisLogger {
    func log(_ message: String)
    func error(_ message: String)
}

// MARK: - Default Logger

class DefaultDiagnosisLogger: DiagnosisLogger {
    func log(_ message: String) {
        #if DEBUG
        print("[DiagnoseLearningGaps] ✓ \(message)")
        #endif
    }

    func error(_ message: String) {
        print("[DiagnoseLearningGaps] ✗ ERROR: \(message)")
    }
}

// MARK: - Use Case Implementation

class DiagnoseLearningGapsUseCaseImpl: DiagnoseLearningGapsUseCase {
    private let repository: QuestionRepository
    private let logger: DiagnosisLogger

    init(
        repository: QuestionRepository = LocalQuestionRepository(),
        logger: DiagnosisLogger = DefaultDiagnosisLogger()
    ) {
        self.repository = repository
        self.logger = logger
    }

    func diagnose(userId: String) async throws -> [LearningGap] {
        logger.log("Starting diagnosis for userId: \(userId)")

        let questions = try await repository.fetchQuestions(for: userId)

        guard !questions.isEmpty else {
            logger.log("No questions found for userId: \(userId), returning empty gaps.")
            return []
        }

        let gaps = buildLearningGaps(from: questions)
        logger.log("Diagnosed \(gaps.count) learning gap(s) for userId: \(userId)")
        return gaps
    }

    private func buildLearningGaps(from questions: [Question]) -> [LearningGap] {
        // Group questions by topic
        let grouped = Dictionary(grouping: questions, by: { $0.topic })

        return grouped.compactMap { topic, topicQuestions in
            let total = topicQuestions.count
            let incorrect = topicQuestions.filter { !$0.wasAnsweredCorrectly }.count

            guard incorrect > 0 else { return nil }

            let errorRate = Double(incorrect) / Double(total)
            let severity: LearningGap.GapSeverity
            switch errorRate {
            case 0..<0.33:
                severity = .low
            case 0.33..<0.66:
                severity = .medium
            default:
                severity = .high
            }

            return LearningGap(
                id: UUID().uuidString,
                topic: topic,
                severity: severity,
                recommendedActions: recommendedActions(for: severity, topic: topic)
            )
        }
    }

    private func recommendedActions(for severity: LearningGap.GapSeverity, topic: String) -> [String] {
        switch severity {
        case .low:
            return ["Review \(topic) summary", "Complete one practice exercise"]
        case .medium:
            return ["Re-study \(topic) fundamentals", "Complete three practice exercises", "Watch explainer video"]
        case .high:
            return ["Start \(topic) from the beginning", "Complete full module", "Schedule a coaching session", "Take diagnostic quiz"]
        }
    }
}

// MARK: - ViewModel

@MainActor
class LearningGapsViewModel: ObservableObject {
    @Published var gaps: [LearningGap] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let diagnosisUseCase: DiagnoseLearningGapsUseCase
    private let userId: String

    init(diagnosisUseCase: DiagnoseLearningGapsUseCase, userId: String) {
        self.diagnosisUseCase = diagnosisUseCase
        self.userId = userId
    }

    func loadGaps() async {
        isLoading = true
        errorMessage = nil
        do {
            gaps = try await diagnosisUseCase.diagnose(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}