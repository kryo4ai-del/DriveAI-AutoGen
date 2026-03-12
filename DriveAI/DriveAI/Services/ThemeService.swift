import SwiftUI
import Combine

class ThemeService: ObservableObject {
    @Published private(set) var currentTheme: AppTheme = .light

    func updateTheme(_ theme: AppTheme) {
        currentTheme = theme
        // Notify other components if necessary.
    }

    func getColors() -> ThemeColors {
        DesignSystemModel().colors(for: currentTheme)
    }
    
    func getFont(size: CGFloat) -> Font {
        DesignSystemModel().font(for: currentTheme, size: size)
    }
}