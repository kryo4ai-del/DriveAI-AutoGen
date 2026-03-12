import SwiftUI

struct ThemeColors {
    let primary: Color
    let secondary: Color
    let background: Color
    let text: Color
}

struct DesignSystemModel {
    let cornerRadius: CGFloat = 12

    func colors(for theme: AppTheme) -> ThemeColors {
        switch theme {
        case .light:
            return ThemeColors(
                primary: .blue,
                secondary: .green,
                background: .white,
                text: .black
            )
        case .dark:
            return ThemeColors(
                primary: .blue,
                secondary: .green,
                background: .black,
                text: .white
            )
        }
    }

    func font(for theme: AppTheme, size: CGFloat) -> Font {
        return .system(size: size, weight: .regular)
    }
}
