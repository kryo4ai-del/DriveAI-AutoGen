import SwiftUI

// MARK: - AppDelegate

final class AppDelegate: NSObject, ObservableObject {

    static let recognitionService: any RecognitionServiceProtocol = RecognitionService()

    func applicationDidFinishLaunching() {
        Task(priority: .userInitiated) {
            do {
                try await AppDelegate.recognitionService.loadModel()
                print("ML model loaded successfully")
            } catch {
                print("Failed to preload ML model: \(error)")
            }
        }
    }
}