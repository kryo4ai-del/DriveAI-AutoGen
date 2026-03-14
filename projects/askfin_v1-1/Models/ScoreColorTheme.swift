// DesignSystem.swift (centralized)
enum ScoreColorTheme {
    case performance    // 0-60-80-100
    case readiness      // 0-40-60-75-90-100
    
    func color(for score: Int) -> Color {
        switch self {
        case .performance:
            switch score {
            case 80...: return .green
            case 60..<80: return .yellow
            default: return .red
            }
        case .readiness:
            switch score {
            case 90...: return Color(red: 0.1, green: 0.75, blue: 0.2)
            case 75..<90: return Color(red: 0.2, green: 0.8, blue: 0.3)
            // ...
            }
        }
    }
}

// Usage