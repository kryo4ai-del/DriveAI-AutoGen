import SwiftUI

/// Centralized haptic feedback manager
@Observable
final class HapticManager {
    static let shared = HapticManager()
    
    var isEnabled = true
    
    enum FeedbackStyle {
        case light
        case medium
        case heavy
        
        var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            }
        }
    }
    
    /// Trigger impact feedback (button tap, selection)
    func impact(_ style: FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style.uiStyle)
        generator.impactOccurred()
    }
    
    /// Trigger notification feedback (success, error, warning)
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// Success feedback
    func success() {
        notification(.success)
    }
    
    /// Error feedback
    func error() {
        notification(.error)
    }
    
    /// Warning feedback
    func warning() {
        notification(.warning)
    }
}

// MARK: - Haptic Testing Helpers
#if DEBUG
extension HapticManager {
    func testAllFeedback() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.impact(.heavy)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.success()
        }
    }
}
#endif