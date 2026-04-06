import UIKit
enum AccessibilityHelper {
    static func announceAnswer(isCorrect: Bool) {
        let message = isCorrect ? "Correct answer" : "Incorrect answer"
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}