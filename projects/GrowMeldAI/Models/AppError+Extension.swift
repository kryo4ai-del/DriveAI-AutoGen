import Foundation

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