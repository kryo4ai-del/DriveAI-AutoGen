// MARK: - Models/DiagnosticError.swift

import Foundation

enum DiagnosticError: LocalizedError, Equatable {
    case progressDataMissing
    case categoryDataMissing
    case computationFailed(String)
    case timeoutExceeded
    case invalidInput(String)
    
    var errorDescription: String? {
        switch self {
        case .progressDataMissing:
            return "Fortschrittsdaten nicht verfügbar"
        case .categoryDataMissing:
            return "Kategoriedaten konnten nicht geladen werden"
        case .computationFailed(let details):
            return "Diagnose fehlgeschlagen: \(details)"
        case .timeoutExceeded:
            return "Anfrage hat zu lange gedauert. Bitte versuchen Sie es erneut."
        case .invalidInput(let reason):
            return "Ungültige Eingabe: \(reason)"
        }
    }
    
    static func == (lhs: DiagnosticError, rhs: DiagnosticError) -> Bool {
        switch (lhs, rhs) {
        case (.progressDataMissing, .progressDataMissing),
             (.categoryDataMissing, .categoryDataMissing),
             (.timeoutExceeded, .timeoutExceeded):
            return true
        case (.computationFailed(let lhsMsg), .computationFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.invalidInput(let lhsReason), .invalidInput(let rhsReason)):
            return lhsReason == rhsReason
        default:
            return false
        }
    }
}

// MARK: - Models/GapSeverity.swift

import SwiftUI

// MARK: - Models/MasteryLevel.swift

import SwiftUI

// MARK: - Models/LearningGap.swift

import Foundation

// MARK: - Models/CategoryStrength.swift

import Foundation

// MARK: - Models/Recommendation.swift

import Foundation

// MARK: - Models/DiagnosticAction.swift

import Foundation

// Struct DiagnosticAction declared in Models/DiagnosticAction.swift

// MARK: - Models/DiagnosticResult.swift

import Foundation
