import SwiftUI

enum DesignTokens {
    // MARK: - Spacing Scale
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Typography Hierarchy
    enum Typography {
        static let h1 = Font.system(size: 32, weight: .bold, design: .default)
        static let h2 = Font.system(size: 28, weight: .bold, design: .default)
        static let h3 = Font.system(size: 24, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyBold = Font.system(size: 16, weight: .semibold, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let captionSmall = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 999
    }
    
    // MARK: - Shadows
    enum Shadow {
        static let sm = (color: Color.black, radius: 2.0, x: 0.0, y: 1.0)
        static let md = (color: Color.black, radius: 4.0, x: 0.0, y: 2.0)
        static let lg = (color: Color.black, radius: 8.0, x: 0.0, y: 4.0)
    }
    
    // MARK: - Border Widths
    enum Border {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 2
        static let thick: CGFloat = 3
    }
    
    // MARK: - Animation Durations
    enum Animation {
        static let fast = 0.15
        static let normal = 0.3
        static let slow = 0.5
    }
}