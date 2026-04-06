import Foundation
import SwiftUI

enum AppConfig {
    enum Exam {
        static let totalQuestions: Int = 30
        static let passThreshold: Double = 75.0
        static let timeLimit: TimeInterval = 30 * 60  // 30 minutes
        static let questionShowDelay: TimeInterval = 0.3
    }
    
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let animationDuration: Double = 0.3
        static let hapticEnabled: Bool = true
    }
    
    enum Localization {
        static let supportedLocales = ["de-DE", "en-US"]
        static let defaultLocale = Locale(identifier: "de-DE")
    }
}