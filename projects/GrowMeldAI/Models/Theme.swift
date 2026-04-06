import SwiftUI
struct Theme {
    struct Colors {
        let primary: Color
        let success: Color
        let error: Color
        let neutral: Color
        
        init(colorScheme: ColorScheme) {
            if colorScheme == .dark {
                primary = Color(red: 0.2, green: 0.6, blue: 1.0)
                success = Color(red: 0.2, green: 0.8, blue: 0.4)
                error = Color(red: 1.0, green: 0.3, blue: 0.3)
                neutral = Color(white: 0.15)
            } else {
                primary = Color(red: 0.0, green: 0.48, blue: 1.0)
                success = Color(red: 0.0, green: 0.7, blue: 0.0)
                error = Color(red: 1.0, green: 0.0, blue: 0.0)
                neutral = Color(white: 0.95)
            }
        }
    }
}