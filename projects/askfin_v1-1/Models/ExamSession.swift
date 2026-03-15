// ExamSession.swift
// Auto-generated stub — type was referenced but never declared.
// Referenced in:
//   - Models/AppCoordinator.swift
//   - Models/ExamSessionViewModelTests.swift
//   - Models/QuestionRepositoryProtocol.swift
//   - Services/PersistenceService.swift
//   - ViewModels/ExamSessionViewModel.swift
//
// TODO: Replace this stub with a full implementation.

import Foundation

struct ExamSession: Sendable {
    let id: String
    let startTime: Date
    var endTime: Date?
    var answers: [String: Int]
    var score: Int?
    var passed: Bool?
    let questionIds: [String]

    init(
        id: String = UUID().uuidString,
        startTime: Date = Date(),
        endTime: Date? = nil,
        answers: [String: Int] = [:],
        score: Int? = nil,
        passed: Bool? = nil,
        questionIds: [String] = []
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.answers = answers
        self.score = score
        self.passed = passed
        self.questionIds = questionIds
    }
}
