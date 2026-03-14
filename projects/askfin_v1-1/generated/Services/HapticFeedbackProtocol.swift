import UIKit

enum HapticType {
    case success
    case error
}

protocol HapticFeedbackProtocol {
    func trigger(_ type: HapticType)
}

final class HapticFeedback: HapticFeedbackProtocol {
    private let generator = UINotificationFeedbackGenerator()

    func trigger(_ type: HapticType) {
        switch type {
        case .success: generator.notificationOccurred(.success)
        case .error:   generator.notificationOccurred(.error)
        }
    }
}