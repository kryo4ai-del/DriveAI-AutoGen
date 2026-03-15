import Foundation
// 1. Define proper error types
enum ExamReadinessError: LocalizedError, Codable {
    case noCategoryData(reason: String)
    case corruptTrendData(categoryId: String)
    case persistenceFailure(String)
    case invalidCategoryId(String)
    
    var errorDescription: String? {
        switch self {
        case .noCategoryData(let reason):
            return "Kategoriendaten nicht verfügbar: \(reason)"
        case .corruptTrendData(let catId):
            return "Beschädigte Trenddaten für \(catId)"
        case .persistenceFailure(let msg):
            return "Speicherfehler: \(msg)"
        case .invalidCategoryId(let id):
            return "Ungültige Kategorie-ID: \(id)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noCategoryData:
            return "Versuchen Sie es später erneut"
        case .corruptTrendData:
            return "Löschen Sie den App-Cache und starten Sie neu"
        case .persistenceFailure:
            return "Überprüfen Sie den verfügbaren Speicherplatz"
        case .invalidCategoryId:
            return "Kontaktieren Sie Support"
        }
    }
}

// 2. Refactor service method
// [FK-019 sanitized] @MainActor

// 3. In ViewModel, handle specific errors
// [FK-019 sanitized] @MainActor