enum ProficiencyLevel: Codable {
    case weak, fair, strong
}

// In Models/Localization/LocalizedStrings.swift
extension ProficiencyLevel {
    var localizedName: String {
        switch self {
        case .weak: return NSLocalizedString("proficiency.weak", comment: "")
        case .fair: return NSLocalizedString("proficiency.fair", comment: "")
        case .strong: return NSLocalizedString("proficiency.strong", comment: "")
        }
    }
    
    var emoji: String {
        switch self {
        case .weak: return "🔴"
        case .fair: return "🟡"
        case .strong: return "🟢"
        }
    }
}