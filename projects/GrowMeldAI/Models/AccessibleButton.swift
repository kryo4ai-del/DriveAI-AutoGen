// Shared/Modifiers/AccessibilityModifiers.swift
import SwiftUI
import UIKit
struct AccessibleButton: ViewModifier {
    let label: String
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
        .accessibilityLabel(label)
        .accessibilityHint("Double-tap to select")
    }
}

// Shared/Extensions/Color+Theme.swift
extension Color {
    static var questionText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
    }
    
    static var feedbackCorrect: Color {
        Color(red: 0.2, green: 0.8, blue: 0.2)  // Accessible green
    }
}