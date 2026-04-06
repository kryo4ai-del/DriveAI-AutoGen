// File: Services/LocalQuestionService.swift
import Foundation

final class LocalQuestionService: QuestionServiceProtocol {
    func loadQuestions() -> [ExamQuestion] {
        // In a real implementation, this would load from a local JSON file
        // For now, returning sample questions
        return [
            ExamQuestion(
                id: UUID(),
                questionText: "What does this traffic sign mean?",
                options: ["Stop", "Yield", "No entry", "Speed limit"],
                correctAnswerIndex: 1,
                category: .roadSigns,
                explanation: "The yield sign means you must give way to other traffic.",
                difficulty: .easy
            ),
            ExamQuestion(
                id: UUID(),
                questionText: "At a red traffic light, when are you allowed to turn right?",
                options: ["Never", "After coming to a complete stop", "After yielding to pedestrians and other traffic", "Only if there's a green arrow"],
                correctAnswerIndex: 2,
                category: .trafficRules,
                explanation: "You may turn right on red after coming to a complete stop and yielding to all other traffic and pedestrians.",
                difficulty: .medium
            )
        ]
    }
}