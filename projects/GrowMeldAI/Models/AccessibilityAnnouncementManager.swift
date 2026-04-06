import Foundation
import UIKit

class AccessibilityAnnouncementManager {
    static let shared = AccessibilityAnnouncementManager()
    func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
