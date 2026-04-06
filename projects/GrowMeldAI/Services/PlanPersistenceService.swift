// Services/PlanPersistenceService.swift
import Foundation

final class PlanPersistenceService {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private lazy var planURL: URL = {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("learning_plan.json")
    }()
    
    private lazy var performanceURL: URL = {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("question_performance.json")
    }()
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Plan Operations
    
    func savePlan(_ plan: DriverExamPlan) throws {
        let data = try encoder.encode(plan)
        try data.write(to: planURL, options: .atomic)
    }
    
    func loadPlan() -> DriverExamPlan? {
        guard fileManager.fileExists(atPath: planURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: planURL)
            return try decoder.decode(DriverExamPlan.self, from: data)
        } catch {
            print("❌ Failed to load plan: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearPlan() throws {
        if fileManager.fileExists(atPath: planURL.path) {
            try fileManager.removeItem(at: planURL)
        }
    }
    
    // MARK: - Performance History
    
    func loadPerformanceHistory() -> [QuestionPerformance] {
        guard fileManager.fileExists(atPath: performanceURL.path) else { return [] }
        
        do {
            let data = try Data(contentsOf: performanceURL)
            return try decoder.decode([QuestionPerformance].self, from: data)
        } catch {
            print("❌ Failed to load performance history: \(error.localizedDescription)")
            return []
        }
    }
    
    func updateQuestionPerformance(
        questionId: String,
        category: String,
        passed: Bool
    ) throws {
        var history = loadPerformanceHistory()
        
        if let index = history.firstIndex(where: { $0.questionId == questionId }) {
            let current = history[index]
            let newAttempts = current.attemptCount + 1
            let newFailures = current.failureCount + (passed ? 0 : 1)
            let newStrength = calculateRetrievalStrength(
                attempts: newAttempts,
                failures: newFailures
            )
            
            history[index] = QuestionPerformance(
                questionId: questionId,
                category: category,
                attemptCount: newAttempts,
                failureCount: newFailures,
                retrievalStrength: newStrength,
                lastReviewDate: Date()
            )
        } else {
            history.append(QuestionPerformance(
                questionId: questionId,
                category: category,
                attemptCount: 1,
                failureCount: passed ? 0 : 1,
                retrievalStrength: passed ? 0.8 : 0.2,
                lastReviewDate: Date()
            ))
        }
        
        let data = try encoder.encode(history)
        try data.write(to: performanceURL, options: .atomic)
    }
    
    // MARK: - Private Helpers
    
    private func calculateRetrievalStrength(attempts: Int, failures: Int) -> Double {
        let successRate = Double(attempts - failures) / Double(attempts)
        // Smooth transition from new (0.5) to mastered (1.0)
        return 0.5 + (successRate * 0.5)
    }
}