// Services/ExamSimulationService.swift
protocol ExamDecisionService {
    /// Evaluates exam result with GDPR compliance safeguards
    /// - Returns: Decision + audit trail for potential challenge
    func evaluateExam(
        answers: [AnswerRecord],
        complianceMode: ComplianceMode
    ) -> DecisionWithAudit
}

struct DecisionWithAudit {
    let passed: Bool
    let score: Int
    let passingThreshold: Int
    let decisionReason: String  // Transparent
    let auditId: UUID  // For compliance audits
    let allowsChallenge: Bool  // Art. 22 right to object
    let createdAt: Date
}

enum ComplianceMode {
    case standard  // Default
    case withHumanReview  // If Art. 22 applies
}