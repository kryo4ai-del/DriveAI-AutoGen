import SwiftUI

struct ColorPalette {
    // MARK: - Primary Brand Colors
    let primary: Color
    let primaryLight: Color
    let primaryDark: Color
    
    // MARK: - Semantic/Feedback Colors
    let success: Color      // Correct answer
    let error: Color        // Wrong answer / errors
    let warning: Color      // Timer warnings
    let info: Color         // Informational
    
    // MARK: - Neutral Colors
    let background: Color
    let surface: Color      // Cards, containers
    let surfaceVariant: Color
    let text: Color
    let textSecondary: Color
    let textTertiary: Color
    let border: Color
    let divider: Color
    
    // MARK: - Current Palette (Respects Dark Mode)
    static var current: ColorPalette {
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark:
            return .dark
        default:
            return .light
        }
    }
    
    // MARK: - Light Mode Palette
    static let light = ColorPalette(
        primary: Color(red: 0.2, green: 0.55, blue: 0.95),           // Blue
        primaryLight: Color(red: 0.4, green: 0.75, blue: 1.0),
        primaryDark: Color(red: 0.1, green: 0.35, blue: 0.75),
        
        success: Color(red: 0.2, green: 0.8, blue: 0.4),             // Green
        error: Color(red: 0.95, green: 0.2, blue: 0.2),              // Red
        warning: Color(red: 1.0, green: 0.65, blue: 0.0),            // Orange
        info: Color(red: 0.1, green: 0.5, blue: 0.9),
        
        background: Color.white,
        surface: Color(red: 0.97, green: 0.97, blue: 0.98),
        surfaceVariant: Color(red: 0.93, green: 0.93, blue: 0.95),
        text: Color.black,
        textSecondary: Color(red: 0.3, green: 0.3, blue: 0.3),
        textTertiary: Color(red: 0.6, green: 0.6, blue: 0.6),
        border: Color(red: 0.85, green: 0.85, blue: 0.85),
        divider: Color(red: 0.9, green: 0.9, blue: 0.9)
    )
    
    // MARK: - Dark Mode Palette
    static let dark = ColorPalette(
        primary: Color(red: 0.5, green: 0.8, blue: 1.0),
        primaryLight: Color(red: 0.7, green: 0.9, blue: 1.0),
        primaryDark: Color(red: 0.3, green: 0.6, blue: 0.9),
        
        success: Color(red: 0.4, green: 0.95, blue: 0.5),
        error: Color(red: 1.0, green: 0.4, blue: 0.4),
        warning: Color(red: 1.0, green: 0.8, blue: 0.2),
        info: Color(red: 0.4, green: 0.7, blue: 1.0),
        
        background: Color(red: 0.1, green: 0.1, blue: 0.11),
        surface: Color(red: 0.15, green: 0.15, blue: 0.16),
        surfaceVariant: Color(red: 0.2, green: 0.2, blue: 0.22),
        text: Color.white,
        textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8),
        textTertiary: Color(red: 0.6, green: 0.6, blue: 0.6),
        border: Color(red: 0.3, green: 0.3, blue: 0.3),
        divider: Color(red: 0.25, green: 0.25, blue: 0.25)
    )
}

// MARK: - Environment Key for SwiftUI Integration
struct ColorPaletteKey: EnvironmentKey {
    static let defaultValue = ColorPalette.current
}

extension EnvironmentValues {
    var colorPalette: ColorPalette {
        get { self[ColorPaletteKey.self] }
        set { self[ColorPaletteKey.self] = newValue }
    }
}