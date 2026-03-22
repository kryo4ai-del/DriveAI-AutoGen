enum ReadinessLevel: Comparable {
    case needsWork      // 0-59%
    case closeToReady   // 60-79%
    case ready          // 80%+
    
    var color: Color {
        switch self {
        case .needsWork: return .red
        case .closeToReady: return .orange
        case .ready: return .green
        }
    }
    
    var description: String {
        switch self {
        case .needsWork: return "Needs Work"
        case .closeToReady: return "Close to Ready"
        case .ready: return "Ready for Exam"
        }
    }
}

final class ReadinessCalculator {
    func calculateReadiness(score: Int) -> ReadinessLevel {
        switch score {
        case 0..<60: return .needsWork
        case 60..<80: return .closeToReady
        default: return .ready
        }
    }
    
    func identifyWeakTopics(
        answers: [Int?],
        questions: [Question]
    ) -> [String] {
        var topicScores: [String: (correct: Int, total: Int)] = [:]
        
        for (index, answer) in answers.enumerated() {
            guard index < questions.count else { continue }
            let question = questions[index]
            let topic = question.category
            
            let isCorrect = answer == question.correctAnswerIndex
            topicScores[topic, default: (0, 0)].total += 1
            if isCorrect {
                topicScores[topic]?.correct += 1
            }
        }
        
        // Return topics scoring < 70%
        return topicScores.filter { _, scores in
            scores.total > 0 && Double(scores.correct) / Double(scores.total) < 0.7
        }.keys.sorted()
    }
}