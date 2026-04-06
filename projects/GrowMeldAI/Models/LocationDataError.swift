import Foundation

enum LocationDataError: Error {
    case bundleFileNotFound(String)
    case invalidData
    case decodingFailed(String)
}

extension LocationDataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .bundleFileNotFound(let name):
            return "Bundle file not found: \(name)"
        case .invalidData:
            return "Invalid data"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        }
    }
}

enum LocationRepositoryError: Error {
    case saveFailed
    case encodingFailed
}

extension LocationRepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Save failed"
        case .encodingFailed:
            return "Encoding failed"
        }
    }
}