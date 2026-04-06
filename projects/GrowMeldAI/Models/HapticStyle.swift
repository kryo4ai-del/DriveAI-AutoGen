import SwiftUI
import CoreHaptics

enum HapticStyle {
    case light
    case medium
    case notification
    case custom(Intensity: Double, Sharpness: Double)
}

// MARK: - Private Extensions (Implementation Details)
private extension UIImpactFeedbackGenerator {
    func impactOccurred() {
        prepare()
        impactOccurred()
    }
}

private extension UINotificationFeedbackGenerator {
    func notificationOccurred() {
        prepare()
        notificationOccurred(.success)
    }
}