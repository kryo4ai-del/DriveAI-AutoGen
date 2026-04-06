import Foundation

struct QuizLogicService {
    func shuffleQuestions(_ questions: [Question]) -> [Question] {
        questions.shuffled()
    }
    
    func selectRandomQuestions(_ questions: [Question], count: Int) -> [Question] {
        Array(questions.shuffled().prefix(count))
    }
    
    func calculateScore(
        totalQuestions: Int,
        correctAnswers: Int
    ) -> (score: Int, percentage: Double, passed: Bool) {
        let percentage = totalQuestions == 0 ? 0 : (Double(correctAnswers) / Double(totalQuestions)) * 100
        let score = totalQuestions == 0 ? 0 : (correctAnswers * 100) / totalQuestions
        let passed = percentage >= 70.0  // German exam passing threshold
        
        return (score, percentage, passed)
    }
    
    func getCategoryBreakdown(
        for questions: [Question],
        with answers: [UUID: (selectedIndex: Int, correct: Bool)]
    ) -> [QuestionCategory: CategoryBreakdown] {
        var breakdown: [QuestionCategory: CategoryBreakdown] = [:]
        
        for question in questions {
            let answerData = answers[question.id]
            let isCorrect = answerData?.correct ?? false
            
            if breakdown[question.category] == nil {
                breakdown[question.category] = CategoryBreakdown()
            }
            
            var category = breakdown[question.category]!
            category.total += 1
            if isCorrect {
                category.correct += 1
            }
            breakdown[question.category] = category
        }
        
        return breakdown
    }
}

struct CategoryBreakdown {
    var total: Int = 0
    var correct: Int = 0
    
    var accuracy: Double {
        total == 0 ? 0 : Double(correct) / Double(total)
    }
}