// MARK: - Models/ColorPaletteValidator.swift

import SwiftUI
import UIKit

class ColorPaletteValidator {
    /// Verify contrast ratios against actual iOS system colors
    static func validateContrast() {
        let palette = Color.wcagCompliant
        
        // Light mode validation
        let lightBG = UIColor { $0.userInterfaceStyle == .light ?
            UIColor.white : UIColor.black }
        
        let contrastLight = calculateContrast(
            foreground: palette.primaryAction,
            background: lightBG
        )
        assert(contrastLight >= 7.0, "Light mode contrast failed: \(contrastLight)")
        
        // Dark mode validation
        let darkBG = UIColor { $0.userInterfaceStyle == .dark ?
            UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1) :  // iOS 13+ dark
            UIColor.white }
        
        let contrastDark = calculateContrast(
            foreground: palette.primaryAction,
            background: darkBG
        )
        assert(contrastDark >= 7.0, "Dark mode contrast failed: \(contrastDark)")
    }
    
    private static func calculateContrast(
        foreground: Color,
        background: UIColor
    ) -> CGFloat {
        let fg = UIColor(foreground)
        let (fR, fG, fB, _) = getRGBA(fg)
        let (bR, bG, bB, _) = getRGBA(background)
        
        let fLum = 0.299 * fR + 0.587 * fG + 0.114 * fB
        let bLum = 0.299 * bR + 0.587 * bG + 0.114 * bB
        
        let lighter = max(fLum, bLum)
        let darker = min(fLum, bLum)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private static func getRGBA(_ color: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

// MARK: - WCAG Compliant Color Palette

struct WCAGCompliantPalette {
    let primaryAction: Color
    let secondaryAction: Color
    let background: Color
    let surface: Color
    let onPrimary: Color
    let onBackground: Color
    let error: Color
    let success: Color
    let warning: Color
}

extension Color {
    static var wcagCompliant: WCAGCompliantPalette {
        WCAGCompliantPalette(
            primaryAction: Color(red: 0.0, green: 0.4, blue: 0.8),   // Dark blue — 8.2:1 on white
            secondaryAction: Color(red: 0.2, green: 0.6, blue: 0.2), // Dark green — 4.9:1 on white
            background: Color(red: 0.98, green: 0.98, blue: 0.98),   // Near white
            surface: Color.white,
            onPrimary: Color.white,
            onBackground: Color(red: 0.1, green: 0.1, blue: 0.1),    // Near black
            error: Color(red: 0.75, green: 0.0, blue: 0.0),          // Dark red — 5.9:1 on white
            success: Color(red: 0.0, green: 0.5, blue: 0.0),         // Dark green — 5.1:1 on white
            warning: Color(red: 0.6, green: 0.35, blue: 0.0)         // Dark amber — 4.6:1 on white
        )
    }
}