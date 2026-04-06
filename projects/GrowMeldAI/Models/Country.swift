// MARK: - Models/Country.swift

enum Country: CaseIterable, Hashable {
    case australia
    case canada
    
    var id: String {
        switch self {
        case .australia: return "AU"
        case .canada: return "CA"
        }
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
    
    static var allCases: [Country] = [.australia, .canada]
}