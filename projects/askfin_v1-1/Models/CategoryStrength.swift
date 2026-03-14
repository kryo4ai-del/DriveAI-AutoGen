// Models/ExamReadiness.swift

enum CategoryStrength: String, Codable {
    case weak, fair, strong
    
    var label: String {
        switch self {
        case .weak: return NSLocalizedString("strength.weak", comment: "Category strength")
        case .fair: return NSLocalizedString("strength.fair", comment: "Category strength")
        case .strong: return NSLocalizedString("strength.strong", comment: "Category strength")
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .fair: return .yellow
        case .strong: return .green
        }
    }
    
    init(percentage: Int) {
        switch percentage {
        case 0..<40: self = .weak
        case 40..<70: self = .fair
        default: self = .strong
        }
    }
}

// In models, use String not LocalizedStringKey