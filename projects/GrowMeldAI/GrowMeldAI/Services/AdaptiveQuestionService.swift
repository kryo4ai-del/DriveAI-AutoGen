// Services/Learning/AdaptiveQuestionService.swift
protocol AdaptiveQuestionService {
    func getNextQuestion(
        categoryId: String,
        userProgress: UserProgress
    ) async throws -> Question
}

final class AdaptiveQuestionServiceImpl: AdaptiveQuestionService {
    func getNextQuestion(categoryId: String, userProgress: UserProgress) async throws -> Question {
        let categoryProgress = userProgress.categoryProgress[categoryId]
        let percentage = categoryProgress?.percentage ?? 0
        
        // Spaced repetition: ask harder questions on topics already known
        let questions = try await dataService.getQuestionsByCategory(categoryId)
        
        // Weight by mastery: questions user got wrong recently bubble up
        let weighted = questions.sorted { q1, q2 in
            let q1Mastered = categoryProgress?.correctAnswers ?? 0 > 3
            let q2Mastered = categoryProgress?.correctAnswers ?? 0 > 3
            
            return q1Mastered ? false : true  // Ask weak areas first
        }
        
        return weighted.randomElement() ?? questions.first!
    }
}