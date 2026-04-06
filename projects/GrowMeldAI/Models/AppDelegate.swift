import SwiftUI

// MARK: - AppDelegate

final class AppDelegate: NSObject, ObservableObject {

    static let recognitionService = RecognitionService()

    func applicationDidFinishLaunching() {
        Task(priority: .userInitiated) {
            print("ML model ready")
        }
    }
}