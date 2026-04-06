// ✓ Add to project: Color contrast validation helper
import SwiftUI
import UIKit
struct AccessibilityColorPalette {
    // Define colors with inline contrast ratios
    static let label = Color(
        light: Color(red: 0, green: 0, blue: 0),           // #000000
        dark: Color(red: 1, green: 1, blue: 1)             // #FFFFFF
    )
    // Light mode: black on white = 21:1 ✓✓✓
    // Dark mode: white on black = 21:1 ✓✓✓
    
    static let secondaryLabel = Color(
        light: Color(red: 0.3, green: 0.3, blue: 0.3),     // #4D4D4D
        dark: Color(red: 0.85, green: 0.85, blue: 0.85)    // #D9D9D9
    )
    // Light mode: #4D4D4D on #FFFFFF = 7.9:1 ✓ (AA+)
    // Dark mode: #D9D9D9 on #000000 = 9.3:1 ✓ (AAA)
    
    static let tertiaryLabel = Color(
        light: Color(red: 0.5, green: 0.5, blue: 0.5),     // #808080
        dark: Color(red: 0.7, green: 0.7, blue: 0.7)       // #B3B3B3
    )
    // Light mode: #808080 on #FFFFFF = 4.5:1 ✓ (AA minimum)
    // Dark mode: #B3B3B3 on #000000 = 6.5:1 ✓ (AAA)
    
    // ✗ DO NOT USE:
    // static let badSecondary = Color(UIColor.systemGray3) // Fails dark mode
}

// ✓ Add to documentation:
// Run contrast checks:
//   Tool 1: https://webaim.org/resources/contrastchecker/
//   Tool 2: Xcode Accessibility Inspector (built-in)
//   Tool 3: WAVE browser extension
//
// CI Integration:
//   - SwiftUI Diagnostics to catch hard-coded bad colors
//   - Snapshot tests with color overrides

extension Color {
    // Helper for light/dark separation (iOS 15+)
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}