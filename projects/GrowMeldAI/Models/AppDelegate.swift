import SwiftUI

// MARK: - AppDelegate

final class AppDelegate: NSObject, ObservableObject {

    static let recognitionService = RecognitionService()

    func applicationDidFinishLaunching() {
        print("ML model loaded successfully")
    }
}