// File: AppThemeManager.swift
import SwiftUI

final class AppThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .light

    enum AppTheme {
        case light, dark, system

        var colorScheme: ColorScheme {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return .unspecified
            }
        }

        var primaryColor: Color {
            switch self {
            case .light: return .drivePrimary
            case .dark: return .drivePrimaryDark
            case .system: return .drivePrimary
            }
        }
    }

    func toggleTheme() {
        currentTheme = {
            switch currentTheme {
            case .light: return .dark
            case .dark: return .system
            case .system: return .light
            }
        }()
    }
}