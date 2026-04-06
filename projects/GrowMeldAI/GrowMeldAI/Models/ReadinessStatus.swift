import Foundation

enum ReadinessStatus: Equatable {
    case red    // 0–18 questions (0–75%)
    case yellow // 19–23 questions (75–95%)
    case green  // 24+ questions (≥100%)

    var color: Color {
        switch self {
        case .red: return DriveAIColors.incorrectAnswer
        case .yellow: return DriveAIColors.warningReview
        case .green: return DriveAIColors.correctAnswer
        }
    }

    var label: String {
        switch self {
        case .red: return "Weiterüben"
        case .yellow: return "Fast bereit"
        case .green: return "Prüfungsreif!"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .red: return "Nicht bereit für die Prüfung"
        case .yellow: return "Fast bereit für die Prüfung"
        case .green: return "Bereit für die Prüfung"
        }
    }
}