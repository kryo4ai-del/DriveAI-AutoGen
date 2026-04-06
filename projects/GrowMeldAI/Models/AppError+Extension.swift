import Foundation

enum AppError: Error {
    case fileNotFound
    case jsonDecodingFailed
    case persistenceFailed
    case networkUnavailable
    case dataValidationFailed
    case unknownError
}

extension AppError {
    func recover() -> Bool {
        switch self {
        case .fileNotFound, .jsonDecodingFailed:
            return resetToDefaultData()
        case .persistenceFailed:
            return clearCache()
        case .networkUnavailable, .dataValidationFailed, .unknownError:
            return false
        }
    }

    private func resetToDefaultData() -> Bool {
        return true
    }

    private func clearCache() -> Bool {
        return true
    }
}