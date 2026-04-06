// ✅ Models/ExamSnapshot.swift
struct ExamSnapshot: Codable {
    let examID: UUID
    let currentQuestionIndex: Int
    let answers: [String: Answer]
    let timestamp: Date
    let timeRemaining: TimeInterval
    let questions: [Question]
}

// ✅ Models/Category.swift

// ✅ Models/Progress.swift (Enhanced)
