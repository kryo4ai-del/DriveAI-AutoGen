// Services/MasteryCalculationService.swift
import Foundation
import Combine

protocol MasteryCalculationServiceProtocol {
    func calculateMastery(for categoryId: String, from quizHistory: [QuizAttempt]) -> MasteryRecord?
    func updateMastery(after quizCompletion: QuizSession)
    func fetchMasteryByCategory() -> [MasteryRecord]
    func fetchOverallMastery() -> Double
}

final class MasteryCalculationService: MasteryCalculationServiceProtocol {
    private let localDataService: LocalDataService
    
    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
    }
    
    func calculateMastery(
        for categoryId: String,
        from quizHistory: [QuizAttempt]
    ) -> MasteryRecord? {
        let categoryAttempts = quizHistory.filter { $0.categoryId == categoryId }
        guard !categoryAttempts.isEmpty else { return nil }
        
        let correct = categoryAttempts.filter { $0.isCorrect }.count
        let categoryName = localDataService.getCategoryName(categoryId) ?? categoryId
        
        return MasteryRecord(
            id: UUID(),
            categoryId: categoryId,
            categoryName: categoryName,
            correctAnswers: correct,
            totalAnswers: categoryAttempts.count,
            lastUpdated: Date()
        )
    }
    
    func updateMastery(after quizCompletion: QuizSession) {
        let categories = Set(quizCompletion.answers.map { $0.categoryId })
        
        for categoryId in categories {
            if let mastery = calculateMastery(
                for: categoryId,
                from: quizCompletion.answers
            ) {
                localDataService.saveMastery(mastery)
            }
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("MasteryUpdated"),
            object: nil
        )
    }
    
    func fetchMasteryByCategory() -> [MasteryRecord] {
        localDataService.fetchAllMastery()
            .sorted { $0.masteryPercentage > $1.masteryPercentage }
    }
    
    func fetchOverallMastery() -> Double {
        let records = fetchMasteryByCategory()
        guard !records.isEmpty else { return 0 }
        
        let totalPercentage = records.reduce(0) { $0 + Double($1.masteryPercentage) }
        return totalPercentage / Double(records.count)
    }
}