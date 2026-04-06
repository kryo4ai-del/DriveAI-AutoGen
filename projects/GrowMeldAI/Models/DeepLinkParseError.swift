import Foundation

enum DeepLinkParseError: LocalizedError {
    case unknownPath(String)
    case malformedCategoryId(String)

    var errorDescription: String? {
        switch self {
        case .unknownPath(let path):
            return "Unknown deep link path: \(path)"
        case .malformedCategoryId(let path):
            return "Malformed category ID in path: \(path)"
        }
    }
}