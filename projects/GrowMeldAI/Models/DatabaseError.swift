import Foundation

enum DatabaseError: LocalizedError {
    case invalidQuestion(String)
    case corruptedData(String)

    var errorDescription: String? {
        switch self {
        case .invalidQuestion(let message):
            return "Invalid question: \(message)"
        case .corruptedData(let message):
            return "Corrupted data: \(message)"
        }
    }
}