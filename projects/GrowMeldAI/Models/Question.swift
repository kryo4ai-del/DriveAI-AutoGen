// Features/Questions/Models/Question.swift
import Foundation

struct Question: Codable, Identifiable, Equatable {
    let id: String
    let text: String
    let category: Category
    let answers: [Answer]
    let correctAnswerID: String
    let explanation: String?
    let difficulty: DifficultyLevel
    let imageURL: String?
    
    enum DifficultyLevel: String, Codable {
        case easy, medium, hard
    }
    
    var correctAnswer: Answer? {
        answers.first { $0.id == correctAnswerID }
    }
    
    init(
        id: String,
        text: String,
        category: Category,
        answers: [Answer],
        correctAnswerID: String,
        explanation: String? = nil,
        difficulty: DifficultyLevel = .medium,
        imageURL: String? = nil
    ) {
        precondition(!id.isEmpty, "Question ID must not be empty")
        precondition(!text.isEmpty, "Question text must not be empty")
        precondition(!answers.isEmpty, "Question must have at least one answer")
        precondition(
            answers.contains { $0.id == correctAnswerID },
            "Correct answer ID must exist in answers array"
        )
        
        self.id = id
        self.text = text
        self.category = category
        self.answers = answers
        self.correctAnswerID = correctAnswerID
        self.explanation = explanation
        self.difficulty = difficulty
        self.imageURL = imageURL
    }
}

struct Answer: Codable, Identifiable, Equatable {
    let id: String
    let text: String
    
    init(id: String, text: String) {
        precondition(!id.isEmpty, "Answer ID must not be empty")
        precondition(!text.isEmpty, "Answer text must not be empty")
        self.id = id
        self.text = text
    }
}

// Features/Questions/Models/Category.swift
// Struct Category declared in Models/Category.swift

// Features/Exam/Models/ExamResult.swift
import Foundation

// Struct QuizResult declared in Models/QuizResult.swift

// Struct ExamResult declared in Models/ExamResult.swift

struct CategoryBreakdown: Identifiable, Equatable {
    let id: String
    let category: Category
    let correct: Int
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0.0 }
        return Double(correct) / Double(total)
    }
}