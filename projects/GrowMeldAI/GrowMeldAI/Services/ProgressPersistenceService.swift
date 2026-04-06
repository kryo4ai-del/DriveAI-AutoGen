// Services/Persistence/ProgressPersistenceService.swift
import Foundation
import os.log

protocol ProgressPersistenceService: AnyObject {
    func saveExamDate(_ date: Date) async throws
    func fetchProgress() async throws -> UserProgress
    func recordAnswer(questionId: String, categoryId: String, isCorrect: Bool) async throws
    func resetProgress() throws
    func getWeakAreas() async throws -> [String] // categoryIds with <70% score
}

final class ProgressPersistenceServiceImpl: ProgressPersistenceService {
    private let dataService: LocalDataService
    private let logger = Logger(subsystem: "com.driveai", category: "Progress")
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
    }
    
    func saveExamDate(_ date: Date) async throws {
        var progress = try await fetchProgress()
        progress.examDate = date
        try dataService.saveUserProgress(progress)
        logger.info("Exam date saved: \(date.formatted())")
    }
    
    func fetchProgress() async throws -> UserProgress {
        do {
            return try await dataService.fetchUserProgress() ?? UserProgress()
        } catch {
            logger.error("Failed to fetch progress: \(error.localizedDescription)")
            return UserProgress() // Graceful fallback
        }
    }
    
    func recordAnswer(questionId: String, categoryId: String, isCorrect: Bool) async throws {
        var progress = try await fetchProgress()
        
        progress.totalQuestionsAttempted += 1
        if isCorrect {
            progress.correctAnswers += 1
        }
        
        var catProgress = progress.categoryProgress[categoryId] 
            ?? UserProgress.CategoryProgress(questionsAttempted: 0, correctAnswers: 0)
        catProgress.questionsAttempted += 1
        if isCorrect {
            catProgress.correctAnswers += 1
        }
        progress.categoryProgress[categoryId] = catProgress
        progress.lastUpdated = Date()
        
        try dataService.saveUserProgress(progress)
        logger.debug("Answer recorded for category: \(categoryId), correct: \(isCorrect)")
    }
    
    func resetProgress() throws {
        try dataService.saveUserProgress(UserProgress())
        logger.info("Progress reset")
    }
    
    func getWeakAreas() async throws -> [String] {
        let progress = try await fetchProgress()
        return progress.categoryProgress
            .filter { $0.value.percentage < 70 }
            .keys
            .sorted()
    }
}