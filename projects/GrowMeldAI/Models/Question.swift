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
struct Category: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String?
    let questionCount: Int
    
    init(
        id: String,
        name: String,
        description: String = "",
        icon: String? = nil,
        questionCount: Int = 0
    ) {
        precondition(!id.isEmpty, "Category ID must not be empty")
        precondition(!name.isEmpty, "Category name must not be empty")
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.questionCount = questionCount
    }
}

// Features/Exam/Models/ExamResult.swift
import Foundation

struct QuizResult: Identifiable, Equatable {
    let id: UUID = UUID()
    let totalQuestions: Int
    let correctAnswers: Int
    let category: Category?
    let duration: TimeInterval
    let timestamp: Date
    
    init(
        totalQuestions: Int,
        correctAnswers: Int,
        category: Category? = nil,
        duration: TimeInterval = 0,
        timestamp: Date = Date()
    ) {
        precondition(totalQuestions > 0, "Total questions must be greater than 0")
        precondition(correctAnswers >= 0, "Correct answers cannot be negative")
        precondition(
            correctAnswers <= totalQuestions,
            "Correct answers cannot exceed total questions"
        )
        
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.category = category
        self.duration = duration
        self.timestamp = timestamp
    }
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var percentage: Int {
        Int(accuracy * 100)
    }
    
    // German driving license exam requires 75% pass rate
    private static let passingThreshold: Double = 0.75
    
    var passed: Bool {
        accuracy >= Self.passingThreshold
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ExamResult: Identifiable, Equatable {
    let id: UUID = UUID()
    let quizResult: QuizResult
    let categoryBreakdowns: [CategoryBreakdown]
    let completedAt: Date
    
    var score: Int {
        quizResult.percentage
    }
    
    var passed: Bool {
        quizResult.passed
    }
    
    init(
        quizResult: QuizResult,
        categoryBreakdowns: [CategoryBreakdown] = [],
        completedAt: Date = Date()
    ) {
        self.quizResult = quizResult
        self.categoryBreakdowns = categoryBreakdowns
        self.completedAt = completedAt
    }
}

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