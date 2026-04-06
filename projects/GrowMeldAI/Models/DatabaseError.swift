// Struct Question declared in Models/Question.swift
import Foundation

typealias Row = [String: Any]

enum DatabaseError: LocalizedError {
    case invalidQuestion(String)
    case corruptedData(String)
    case openFailed(reason: String)
    case closed
    case prepareFailed(sql: String, reason: String)
    case executionFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .invalidQuestion(let message):
            return message
        case .corruptedData(let message):
            return message
        case .openFailed(let reason):
            return "Failed to open database: \(reason)"
        case .closed:
            return "Database is closed"
        case .prepareFailed(let sql, let reason):
            return "Failed to prepare: \(sql) - \(reason)"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        }
    }
}