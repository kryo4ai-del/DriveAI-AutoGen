// Theme/DriveAITheme.swift
enum DriveAITheme {
    static let backgroundColor = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            : UIColor.white
    })
    
    static let accentColor = Color(red: 0.2, green: 0.5, blue: 1.0)
    static let spacing = 24.0
    static let titleFont = Font.system(size: 36, weight: .bold, design: .rounded)
}

// Usage
LinearGradient(...).background(DriveAITheme.backgroundColor)