import SwiftUI

struct StyleService {
    static func color(for theme: AppTheme) -> Color {
        switch theme {
        case .light:
            return Color.blue // Light theme primary color
        case .dark:
            return Color.yellow // Dark theme primary color
        }
    }
}