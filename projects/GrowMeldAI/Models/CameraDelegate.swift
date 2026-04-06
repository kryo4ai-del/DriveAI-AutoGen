import Foundation

// PREFER: Protocol-based weak references
protocol CameraDelegate: AnyObject {
    func cameraDidFinish()
}

// PREFER: Weak capture in ViewModels
@MainActor
class CameraViewModel {
    weak var delegate: CameraDelegate?

    var imageProcessorOnComplete: (() -> Void)?

    func setup() {
        imageProcessorOnComplete = { [weak self] in
            self?.updateUI()
        }
    }

    func updateUI() {
        // Update UI
    }
}