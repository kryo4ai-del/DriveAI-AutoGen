// Services/QuestionSelectionService.swift
protocol QuestionSelectionProtocol {
    func selectNextQuestion(
        context: SelectionContext
    ) async throws -> Question
}

struct SelectionContext {
    let userPerformance: [String: Double]  // categoryId: successRate
    let examMode: Bool  // Simulate real exam frequency
    let focusWeakAreas: Bool
}

class AdaptiveQuestionSelector: QuestionSelectionProtocol {
    func selectNextQuestion(context: SelectionContext) async throws -> Question {
        var candidates = try await dataService.loadQuestions()
        
        if context.focusWeakAreas {
            // Filter to categories where user struggled
            candidates = candidates.filter { q in
                let performance = context.userPerformance[q.categoryId] ?? 0
                return performance < 0.7  // Focus on <70% accuracy
            }
        }
        
        if context.examMode {
            // Weight by examFrequency (bias towards likely exam questions)
            let weighted = candidates.map { q -> (Question, Double) in
                (q, q.examFrequency * Double(6 - q.difficulty) / 5)  // Harder Qs slightly less likely
            }
            return selectWeighted(weighted)
        }
        
        return candidates.randomElement() ?? candidates[0]
    }
}