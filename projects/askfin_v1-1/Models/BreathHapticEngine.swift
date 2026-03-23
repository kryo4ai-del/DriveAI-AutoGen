import UIKit

/// Haptic feedback for BreathFlow phase transitions.
/// Generators are pre-warmed to reduce first-fire latency.
final class BreathHapticEngine {

    private let light        = UIImpactFeedbackGenerator(style: .light)
    private let medium       = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()

    init() {
        light.prepare()
        medium.prepare()
        notification.prepare()
    }

    func phaseStart() {
        light.impactOccurred()
        light.prepare()
    }

    func cycleComplete() {
        medium.impactOccurred()
        medium.prepare()
    }

    func sessionComplete() {
        notification.notificationOccurred(.success)
    }
}