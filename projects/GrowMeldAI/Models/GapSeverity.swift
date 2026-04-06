import SwiftUI
enum GapSeverity: Int, Comparable, Hashable {
    case critical = 2      // < 40% accuracy
    case moderate = 1      // 40-69% accuracy
    case minor = 0         // 70-89% accuracy
    
    var label: String {
        switch self {
        case .critical: return "Kritisch"
        case .moderate: return "Mittel"
        case .minor: return "Gering"
        }
    }
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .moderate: return .orange
        case .minor: return .yellow
        }
    }
    
    static func < (lhs: GapSeverity, rhs: GapSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue  // ← Compiler enforces all cases have rawValue
    }
}