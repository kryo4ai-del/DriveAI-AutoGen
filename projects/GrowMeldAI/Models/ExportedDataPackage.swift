import Foundation

struct ExportedDataPackage: Codable {
    let userId: UUID
    let exportDate: Date
    let examDate: Date?
    let displayName: String
    let totalQuestionsAnswered: Int
    let totalCorrect: Int
    let consentHistory: [ConsentRecord]
    let auditTrail: [AuditLogEntry]
    
    enum CodingKeys: String, CodingKey {
        case userId
        case exportDate
        case examDate
        case displayName
        case totalQuestionsAnswered
        case totalCorrect
        case consentHistory
        case auditTrail
    }
}