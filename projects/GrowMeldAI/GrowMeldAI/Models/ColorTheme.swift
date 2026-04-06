// Theme/Theme+Environment.swift
import SwiftUI

enum ColorTheme {
    case light
    case dark
    case custom(background: Color, text: Color, primary: Color, secondary: Color)

    var background: Color {
        switch self {
        case .light: return .white
        case .dark: return .black
        case .custom(let background, _, _, _): return background
        }
    }

    var text: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .custom(_, let text, _, _): return text
        }
    }

    var primary: Color {
        switch self {
        case .light: return .blue
        case .dark: return .blue
        case .custom(_, _, let primary, _): return primary
        }
    }

    var secondary: Color {
        switch self {
        case .light: return .gray
        case .dark: return .gray
        case .custom(_, _, _, let secondary): return secondary
        }
    }
}

struct ColorThemeKey: EnvironmentKey {
    static let defaultValue: ColorTheme = .light
}

extension EnvironmentValues {
    var colorTheme: ColorTheme {
        get { self[ColorThemeKey.self] }
        set { self[ColorThemeKey.self] = newValue }
    }
}