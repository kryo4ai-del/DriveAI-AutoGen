import XCTest
@testable import DriveAI

final class AccessibilityColorContrastTests: XCTestCase {
    /// Calculate WCAG contrast ratio between two colors
    /// Formula: (L1 + 0.05) / (L2 + 0.05) where L = relative luminance
    private func contrastRatio(foreground: UIColor, background: UIColor) -> Double {
        let fgLuminance = relativeLuminance(foreground)
        let bgLuminance = relativeLuminance(background)
        
        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func relativeLuminance(_ color: UIColor) -> Double {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rs = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let gs = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let bs = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)
        
        return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs
    }
    
    func test_primaryText_onWhite_hasWCAGAAContrast() {
        let primaryText = UIColor(AppColors.primaryText)
        let white = UIColor.white
        
        let ratio = contrastRatio(foreground: primaryText, background: white)
        XCTAssertGreaterThanOrEqual(ratio, 4.5, "Primary text should have 4.5:1 contrast (AA)")
    }
    
    func test_success_onWhite_hasWCAGAAContrast() {
        let success = UIColor(AppColors.success)
        let white = UIColor.white
        
        let ratio = contrastRatio(foreground: success, background: white)
        XCTAssertGreaterThanOrEqual(ratio, 4.5)
    }
    
    func test_error_onWhite_hasWCAGAAContrast() {
        let error = UIColor(AppColors.error)
        let white = UIColor.white
        
        let ratio = contrastRatio(foreground: error, background: white)
        XCTAssertGreaterThanOrEqual(ratio, 4.5)
    }
    
    func test_textSecondary_onWhite_hasWCAGAAContrast() {
        let secondary = UIColor(AppColors.textSecondary)
        let white = UIColor.white
        
        let ratio = contrastRatio(foreground: secondary, background: white)
        XCTAssertGreaterThanOrEqual(ratio, 4.5)
    }
}