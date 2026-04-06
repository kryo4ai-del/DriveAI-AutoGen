// Add to debug build to test contrast
import UIKit
import SwiftUI
#if DEBUG
struct ContrastChecker {
    static func check(foreground: UIColor, background: UIColor) -> Double {
        let fg = foreground.luminance
        let bg = background.luminance
        let lighter = max(fg, bg)
        let darker = min(fg, bg)
        return (lighter + 0.05) / (darker + 0.05)
    }
}

extension UIColor {
    var luminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // WCAG formula
        let rs = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let gs = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let bs = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)
        
        return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs
    }
}
#endif