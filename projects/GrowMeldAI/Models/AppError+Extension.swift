import Foundation

enum AppError: Error {
    case fileNotFound
    case jsonDecodingFailed
    case persistenceFailed
    case networkUnavailable
    case dataValidationFailed
    case unknownError
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found."
        case .jsonDecodingFailed:
            return "JSON decoding failed."
        case .persistenceFailed:
            return "Persistence failed."
        case .networkUnavailable:
            return "Network unavailable."
        case .dataValidationFailed:
            return "Data validation failed."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
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