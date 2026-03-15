import Foundation
@testable import DriveAI

struct TestData {
    // Sample questions
    static let sampleQuestions: [Question] = [
        Question(id: "Q1", category: "Traffic Signs", text: "What does a red octagon mean?",
                answers: ["Stop", "Yield", "Speed limit"], correctAnswerIndex: 0),
        Question(id: "Q2", category: "Traffic Signs", text: "What does a triangle mean?",
                answers: ["Stop", "Warning", "Speed limit"], correctAnswerIndex: 1),
        Question(id: "Q3", category: "Right of Way", text: "Who has right of way?",
                answers: ["Left", "Right", "Straight"], correctAnswerIndex: 1),
        Question(id: "Q4", category: "Right of Way", text: "At intersection, who goes first?",
                answers: ["Younger driver", "Faster car", "Whoever arrived first"], correctAnswerIndex: 2),
        Question(id: "Q5", category: "Parking", text: "Where can you park?",
                answers: ["Fire lane", "Sidewalk", "Parking spot"], correctAnswerIndex: 2),
        Question(id: "Q6", category: "Parking", text: "What does red curb mean?",
                answers: ["No parking", "Reserved", "Permit only"], correctAnswerIndex: 0),
    ]
    
    // Sample answers (strong in Traffic Signs, weak in Parking)
    static let sampleAnswerHistory: [UserAnswer] = [
        // Traffic Signs: 2/2 correct
        UserAnswer(questionId: "Q1", selectedAnswerIndex: 0, isCorrect: true, answeredAt: Date().addingTimeInterval(-3600)),
        UserAnswer(questionId: "Q2", selectedAnswerIndex: 1, isCorrect: true, answeredAt: Date().addingTimeInterval(-3500)),
        
        // Right of Way: 1/2 correct
        UserAnswer(questionId: "Q3", selectedAnswerIndex: 0, isCorrect: false, answeredAt: Date().addingTimeInterval(-3400)),
        UserAnswer(questionId: "Q4", selectedAnswerIndex: 2, isCorrect: true, answeredAt: Date().addingTimeInterval(-3300)),
        
        // Parking: 0/2 correct
        UserAnswer(questionId: "Q5", selectedAnswerIndex: 0, isCorrect: false, answeredAt: Date().addingTimeInterval(-3200)),
        UserAnswer(questionId: "Q6", selectedAnswerIndex: 1, isCorrect: false, answeredAt: Date().addingTimeInterval(-3100)),
    ]
    
    // Extended history for trend analysis
    static let extendedAnswerHistory: [UserAnswer] = {
        var answers: [UserAnswer] = []
        let base = Date().addingTimeInterval(-86400 * 30) // 30 days ago
        
        // Simulate improving trend
        for window in 0..<10 {
            let startIdx = window * 10
            let endIdx = min(startIdx + 10, sampleQuestions.count)
            let windowBase = base.addingTimeInterval(Double(window) * 86400 * 3)
            
            for (idx, qId) in (0..<(endIdx - startIdx)).map({ sampleQuestions[startIdx + $0].id }) {
                // Improvement over time: first windows 30%, last windows 80%
                let correctProbability = 0.3 + (Double(window) / 10.0) * 0.5
                let isCorrect = Double.random(in: 0..<1) < correctProbability
                
                answers.append(UserAnswer(
                    questionId: qId,
                    selectedAnswerIndex: 0,
                    isCorrect: isCorrect,
                    answeredAt: windowBase.addingTimeInterval(Double(idx) * 60)
                ))
            }
        }
        return answers
    }()
}