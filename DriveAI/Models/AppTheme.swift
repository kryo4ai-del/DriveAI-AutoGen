import Foundation
import SwiftUI

enum AppTheme {
    case light, dark
}

struct DesignSystemModel {
    let margins: CGFloat = 16.0
    let cornerRadius: CGFloat = 10.0
    let lightColors: ThemeColors = ThemeColors(primary: .blue, background: .white)
    let darkColors: ThemeColors = ThemeColors(primary: .yellow, background: .black)

    func colors(for theme: AppTheme) -> ThemeColors {
        switch theme {
        case .light:
            return lightColors
        case .dark:
            return darkColors
        }
    }

    // New method to provide font styles
    func font(for theme: AppTheme, size: CGFloat) -> Font {
        switch theme {
        case .light:
            return Font.system(size: size, weight: .regular, design: .default)
        case .dark:
            return Font.system(size: size, weight: .bold, design: .default)
        }
    }
}

struct ThemeColors {
    var primary: Color
    var background: Color
}