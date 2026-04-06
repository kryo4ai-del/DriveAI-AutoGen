// Models/AppError+Extension.swift
import Foundation

// MARK: - AppError Definition

enum AppError: Error {
    case fileNotFound
    case jsonDecodingFailed
    case persistenceFailed
    case networkUnavailable
    case dataValidationFailed
    case unknownError
}

// MARK: - Recovery Extension

extension AppError {
    func recover() -> Bool {
        switch self {
        case .fileNotFound, .jsonDecodingFailed:
            // Attempt to reset to default data
            return resetToDefaultData()
        case .persistenceFailed:
            // Attempt to clear cache
            return clearCache()
        case .networkUnavailable, .dataValidationFailed, .unknownError:
            // No automatic recovery for these
            return false
        }
    }

    private func resetToDefaultData() -> Bool {
        // Implementation would restore default bundled data
        return true
    }

    private func clearCache() -> Bool {
        // Implementation would clear temporary files
        return true
    }
}