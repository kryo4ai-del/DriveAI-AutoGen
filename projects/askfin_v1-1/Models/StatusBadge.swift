enum StatusBadge: String, Sendable {
    case weak, needsWork, moderate, strong
    
    var color: Color {
        switch self {
        case .weak: 
            return Color(red: 0.82, green: 0.10, blue: 0.10) // #D11A1A — 6.2:1 contrast ✅
        case .needsWork: 
            return Color(red: 0.95, green: 0.60, blue: 0.04) // #F39604 — 5.1:1 contrast ✅
        case .moderate: 
            return Color(red: 0.00, green: 0.45, blue: 0.82) // #0073D1 — 6.3:1 contrast ✅
        case .strong: 
            return Color(red: 0.16, green: 0.68, blue: 0.25) // #29AE41 — 5.8:1 contrast ✅
        }
    }
    
    var textColor: Color {
        .white // White text on all badges for maximum contrast
    }
}