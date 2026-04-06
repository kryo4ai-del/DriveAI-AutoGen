import Foundation

enum Country: String, CaseIterable, Hashable, Codable {
    case australia = "AU"
    case canada = "CA"

    var id: String {
        return rawValue
    }

    var displayName: String {
        switch self {
        case .australia: return "Australia"
        case .canada: return "Canada"
        }
    }

    var flag: String {
        switch self {
        case .australia: return "🇦🇺"
        case .canada: return "🇨🇦"
        }
    }
}