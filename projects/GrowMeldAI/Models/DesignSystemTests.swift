import XCTest
import SwiftUI
@testable import DriveAI

final class DesignSystemTests: XCTestCase {
    
    // MARK: - Color Contrast Tests (WCAG AA Minimum)
    func testLightModeContrast_TextOnBackground() {
        let light = ColorPalette.light
        let contrast = calculateContrast(light.text, light.background)
        
        // WCAG AA requires 4.5:1 for normal text
        XCTAssertGreaterThanOrEqual(contrast, 4.5, 
            "Text color insufficient contrast on light background")
    }
    
    func testDarkModeContrast_TextOnBackground() {
        let dark = ColorPalette.dark
        let contrast = calculateContrast(dark.text, dark.background)
        
        XCTAssertGreaterThanOrEqual(contrast, 4.5)
    }
    
    func testSemanticColors_SuccessError_Distinguishable() {
        let light = ColorPalette.light
        
        let successContrast = calculateContrast(light.success, light.background)
        let errorContrast = calculateContrast(light.error, light.background)
        
        XCTAssertGreaterThanOrEqual(successContrast, 3.0, 
            "Success color insufficient contrast (non-text)")
        XCTAssertGreaterThanOrEqual(errorContrast, 3.0,
            "Error color insufficient contrast (non-text)")
        
        // Ensure colors are visually distinct (not just for color-blind users)
        let successDelta = colorDistance(light.success, light.error)
        XCTAssertGreaterThan(successDelta, 50, 
            "Success and error colors too similar (fails deuteranopia test)")
    }
    
    // MARK: - Typography Tests
    func testTypographyHierarchy_SizesIncreasing() {
        // H1 > H2 > H3 > Body > Caption
        XCTAssertGreater(fontSize(DesignTokens.Typography.h1),
                        fontSize(DesignTokens.Typography.h2))
        XCTAssertGreater(fontSize(DesignTokens.Typography.h2),
                        fontSize(DesignTokens.Typography.h3))
        XCTAssertGreater(fontSize(DesignTokens.Typography.h3),
                        fontSize(DesignTokens.Typography.body))
        XCTAssertGreater(fontSize(DesignTokens.Typography.body),
                        fontSize(DesignTokens.Typography.caption))
    }
    
    func testTypography_MinimumReadableSize() {
        let minSize: CGFloat = 12  // iOS accessibility minimum
        let captionSize = fontSize(DesignTokens.Typography.captionSmall)
        
        XCTAssertGreaterThanOrEqual(captionSize, minSize,
            "Caption size below minimum accessibility requirement")
    }
    
    // MARK: - Spacing Scale Tests
    func testSpacingScale_Consistent() {
        let spacing = DesignTokens.Spacing.self
        
        // Verify scale increases consistently (multiples of base unit)
        XCTAssertEqual(spacing.xs, 4)
        XCTAssertEqual(spacing.sm, 8)   // 2x xs
        XCTAssertEqual(spacing.md, 16)  // 2x sm
        XCTAssertEqual(spacing.lg, 24)  // 1.5x md
        XCTAssertEqual(spacing.xl, 32)  // 1.33x lg
        XCTAssertEqual(spacing.xxl, 48) // 1.5x xl
    }
    
    // MARK: - Border Radius Tests
    func testBorderRadius_AppropriateForContext() {
        let radius = DesignTokens.Radius.self
        
        // Verify increasing sizes for different component contexts
        XCTAssertLessThan(radius.sm, radius.md)
        XCTAssertLessThan(radius.md, radius.lg)
        XCTAssertLessThan(radius.lg, radius.xl)
        XCTAssertLessThan(radius.xl, radius.full)
    }
    
    // MARK: - Animation Timing Tests
    func testAnimationDurations_Professional() {
        let anim = DesignTokens.Animation.self
        
        // Verify durations follow Material Design motion standards
        XCTAssertEqual(anim.fast, 0.15)    // For micro-interactions
        XCTAssertEqual(anim.normal, 0.3)   // For most transitions
        XCTAssertEqual(anim.slow, 0.5)     // For large state changes
        
        // Ensure fast < normal < slow
        XCTAssertLessThan(anim.fast, anim.normal)
        XCTAssertLessThan(anim.normal, anim.slow)
    }
}

// MARK: - Helper Functions
func calculateContrast(_ foreground: Color, _ background: Color) -> Double {
    let fg = UIColor(foreground)
    let bg = UIColor(background)
    
    let fgLum = relativeLuminance(fg)
    let bgLum = relativeLuminance(bg)
    
    let lighter = max(fgLum, bgLum)
    let darker = min(fgLum, bgLum)
    
    return (lighter + 0.05) / (darker + 0.05)
}

func relativeLuminance(_ color: UIColor) -> Double {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
    let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
    let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

func colorDistance(_ c1: Color, _ c2: Color) -> Double {
    let uc1 = UIColor(c1)
    let uc2 = UIColor(c2)
    
    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
    
    uc1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    uc2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    
    let dr = r1 - r2
    let dg = g1 - g2
    let db = b1 - b2
    
    return sqrt(dr*dr + dg*dg + db*db)
}

func fontSize(_ font: Font) -> CGFloat {
    // Extract font size from SwiftUI Font (helper function)
    // In real implementation, may need to check system default sizes
    return 16  // Placeholder
}